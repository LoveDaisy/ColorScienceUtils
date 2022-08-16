function xyY = rgb2xyY(rgb, varargin)
% DESCRIPTION
%   It converts rgb data to xyY data.
% SYNTAX
%   xyY = rgb2xyY(rgb);
%   xyY = rgb2xyY(rgb, cs_name);
%   xyY = rgb2xyY(rgb, param);
% INPUT
%   rgb:            n*3 matrix, each row represents a color; or m*n*3 array for 3-channel image.
%   cs_name:        A string for colorspace name. Default is 'sRGB'.
%                   See colorutil.cs_name_validator for detail.
%   param:          A struct returned from colorspace.get_param.
% OUTPUT
%   xyY:            The same shape to input rgb.

input_size = size(rgb);
xyz = colorspace.rgb2xyz(rgb, varargin{:});
xyz = reshape(xyz, [], 3);
xyY = [xyz(:, 1:2) ./ sum(xyz, 2), xyz(:, 2)];
xyY = reshape(xyY, input_size);
end