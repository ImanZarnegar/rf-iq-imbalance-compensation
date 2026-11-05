function [mu, nu] = iq_mu_nu(gain_db, phase_deg)
%IQ_MU_NU Complex imbalance coefficients, model  y = mu*x + nu*conj(x).
%   Definition: I branch ideal; Q branch is scaled by g = 10^(gain_db/20)
%   and mixed with the I branch by phase error phi:
%       y_I = x_I
%       y_Q = g * ( sin(phi) * x_I + cos(phi) * x_Q )
    g   = 10^(gain_db / 20);
    phi = phase_deg * pi / 180;
    mu = (1 + g * cos(phi) + 1j * g * sin(phi)) / 2;
    nu = (1 - g * cos(phi) + 1j * g * sin(phi)) / 2;
end
