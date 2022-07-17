function res = rgb_compression_validator(method)
res = ischar(method) && (...
    strcmpi(method, 'None') || ...
    strcmpi(method, 'Clip') || ...
    strcmpi(method, 'DeSat') || ...
    strcmpi(method, 'Greying') || strcmpi(method, 'GreyingXYZ') || ...
    strcmpi(method, 'GreyingLab') || strcmpi(method, 'GreyingICtCp')...
    );
end