function res = rgb_clamping_validator(method)
res = ischar(method) && (strcmpi(method, 'clip') || strcmpi(method, 'desat') || ...
    strcmpi(method, 'greying') || strcmpi(method, 'minuv'));
end