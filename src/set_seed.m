function set_seed(seed)
%SET_SEED Reproducible random numbers in MATLAB and Octave.
    try
        rng(seed, 'twister');
    catch
        rand('twister', seed); %#ok<RAND>
        randn('state', seed);  %#ok<RAND>
    end
end
