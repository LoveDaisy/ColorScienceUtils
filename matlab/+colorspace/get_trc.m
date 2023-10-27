function trc = get_trc(trc_name)
% DESCRIPTION
%   Get a parameter array for transfer characteristics. [a, b, g, k].
% SYNTAX
%   trc = get_trc(trc_name);
% INPUT
%   trc_name:           A string, expected to be a valid transfer characteristics name.
%                       See colorutil.trc_name_validator for detail.
% OUTPUT
%   trc:                4-element array, [a, b, g, k]. See colorspace.rgb_gamma and
%                       colorspace.rgb_ungamma for detail.

p = inputParser;
p.addRequired('name', @colorutil.trc_name_validator);
p.parse(trc_name);

if strcmpi(trc_name, 'Linear')
    g = 1.0;
    a = 0;
    b = 0;
    k = 1.0;
elseif strcmpi(trc_name, 'sRGB') || ...
        strcmpi(trc_name, 'p3d65') || strcmpi(trc_name, 'd65p3') ||strcmpi(trc_name, 'displayp3')
    g = 2.4;
    a = 0.055;
    b = 0.0031308;
    k = 12.92;
elseif strcmpi(trc_name, 'AdobeRGB') || strcmpi(trc_name, 'ARGB')
    g = 2.2;
    a = 0;
    b = 0;
    k = 0;
elseif strcmpi(trc_name, 'p3dci') || strcmpi(trc_name, 'dci3')
    g = 2.6;
    a = 0;
    b = 0;
    k = 0;
elseif strcmpi(trc_name, '709')
    g = 1 / 0.45;
    a = 0.099;
    b = 0.018;
    k = 4.5;
elseif strcmpi(trc_name, '2020')
    g = 1 / 0.45;
    a = 0.099297;
    b = 0.018053;
    k = 4.5;
else
    warning('Input color space %d cannot recognize! Use default sRGB!', trc_name);
    g = 2.4;
    a = 0.055;
    b = 0.0031308;
    k = 12.92;
end

trc = [a, b, g, k];
end
