function res = rgb_name_validator(space)
% INPUT
%   space:          Expected to be a valid colorspace name, such as 'sRGB' or 'AdobeRGB'.
% OUTPUT
%   res:            true if input space is a valid name, false otherwise.

res = ischar(space) && (...
    strcmpi(space, 'sRGB') || ...
    strcmpi(space, 'AdobeRGB') || strcmpi(space, 'ARGB') || ...
    strcmpi(space, '709') || ...
    strcmpi(space, '2020') ...
    );
end