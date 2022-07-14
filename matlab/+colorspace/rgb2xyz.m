function xyz = rgb2xyz(rgb, varargin)
% DESCRIPTION
%   Convert RGB data to XYZ data.
% SYNTAX
%   xyz = rgb2xyz(rgb);
%   xyz = rgb2xyz(rgb, cs_name);
%   xyz = rgb2xyz(rgb, param);
% INPUT
%   rgb:            n*3 matrix, each row represents a color.
%   cs_name:        A string for colorspace name. Default is 'sRGB'.
%                   See internal.cs_name_validator for detail.
%   param:          A struct returned from colorspace.get_param.
% OUTPUT
%   xyz:            n*3 matrix for XYZ data.

p = inputParser;
p.addRequired('xyz', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.addOptional('param', 'sRGB', @internal.cs_validator);
p.parse(rgb, varargin{:});

if ischar(p.Results.param)
    param = colorspace.get_param(p.Results.param);
else
    param = p.Result.param;
end

mat = colorspace.xyz_rgb_mat(param);
rgb_lin = colorspace.rgb_ungamma(rgb, param);
xyz = rgb_lin / mat;
end