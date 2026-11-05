%RUN_DEMO Simulation: EVM / IRR vs SNR for pilot-aided and blind estimation.
clear; close all; clc;
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src'));
outdir = fullfile(fileparts(mfilename('fullpath')), '..', 'docs');

% ---- configuration (all parameters in one place) ----
cfg.M = 16;  cfg.N = 20000;  cfg.nPilot = 256;
cfg.gain_db = -1;  cfg.phase_deg = 5;  cfg.dc = 0.05 + 0.03j;
cfg.snr_db = 10:5:40;  cfg.trials = 20;  cfg.seed = 7;

set_seed(cfg.seed);
[mu, nu] = iq_mu_nu(cfg.gain_db, cfg.phase_deg);
fprintf('Impairment IRR = %.1f dB\n', irr_db(mu, nu));

S = numel(cfg.snr_db);
E = zeros(S, 3);  IRRp = zeros(S, 1);  IRRb = zeros(S, 1);
for s = 1:S
    acc = zeros(cfg.trials, 5);
    for t = 1:cfg.trials
        x = generate_qam(cfg.N, cfg.M);
        r = apply_iq_imbalance(x, cfg.gain_db, cfg.phase_deg, cfg.dc, cfg.snr_db(s));
        ep = estimate_iq_pilot(r, x(1:cfg.nPilot));
        eb = estimate_iq_blind(r);
        [~, acc(t,1)] = iq_metrics(x, r);
        [~, acc(t,2)] = iq_metrics(x, compensate_iq(r, ep));
        [~, acc(t,3)] = iq_metrics(x, compensate_iq(r, eb));
        acc(t,4) = irr_db(mu, nu, ep);
        acc(t,5) = irr_db(mu, nu, eb);
    end
    E(s,:) = 10 * log10(mean(10.^(acc(:,1:3) / 10), 1));
    IRRp(s) = mean(acc(:,4));  IRRb(s) = mean(acc(:,5));
    fprintf('SNR %2d dB | EVM dB: raw %6.2f pilot %6.2f blind %6.2f | IRR: pilot %5.1f blind %5.1f\n', ...
        cfg.snr_db(s), E(s,1), E(s,2), E(s,3), IRRp(s), IRRb(s));
end

if ~exist(outdir, 'dir'), mkdir(outdir); end
f1 = figure('Visible', 'off');
plot(cfg.snr_db, E(:,1), 'r-o', cfg.snr_db, E(:,2), 'b-s', cfg.snr_db, E(:,3), 'g-^', 'LineWidth', 1.5);
grid on; xlabel('SNR (dB)'); ylabel('EVM (dB)');
legend('uncompensated', 'pilot LS', 'blind', 'Location', 'southwest');
title('EVM vs SNR'); print(f1, fullfile(outdir, 'evm_vs_snr.png'), '-dpng', '-r150');

f2 = figure('Visible', 'off');
plot(cfg.snr_db, IRRp, 'b-s', cfg.snr_db, IRRb, 'g-^', 'LineWidth', 1.5);
hold on; plot(cfg.snr_db, irr_db(mu, nu) * ones(S,1), 'r--'); grid on;
xlabel('SNR (dB)'); ylabel('Residual IRR (dB)');
legend('pilot LS', 'blind', 'before', 'Location', 'northwest');
title('Image rejection ratio'); print(f2, fullfile(outdir, 'irr_vs_snr.png'), '-dpng', '-r150');

% ---- constellations at 30 dB ----
x = generate_qam(cfg.N, cfg.M);
r = apply_iq_imbalance(x, cfg.gain_db, cfg.phase_deg, cfg.dc, 30);
xh = compensate_iq(r, estimate_iq_pilot(r, x(1:cfg.nPilot)));
f3 = figure('Visible', 'off');
subplot(1,2,1); plot(real(r), imag(r), '.', 'MarkerSize', 2); axis equal; grid on; title('Before');
subplot(1,2,2); plot(real(xh), imag(xh), '.', 'MarkerSize', 2); axis equal; grid on; title('After (pilot LS)');
print(f3, fullfile(outdir, 'constellation.png'), '-dpng', '-r150');
fprintf('Figures saved to %s\n', outdir);
