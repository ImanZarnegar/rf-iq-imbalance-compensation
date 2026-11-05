function [x, bits_idx] = generate_qam(N, M)
%GENERATE_QAM Random square M-QAM symbols, unit average power (no toolbox).
%   x = generate_qam(N, M)   N x 1 complex column vector, M = 4,16,64,256...
    if nargin < 2, M = 16; end
    k = sqrt(M);
    assert(k == round(k) && k >= 2, 'M must be a square number (4, 16, 64, ...).');
    levels = (-(k-1):2:(k-1)).';
    bits_idx = floor(rand(N, 2) * k) + 1;          % random level indices
    x = levels(bits_idx(:,1)) + 1j * levels(bits_idx(:,2));
    x = x / sqrt(2 * (M - 1) / 3);                  % E|x|^2 = 1
end
