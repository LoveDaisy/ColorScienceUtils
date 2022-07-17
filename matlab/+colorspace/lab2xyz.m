function xyz = lab2xyz(lab)
% DESCRIPTION
%   Convert Lab color to XYZ color space. Reference white point is D65.
% SYNTAX
%   xyz = lab2xyz(lab)
% INPUT
%   lab:            n*3 matrix, each row represents a color. L ranges between [0, 1]
% OUTPUT
%   xyz:            n*3 matrix, each row represents a color.

p = inputParser;
p.addRequired('lab', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.parse(lab);

w = internal.get_white_point('D65');
lab = lab ./ [1.16, 5, 2];
xyz = zeros(size(lab));
xyz(:, 1) = w(1) * internal.lab_inverse_transfer(lab(:, 1) + 0.16 / 1.16 + lab(:, 2));
xyz(:, 2) = w(2) * internal.lab_inverse_transfer(lab(:, 1) + 0.16 / 1.16);
xyz(:, 3) = w(3) * internal.lab_inverse_transfer(lab(:, 1) + 0.16 / 1.16 - lab(:, 3));
end
