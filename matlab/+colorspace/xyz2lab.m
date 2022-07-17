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
lab(:, 1) = 1.16 * f(xyz(:, 2)) - 0.16;
lab(:, 2) = 5 * (f(xyz(:, 1)) - f(xyz(:, 2)));
lab(:, 3) = 2 * (f(xyz(:, 2)) - f(xyz(:, 3)));
end


function y = f(x)
delta = 6 / 29;
idx = x < delta^3;

y = x;
y(idx) = x(idx) / 3 / delta^2 + 4 / 29;
y(~idx) = nthroot(x(~idx), 3);
end