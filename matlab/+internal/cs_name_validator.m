function res = cs_name_validator(space)
% INPUT
%   space:          Expected to be a valid colorspace name, such as 'sRGB' or 'AdobeRGB'.
% OUTPUT
%   res:            true if input space is a valid name, false otherwise.

res = ischar(space) && (...
    strcmpi(space, 'sRGB') || ...
    strcmpi(space, 'AdobeRGB') || strcmpi(space, 'ARGB') ...
    );
end