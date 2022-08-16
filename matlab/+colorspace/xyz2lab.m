function [lab, max_y] = xyz2lab(xyz)
% DESCRIPTION
%   Convert XYZ color to Lab color space. Reference white point is D65.
% SYNTAX
%   lab = xyz2lab(xyz)
% INPUT
%   xyz:            n*3 matrix, each row represents a color; or m*n*3 for 3-channel image.
% OUTPUT
%   lab:            Same shape to input xyz. For normal image, L ranges between [0, 100], and
%                   ab ranges mainly in [-0.5, 0.5].
%   max_y:          A scalar.

input_size = size(xyz);

p = inputParser;
p.addRequired('xyz', @colorutil.image_shape_validator);
p.parse(xyz);

w = colorspace.get_white_point('D65');
xyz = reshape(xyz, [], 3) ./ w;
max_y = max(xyz(:, 2));
if max_y > 1.001
    % HDR case or linear scene light.
    y2 = xyz(:, 2) ./ max_y;
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
