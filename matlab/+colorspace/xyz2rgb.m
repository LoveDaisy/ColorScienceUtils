function rgb = xyz2rgb(xyz, varargin)
% DESCRIPTION
%   Convert XYZ color to RGB color.
% SYNTAX
%   rgb = xyz2rgb(xyz);
%   rgb = xyz2rgb(xyz, cs_name);
%   rgb = xyz2rgb(xyz, param);
%   rgb = xyz2rgb(..., method);
% INPUT
%   xyz:            n*3 matrix, each row represents a color of XYZ.
%   cs_name:        A string for colorspace name. Default is 'sRGB'.
%                   See internal.rgb_name_validator for detail.
%   param:          A struct returned by colorspace.get_param.
%   method:         A string for RGB adjusting method. Default is 'Greying'.
%                   See internal.rgb_compression_validator for detail.

p = inputParser;
p.addRequired('xyz', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.addOptional('param', 'sRGB', @internal.rgb_param_validator);
p.addOptional('method', 'clip', @internal.rgb_compression_validator);
p.parse(xyz, varargin{:});

if ischar(p.Results.param)
    param = colorspace.get_param(p.Results.param);
else
    param = p.Results.param;
end

mat = colorspace.xyz_rgb_mat(param);
rgb_lin = xyz * mat;
rgb_lin = internal.rgb_compression(rgb_lin, param, p.Results.method, 'Linear', true);
rgb = colorspace.rgb_gamma(rgb_lin, param);
end