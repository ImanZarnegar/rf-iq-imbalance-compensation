function v = irr_db(mu, nu, est)
%IRR_DB Image rejection ratio in dB.
%   irr_db(mu, nu)       IRR of the impairment itself.
%   irr_db(mu, nu, est)  residual IRR after applying compensator est.
    if nargin < 3
        a = mu; b = nu;
    else
        D  = abs(est.mu)^2 - abs(est.nu)^2;
        c1 = est.gain * conj(est.mu) / D;
        c2 = -est.gain * est.nu / D;
        a = c1 * mu + c2 * conj(nu);
        b = c1 * nu + c2 * conj(mu);
    end
    v = 20 * log10(abs(a) / max(abs(b), realmin));
end
