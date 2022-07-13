function rgb = xyz_to_rgb(xyz, varargin)
% DESCRIPTION
%   Convert XYZ color to RGB color.
% SYNTAX
%   rgb = xyz_to_rgb(xyz);
%   rgb = xyz_to_rgb(xyz, cs_name);
%   rgb = xyz_to_rgb(xyz, param);
%   rgb = xyz_to_rgb(..., method);
% INPUT
%   xyz:            n*3 matrix, each row represents a color of XYZ.
%   cs_name:        A string for colorspace name. Default is 'sRGB'.
%                   See internal.cs_name_validator for detail.
%   param:          A struct returned by internal.get_colorspace_param.
%   method:         A string for RGB adjusting method. Default is 'Greying'.
%                   See internal.rgb_clamping_validator for detail.

p = inputParser;
p.addRequired('xyz', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.addOptional('param', 'sRGB', @internal.cs_validator);
p.addOptional('method', 'clip', @internal.rgb_clamping_validator);
p.parse(xyz, varargin{:});

if ischar(p.Results.param)
    param = internal.get_colorspace_param(p.Results.param);
else
    param = p.Results.param;
end

mat = internal.xyz_rgb_mat(param);
rgb_lin = xyz * mat;
rgb_lin = internal.clamp_rgb(rgb_lin, param, p.Results.method, 'Linear', true);
rgb = colorspace.rgb_gamma(rgb_lin, param);
end