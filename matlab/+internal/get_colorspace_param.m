function pram = get_colorspace_param(space)
% DESCRIPTION
%   Get colorspace prameters, including xy-coordinate of R, G, B, and white point,
%   and gamma, etc.
% INPUT
%   space:      The colorspace name. See internal.cs_name_validator for detail.
% OUTPUT
%   pri:        A struct containing fields as following:
%               .w:         1*3 vector, white point, XYZ coordinate.
%               .w_name:    char vector, the white point name, such as 'D65', etc.
%               .rgb:       3*2 matrix, each row represents a color, xy coordinate.
%               .alpha      a scalar, used in gamma transfer function
%               .gamma      a scalar, used in gamma transfer function

p = inputParser;
p.addRequired('space', @internal.cs_name_validator);
p.parse(space);

W_D65 = [0.95047, 1.00000, 1.08883];

if strcmpi(space, 'sRGB')
    pri_xy = [0.6400, 0.3300;
        0.3000, 0.6000;
        0.1500, 0.0600];
    W = W_D65;
    name = 'D65';
    g = 2.4;
    a = 0.055;
elseif strcmpi(space, 'AdobeRGB')
    pri_xy = [0.6400, 0.3300;
        0.2100, 0.7100;
        0.1500, 0.0600];
    W = W_D65;
    name = 'D65';
    g = 2.2;
    a = 0;
else
    warning('Input color space %d cannot recognize! Use default sRGB!', space);
end

pram.w = W;
pram.w_name = name;
pram.rgb = pri_xy;
pram.gamma = g;
pram.alpha = a;
end