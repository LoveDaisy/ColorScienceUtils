function res = cs_name_validator(space)
% DESCRIPTION
%   It validates input colorspace name.
% INPUT
%   space:          Expected to be a valid colorspace name, such as 'sRGB' or 'AdobeRGB'.
% OUTPUT
%   res:            true if input space is a valid name, false otherwise.

res = ischar(space) && (...
    strcmpi(space, 'sRGB') || ...
    strcmpi(space, 'AdobeRGB') || strcmpi(space, 'ARGB') || ...
    strcmpi(space, 'P3D65') || strcmpi(space, 'DisplayP3') || strcmpi(space, 'D65P3') || ...
    strcmpi(space, 'P3DCI') || strcmpi(space, 'DCIP3') || ...
    strcmpi(space, '709') || ...
    strcmpi(space, '601') || strcmpi(space, '601-625') || strcmpi(space, '601_625') || ...
        strcmpi(space, 'bt470bg') || strcmpi(space, '470bg') || ...
    strcmpi(space, '601-525') || strcmpi(space, '601_525') || strcmpi(space, 'smpte170m') || strcmpi(space, '170m') || ...
    strcmpi(space, '2020') ...
    );
end