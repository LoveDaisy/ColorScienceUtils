function res = cs_name_validator(space)
% INPUT
%   space:          Expected to be a valid colorspace name, such as 'sRGB' or 'AdobeRGB'.
% OUTPUT
%   res:            true if input space is a valid name, false otherwise.

if ~ischar(space)
    res = false;
elseif strcmpi(space, 'sRGB') || strcmpi(space, 'AdobeRGB') || strcmpi(space, 'ARGB')
    res = true;
else
    res = false;
end
end