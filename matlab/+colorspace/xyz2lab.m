function [lab, max_y] = xyz2lab(xyz, varargin)
% DESCRIPTION
%   Convert XYZ color to Lab color space. Reference white point is D65.
% SYNTAX
%   lab = xyz2lab(xyz)
%   lab = xyz2lab(xyz, high_cut)
% INPUT
%   xyz:            n*3 matrix, each row represents a color; or m*n*3 for 3-channel image.
%   high_cut:       A scalar. For HDR image, y compnent may be greater than 1.0, and often the max
%                   luminance is extremely high (say, a specular highlight). We can cut off
%                   some extreme values higher than high_cut to keep better representation for
%                   major colors. It is in percent. Default is 100.
% OUTPUT
%   lab:            Same shape to input xyz. For normal image, L ranges between [0, 100], and
%                   ab ranges mainly in [-0.5, 0.5].
%   max_y:          A scalar.

input_size = size(xyz);

p = inputParser;
p.addRequired('xyz', @colorutil.image_shape_validator);
p.addOptional('high', 100, @isnumeric);
p.parse(xyz);

w = colorspace.get_white_point('D65');
xyz = reshape(xyz, [], 3) ./ w;
max_y = max(xyz(:, 2));
if max_y > 1.001
    % HDR/linear scene light.
    max_y = prctile(xyz(:, 2), p.Results.high);
    y2 = min(xyz(:, 2) ./ max_y, 1.0);  % extreme values are cut to prctile(y, high)
    xyz = xyz .* (y2 ./ xyz(:, 2));
else
    % SDR image. Y ranges in [0, 1]
    max_y = 1.0;
end
f_xyz = colorspace.lab_transfer(xyz);

lab = zeros(size(xyz));
lab(:, 1) = 116 * f_xyz(:, 2) - 16;
lab(:, 2) = 500 * (f_xyz(:, 1) - f_xyz(:, 2));
lab(:, 3) = 200 * (f_xyz(:, 2) - f_xyz(:, 3));
lab = reshape(lab, input_size);
end
