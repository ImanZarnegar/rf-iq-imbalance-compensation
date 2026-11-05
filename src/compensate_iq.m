function xh = compensate_iq(r, est)
%COMPENSATE_IQ Exact inverse of the widely-linear model.
    z  = r - est.dc;
    D  = abs(est.mu)^2 - abs(est.nu)^2;
    xh = est.gain * (conj(est.mu) * z - est.nu * conj(z)) / D;
end
