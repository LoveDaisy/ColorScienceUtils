function param = get_param(cs_name, varargin)
% DESCRIPTION
%   Get colorspace prameters, including xy-coordinate of R, G, B, and white point,
%   and gamma, etc.
% SYNTAX
%   param = get_param(name);
%   param = get_param(name, 'linear');
% INPUT
%   name:      The colorspace name. See colorutil.cs_name_validator for detail.
%   linear:     'linear'. Whether use a linear transfer characteristics.
% OUTPUT
%   param:       A struct containing fields as following:
%               .w:         1*3 vector, white point, XYZ coordinate.
%               .w_name:    char vector, the white point name, such as 'D65', etc.
%               .rgb:       3*2 matrix, each row represents a color, xy coordinate.
%               .tsf:       1*4 vector, [alpha, beta, gamma, k].
%                           See colorspace.rgb_gamma & colorspace.rgb_ungamma for detail.

p = inputParser;
p.addRequired('name', @colorutil.cs_name_validator);
p.addOptional('lin', [], @(x) strcmpi(x, 'linear'));
p.parse(cs_name, varargin{:});

if strcmpi(cs_name, 'sRGB')
    name = 'srgb';
    w_name = 'D65';
elseif strcmpi(cs_name, 'AdobeRGB') || strcmpi(cs_name, 'ARGB')
    name = 'argb';
    w_name = 'D65';
elseif strcmpi(cs_name, '709')
    name = '709';
    w_name = 'D65';
elseif strcmpi(cs_name, '2020')
    name = '2020';
    w_name = 'D65';
elseif strcmpi(cs_name, 'p3d65') || strcmpi(cs_name, 'd65p3') ||strcmpi(cs_name, 'displayp3')
    name = 'p3d65';
    w_name = 'D65';
elseif strcmpi(cs_name, 'p3dci') || strcmpi(cs_name, 'dci3')
    name = 'p3dci';
    w_name = 'D65';
else
    warning('Input color space %d cannot recognize! Use default sRGB!', cs_name);
    name = 'srgb';
    w_name = 'D65';
end

param.short_name = name;
param.w_name = w_name;
param.w = colorspace.get_white_point(w_name);
param.rgb = colorspace.get_primaries(name);
if isempty(p.Results.lin)
    param.tsf = colorspace.get_trc(cs_name);
else
    param.tsf = colorspace.get_trc('linear');
end
param.yuv = colorspace.get_ycbcr_coef(cs_name);
end