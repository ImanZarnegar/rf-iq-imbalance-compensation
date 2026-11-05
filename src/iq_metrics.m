function [evm_pct, evm_db] = iq_metrics(x, xh)
%IQ_METRICS EVM of xh vs reference x after optimal complex scaling.
    x = x(:); xh = xh(:);
    a = (xh' * x) / (xh' * xh);
    e = mean(abs(a * xh - x).^2) / mean(abs(x).^2);
    evm_pct = 100 * sqrt(e);
    evm_db  = 10 * log10(e);
end
