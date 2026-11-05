function r = load_iq(file, varname)
%LOAD_IQ Read complex baseband samples from SDR-style files.
%   .mat  complex variable (varname, or first complex/2-col variable)
%   .csv  two columns: I,Q (optional header)
%   .cf32 interleaved float32 I,Q (GNU Radio / SDR)
%   .wav  2 channels: I,Q
    [~, ~, ext] = fileparts(file);
    switch lower(ext)
        case '.mat'
            s = load(file);
            if nargin >= 2, v = s.(varname);
            else
                f = fieldnames(s); v = [];
                for i = 1:numel(f)
                    c = s.(f{i});
                    if isnumeric(c) && (~isreal(c) || size(c,2) == 2), v = c; break; end
                end
                assert(~isempty(v), 'No complex or N x 2 variable found in %s', file);
            end
            r = to_complex(v);
        case '.csv'
            v = dlmread(file, ',', 1, 0);
            if isempty(v) || size(v,2) < 2, v = dlmread(file, ','); end
            r = to_complex(v(:, 1:2));
        case '.cf32'
            fid = fopen(file, 'rb'); assert(fid > 0, 'Cannot open %s', file);
            v = fread(fid, Inf, 'float32'); fclose(fid);
            r = double(v(1:2:end-1)) + 1j * double(v(2:2:end));
        case '.wav'
            v = audioread(file);
            assert(size(v,2) >= 2, 'WAV must have 2 channels (I,Q).');
            r = v(:,1) + 1j * v(:,2);
        otherwise
            error('Unsupported file type: %s', ext);
    end
    r = r(:);
end

function c = to_complex(v)
    if isreal(v) && size(v,2) == 2, c = v(:,1) + 1j * v(:,2);
    else, c = v(:); end
end
