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
p.addRequired('lab', @colorutil.image_shape_validator);
p.parse(lab);

w = colorspace.get_white_point('D65');
lab = reshape(lab, [], 3) ./ [116, 500, 200];
xyz = zeros(size(lab));
xyz(:, 1) = w(1) * colorspace.lab_inverse_transfer(lab(:, 1) + 16 / 116 + lab(:, 2));
xyz(:, 2) = w(2) * colorspace.lab_inverse_transfer(lab(:, 1) + 16 / 116);
xyz(:, 3) = w(3) * colorspace.lab_inverse_transfer(lab(:, 1) + 16 / 116 - lab(:, 3));
xyz = reshape(xyz, input_size);
end
