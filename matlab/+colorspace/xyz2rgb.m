function rgb = xyz2rgb(xyz, varargin)
% DESCRIPTION
%   Convert XYZ color to RGB color.
% SYNTAX
%   rgb = xyz2rgb(xyz);
%   rgb = xyz2rgb(xyz, cs_name);
%   rgb = xyz2rgb(xyz, param);
%   rgb = xyz2rgb(..., method);
% INPUT
%   xyz:            n*3 matrix, each row represents a color of XYZ; or m*n*3 array for 3-channel image.
%   cs_name:        A string for colorspace name. Default is 'sRGB'.
%                   See colorspace.util.cs_name_validator for detail.
%   param:          A struct returned by colorspace.get_param.
%   method:         A string for RGB adjusting method. Default is 'Greying'.
%                   See colorspace.util.rgb_compression_validator for detail.
% OUTPUT
%   rgb:            The same shape to input xyz.

input_size = size(xyz);

p = inputParser;
p.addRequired('xyz', @colorspace.util.image_shape_validator);
p.addOptional('param', 'sRGB', @colorspace.util.cs_param_validator);
p.addOptional('method', 'clip', @colorspace.util.rgb_compression_validator);
p.parse(xyz, varargin{:});

if ischar(p.Results.param)
    param = colorspace.get_param(p.Results.param);
else
    param = p.Results.param;
end

mat = colorspace.xyz_rgb_mat(param);
rgb_lin = reshape(xyz, [], 3) * mat;
rgb_lin = colorspace.util.rgb_compression(rgb_lin, param, p.Results.method, 'Linear', true);
rgb = colorspace.rgb_gamma(rgb_lin, param);
rgb = reshape(rgb, input_size);
end