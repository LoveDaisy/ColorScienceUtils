function xyz = rgb2xyz(rgb, varargin)
% DESCRIPTION
%   Convert RGB data to XYZ data.
% SYNTAX
%   xyz = rgb2xyz(rgb);
%   xyz = rgb2xyz(rgb, cs_name);
%   xyz = rgb2xyz(rgb, param);
% INPUT
%   rgb:            n*3 matrix, each row represents a color; or m*n*3 array for 3-channel image.
%   cs_name:        A string for colorspace name. Default is 'sRGB'.
%                   See colorspace.util.cs_name_validator for detail.
%   param:          A struct returned from colorspace.get_param.
% OUTPUT
%   xyz:            The same shape to input rgb.

input_size = size(rgb);

p = inputParser;
p.addRequired('xyz', @(x) isnumeric(x) && ((length(size(x)) == 2 && size(x, 2) == 3) || ...
    (length(size(x)) == 3 && size(x, 3) == 3)));
p.addOptional('param', 'sRGB', @colorspace.util.cs_param_validator);
p.parse(rgb, varargin{:});

if ischar(p.Results.param)
    param = colorspace.get_param(p.Results.param);
else
    param = p.Results.param;
end

mat = colorspace.xyz_rgb_mat(param);
rgb_lin = colorspace.rgb_ungamma(rgb, param);
xyz = reshape(rgb_lin, [], 3) / mat;
xyz = reshape(xyz, input_size);
end