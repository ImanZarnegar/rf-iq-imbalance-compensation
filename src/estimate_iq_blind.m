function est = estimate_iq_blind(r)
%ESTIMATE_IQ_BLIND Blind estimation (no pilots) via circularity.
%   Assumes the ideal signal is zero-mean and circular (E[x^2] = 0), true
%   for square QAM. Estimates DC and the image ratio rho = nu/mu and a
%   scalar gain that normalises the output power to 1.
%   Accuracy depends on N (about 1.5 % EVM at N=2e4 without noise).
    r = r(:);
    d = mean(r);
    z = r - d;
    p = mean(abs(z).^2);
    P = mean(z.^2);
    rho = P / (p + sqrt(p^2 - abs(P)^2));
    out = (z - rho * conj(z)) / (1 - abs(rho)^2);
    gain = 1 / sqrt(mean(abs(out).^2));
    est = struct('mu', 1, 'nu', rho, 'dc', d, 'gain', gain);
end
