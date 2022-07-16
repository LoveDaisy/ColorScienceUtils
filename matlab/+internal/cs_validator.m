function res = cs_validator(in)
% DESCRIPTION
%   Check colorspace settings. Either it is a string for colorspace name, or it is
%   a colorspace parameter structure.

if ischar(in)
    res = internal.cs_name_validator(in);
else
    res = isstruct(in) && isscalar(in) && ...
        isfield(in, 'w') && isfield(in, 'w_name') && isfield(in, 'rgb') && isfield(in, 'tsf');
end
end