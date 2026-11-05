function est = estimate_iq_pilot(r, xp)
%ESTIMATE_IQ_PILOT Data-aided least squares on known pilot symbols.
%   Fits  r_p = mu*xp + nu*conj(xp) + dc  (works with noise, few pilots).
    r = r(:); xp = xp(:);
    n = numel(xp);
    A = [xp, conj(xp), ones(n, 1)];
    th = A \ r(1:n);
    est = struct('mu', th(1), 'nu', th(2), 'dc', th(3), 'gain', 1);
end
