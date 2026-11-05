function run_tests()
%RUN_TESTS Self-contained tests; errors (non-zero exit) on any failure.
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src'));
    set_seed(1);
    mu0 = 0; %#ok<NASGU>

    % 1) QAM: unit power, M distinct points, no toolbox
    x = generate_qam(50000, 16);
    check(abs(mean(abs(x).^2) - 1) < 0.02, 'QAM power');
    check(numel(unique(round(x * 1e6))) == 16, 'QAM constellation size');

    % 2) Complex model == original 2x2 real-matrix model
    x = generate_qam(1000, 16);
    g = 10^(-1/20); p = 5*pi/180;
    yref = real(x) + 1j * g * (sin(p) * real(x) + cos(p) * imag(x));
    y = apply_iq_imbalance(x, -1, 5);
    check(max(abs(y - yref)) < 1e-12, 'model equivalence');

    % 3) Noiseless pilot LS recovers parameters exactly
    dc = 0.05 + 0.03j;
    r = apply_iq_imbalance(x, -1, 5, dc);
    est = estimate_iq_pilot(r, x(1:64));
    [mu, nu] = iq_mu_nu(-1, 5);
    check(abs(est.mu - mu) < 1e-10 && abs(est.nu - nu) < 1e-10 && abs(est.dc - dc) < 1e-10, 'pilot params');
    [~, evm_db] = iq_metrics(x, compensate_iq(r, est));
    check(evm_db < -150, 'pilot noiseless EVM');
    check(irr_db(mu, nu, est) > 150, 'pilot noiseless IRR');

    % 4) Noisy: EVM matches theory within 1 dB
    N = 20000; snr = 30; acc = 0; T = 20;
    for t = 1:T
        x = generate_qam(N, 16);
        r = apply_iq_imbalance(x, -1, 5, dc, snr);
        [~, e] = iq_metrics(x, compensate_iq(r, estimate_iq_pilot(r, x(1:256))));
        acc = acc + 10^(e/10);
    end
    s2 = 10^(-snr/10);
    theory = s2 * (abs(mu)^2 + abs(nu)^2) / (abs(mu)^2 - abs(nu)^2)^2;
    check(abs(10*log10(acc/T) - 10*log10(theory/(1+theory))) < 1, 'noisy EVM vs theory');

    % 5) Blind: no pilots, noiseless, 10^5 samples
    x = generate_qam(100000, 16);
    r = apply_iq_imbalance(x, -1, 5, dc);
    evm_pct = iq_metrics(x, compensate_iq(r, estimate_iq_blind(r)));
    check(evm_pct < 2, 'blind EVM');

    % 6) File I/O roundtrip (cf32, csv, mat)
    r = r(1:1000);
    f = [tempname() '.cf32']; fid = fopen(f, 'wb');
    iq = [real(r).'; imag(r).']; fwrite(fid, iq(:), 'float32'); fclose(fid);
    check(max(abs(load_iq(f) - r)) < 1e-6, 'cf32 io'); delete(f);
    f = [tempname() '.csv']; fid = fopen(f, 'w'); fprintf(fid, 'I,Q\n');
    fprintf(fid, '%.12g,%.12g\n', [real(r).'; imag(r).']); fclose(fid);
    check(max(abs(load_iq(f) - r)) < 1e-9, 'csv io'); delete(f);
    f = [tempname() '.mat']; iq = r; save(f, 'iq');
    check(max(abs(load_iq(f) - r)) < 1e-12, 'mat io'); delete(f);

    disp('ALL TESTS PASSED');
end

function check(cond, name)
    if ~cond, error('TEST FAILED: %s', name); end
    fprintf('ok   %s\n', name);
end
