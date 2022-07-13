function xyz = rgb_to_xyz(rgb, varargin)
% DESCRIPTION
%   Convert RGB data to XYZ data.
% SYNTAX
%   xyz = rgb_to_xyz(rgb);
%   xyz = rgb_to_xyz(rgb, cs_name);
%   xyz = rgb_to_xyz(rgb, param);
% INPUT
%   rgb:            n*3 matrix, each row represents a color.
%   cs_name:        A string for colorspace name. Default is 'sRGB'.
%                   See internal.cs_name_validator for detail.
%   param:          A struct returned from internal.get_colorspace_param.
% OUTPUT
%   xyz:            n*3 matrix for XYZ data.

p = inputParser;
p.addRequired('xyz', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.addOptional('param', 'sRGB', @internal.cs_validator);
p.parse(rgb, varargin{:});

if ischar(p.Results.param)
    param = internal.get_colorspace_param(p.Results.param);
else
    param = p.Result.param;
end

mat = internal.xyz_rgb_mat(param);
rgb_lin = rgb_ungamma(rgb, param);
xyz = rgb_lin / mat;
end