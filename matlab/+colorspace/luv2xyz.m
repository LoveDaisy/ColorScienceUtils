function xyz = luv2xyz(luv)
% DESCRIPTION
%   It converts CIE Luv data to XYZ data.
% SYNTAX
%   xyz = luv2xyz(luv);
% INPUT
%   luv:            n*3 array or m*n*3 image.
% OUTPUT
%   xyz:            The same shape to input luv.

p = inputParser;
p.addRequired('luv', @colorutil.image_shape_validator);
p.parse(luv);

w = colorspace.get_white_point('D65');
uv_n = (w * [4, 0; 0, 9; 0, 0]) / (w * [1; 15; 3]);

input_size = size(luv);
luv = reshape(luv, [], 3);
uv = luv(:, 2:3) ./ luv(:, 1) / 13 + uv_n;

xyz = zeros(size(luv));
idx = luv(:, 1) <= 8;
xyz(idx, 2) = w(2) * luv(idx, 1) * (3 / 29)^3;
xyz(~idx, 2) = w(2) * ((luv(~idx, 1) + 16) / 116).^3;
xyz(:, 1) = xyz(:, 2) .* uv(:, 1) ./ uv(:, 2) * 9 / 4;
xyz(:, 3) = xyz(:, 2) .* (12 - uv * [3; 20]) ./ uv(:, 2) / 4;

xyz = reshape(xyz, input_size);
end