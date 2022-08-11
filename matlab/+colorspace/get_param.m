function pram = get_param(space)
% DESCRIPTION
%   Get colorspace prameters, including xy-coordinate of R, G, B, and white point,
%   and gamma, etc.
% INPUT
%   space:      The colorspace name. See colorutil.cs_name_validator for detail.
% OUTPUT
%   param:       A struct containing fields as following:
%               .w:         1*3 vector, white point, XYZ coordinate.
%               .w_name:    char vector, the white point name, such as 'D65', etc.
%               .rgb:       3*2 matrix, each row represents a color, xy coordinate.
%               .tsf:       1*4 vector, [alpha, beta, gamma, k].
%                           See colorspace.rgb_gamma & colorspace.rgb_ungamma for detail.

p = inputParser;
p.addRequired('space', @colorutil.cs_name_validator);
p.parse(space);

if strcmpi(space, 'sRGB')
    name = 'srgb';
    w_name = 'D65';
    g = 2.4;
    a = 0.055;
    b = 0.0031308;
    k = 12.92;
    y_coef = [1/3, 1/3, 1/3];
    cbcr_coef = [1, 1];
elseif strcmpi(space, 'AdobeRGB') || strcmpi(space, 'ARGB')
    name = 'argb';
    w_name = 'D65';
    g = 2.2;
    a = 0;
    b = 0;
    k = 0;
    y_coef = [1/3, 1/3, 1/3];
    cbcr_coef = [1, 1];
elseif strcmpi(space, '709')
    name = '709';
    w_name = 'D65';
    g = 1 / 0.45;
    a = 0.099;
    b = 0.018;
    k = 4.5;
    y_coef = [0.2126, 0.7152, 0.0722];
    cbcr_coef = [1.8556, 1.5748];
elseif strcmpi(space, '2020')
    name = '2020';
    w_name = 'D65';
    g = 1 / 0.45;
    a = 0.099297;
    b = 0.018053;
    k = 4.5;
    y_coef = [0.2627, 0.6780, 0.0593];
    cbcr_coef = [1.8814, 1.4746];
elseif strcmpi(space, 'p3d65') || strcmpi(space, 'd65p3') ||strcmpi(space, 'displayp3')
    name = 'p3d65';
    w_name = 'D65';
    g = 1 / 0.45;
    a = 0.099297;
    b = 0.018053;
    k = 4.5;
    y_coef = [0.2627, 0.6780, 0.0593];
    cbcr_coef = [1.8814, 1.4746];
elseif strcmpi(space, 'p3dci') || strcmpi(space, 'dci3')
    name = 'p3dci';
    w_name = 'D65';
    g = 1 / 0.45;
    a = 0.099297;
    b = 0.018053;
    k = 4.5;
    y_coef = [0.2627, 0.6780, 0.0593];
    cbcr_coef = [1.8814, 1.4746];
else
    warning('Input color space %d cannot recognize! Use default sRGB!', space);
end

pram.short_name = name;
pram.w_name = w_name;
pram.w = colorspace.get_white_point(w_name);
pram.rgb = colorspace.get_primaries(name);
pram.tsf = [a, b, g, k];
pram.yuv = [y_coef, cbcr_coef];
end