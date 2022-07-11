function m = xyz2rgb_mat(space)
% INPUT
%   space:      The colorspace name. See internal.colorspace_validator for detail.
% OUTPUT
%   m:              3*3 matrix. rgb_linear = xyz * m, where rgb and xyz
%                   are all n*3 matrix, and each row represents a color.

p = inputParser;
p.addRequired('space', @internal.colorspace_validator);
p.parse(space);

pram = get_colorspace_param(space);

XYZ = [pram.rgb(:, 1) ./ pram.rgb(:, 2), ones(3, 1), (1 - sum(pram.rgb, 2)) ./ pram.rgb(:, 2)];
S = pram.w / XYZ;
m = inv(diag(S) * XYZ);
end