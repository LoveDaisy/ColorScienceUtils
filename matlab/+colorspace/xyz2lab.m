function lab = xyz2lab(xyz)
% DESCRIPTION
%   Convert XYZ color to Lab color space. Reference white point is D65.
% SYNTAX
%   lab = xyz2lab(xyz)
% INPUT
%   xyz:            n*3 matrix, each row represents a color.
% OUTPUT
%   lab:            n*3 matrix, each row represents a color. L ranges between [0, 1]

p = inputParser;
p.addRequired('xyz', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.parse(xyz);

w = internal.get_white_point('D65');
xyz = xyz ./ w;
lab = zeros(size(xyz));
lab(:, 1) = 1.16 * internal.lab_transfer(xyz(:, 2)) - 0.16;
lab(:, 2) = 5 * (internal.lab_transfer(xyz(:, 1)) - internal.lab_transfer(xyz(:, 2)));
lab(:, 3) = 2 * (internal.lab_transfer(xyz(:, 2)) - internal.lab_transfer(xyz(:, 3)));
end
