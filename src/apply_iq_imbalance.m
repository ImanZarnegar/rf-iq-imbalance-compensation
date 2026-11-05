function r = apply_iq_imbalance(x, gain_db, phase_deg, dc, snr_db)
%APPLY_IQ_IMBALANCE Impairment model: r = mu*x + nu*conj(x) + dc + AWGN.
%   snr_db = Inf (or omitted) -> noiseless. SNR is relative to E|x|^2.
    if nargin < 4 || isempty(dc), dc = 0; end
    if nargin < 5, snr_db = Inf; end
    [mu, nu] = iq_mu_nu(gain_db, phase_deg);
    r = mu * x + nu * conj(x) + dc;
    if isfinite(snr_db)
        s2 = mean(abs(x).^2) * 10^(-snr_db / 10);
        r = r + sqrt(s2 / 2) * (randn(size(x)) + 1j * randn(size(x)));
    end
end
