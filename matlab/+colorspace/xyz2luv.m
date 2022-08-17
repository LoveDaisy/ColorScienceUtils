function luv = xyz2luv(xyz)
% DESCRIPTION
%   It converts XYZ data to CIE Luv. See [wiki page](https://en.wikipedia.org/wiki/CIELUV)
%   for detail.
% SYNTAX
%   luv = xyz2luv(xyz);
% INPUT
%   xyz:            n*3 array or m*n*3 image.
% OUTPUT
%   luv:            The same shape to input xyz.

p = inputParser;
p.addRequired('xyz', @colorutil.image_shape_validator);
p.parse(xyz);

input_size = size(xyz);
xyz = reshape(xyz, [], 3);
w = colorspace.get_white_point('D65');
uv = (xyz * [4, 0; 0, 9; 0, 0]) ./ (xyz * [1; 15; 3]);
uv_n = (w * [4, 0; 0, 9; 0, 0]) / (w * [1; 15; 3]);

L = xyz(:, 2);
idx = xyz(:, 2) / w(2) < (6 / 29)^3;
L(idx) = (29 / 3)^3 * xyz(idx, 2) / w(2);
L(~idx) = 116 * nthroot(xyz(~idx, 2) / w(2), 3) - 16;

uv = 13 * L .* (uv - uv_n);
luv = [L, uv];
luv = reshape(luv, input_size);
end
