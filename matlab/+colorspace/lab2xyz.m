function xyz = lab2xyz(lab)
% DESCRIPTION
%   Convert Lab color to XYZ color space. Reference white point is D65.
% SYNTAX
%   xyz = lab2xyz(lab)
% INPUT
%   lab:            n*3 matrix, each row represents a color; or m*n*3 array for 3-channel image.
%                   L ranges between [0, 1]
% OUTPUT
%   xyz:            The same shape to input lab.

input_size = size(lab);

p = inputParser;
p.addRequired('lab', @colorspace.util.image_shape_validator);
p.parse(lab);

w = colorspace.util.get_white_point('D65');
lab = reshape(lab, [], 3) ./ [1.16, 5/5.12, 2/5.12];
xyz = zeros(size(lab));
xyz(:, 1) = w(1) * colorspace.util.lab_inverse_transfer(lab(:, 1) + 0.16 / 1.16 + lab(:, 2));
xyz(:, 2) = w(2) * colorspace.util.lab_inverse_transfer(lab(:, 1) + 0.16 / 1.16);
xyz(:, 3) = w(3) * colorspace.util.lab_inverse_transfer(lab(:, 1) + 0.16 / 1.16 - lab(:, 3));
xyz = reshape(xyz, input_size);
end
