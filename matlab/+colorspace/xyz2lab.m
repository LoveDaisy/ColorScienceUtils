function lab = xyz2lab(xyz)
% DESCRIPTION
%   Convert XYZ color to Lab color space. Reference white point is D65.
% SYNTAX
%   lab = xyz2lab(xyz)
% INPUT
%   xyz:            n*3 matrix, each row represents a color; or m*n*3 for 3-channel image.
% OUTPUT
%   lab:            Same shape to input xyz. L ranges between [0, 1]

input_size = size(xyz);

p = inputParser;
p.addRequired('xyz', @(x) isnumeric(x) && ((length(size(x)) == 2 && size(x, 2) == 3) || ...
  (length(size(x)) == 3 && size(x, 3) == 3)));
p.parse(xyz);

w = colorspace.util.get_white_point('D65');
xyz = reshape(xyz, [], 3) ./ w;
lab = zeros(size(xyz));
lab(:, 1) = 1.16 * colorspace.util.lab_transfer(xyz(:, 2)) - 0.16;
lab(:, 2) = 5 * (colorspace.util.lab_transfer(xyz(:, 1)) - colorspace.util.lab_transfer(xyz(:, 2))) / 5.12;
lab(:, 3) = 2 * (colorspace.util.lab_transfer(xyz(:, 2)) - colorspace.util.lab_transfer(xyz(:, 3))) / 5.12;
lab = reshape(lab, input_size);
end
