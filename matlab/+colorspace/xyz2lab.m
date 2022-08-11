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
p.addRequired('xyz', @colorutil.image_shape_validator);
p.parse(xyz);

w = colorspace.get_white_point('D65');
xyz = reshape(xyz, [], 3) ./ w;
lab = zeros(size(xyz));
lab(:, 1) = 1.16 * colorspace.lab_transfer(xyz(:, 2)) - 0.16;
lab(:, 2) = 5 * (colorspace.lab_transfer(xyz(:, 1)) - colorspace.lab_transfer(xyz(:, 2))) / 5.12;
lab(:, 3) = 2 * (colorspace.lab_transfer(xyz(:, 2)) - colorspace.lab_transfer(xyz(:, 3))) / 5.12;
lab = reshape(lab, input_size);
end
