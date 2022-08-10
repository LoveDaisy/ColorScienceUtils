function ictcp = xyz2ictcp(xyz)
% DESCRIPTION
%   Convert XYZ data to ICtCp colorspace.
% SYNTAX
%   ictcp = xyz2ictcp(xyz);
% INPUT
%   xyz:            n*3 matrix, each row represents a color; or m*n*3 for 3-channel image.
% OUTPUT
%   ictcp:          The same shape to input xyz.

input_size = size(xyz);

p = inputParser;
p.addRequired('xyz', @(x) isnumeric(x) && ((length(size(x)) == 2 && size(x, 2) == 3) || ...
    (length(size(x)) == 3 && size(x, 3) == 3)));
p.parse(xyz);

m2 = colorspace.xyz_lms_mat();          % xyz to lms matrix
m3 = [2048, 2048, 0;
    6610, -13613, 7003;
    17933, -17390, -543]' / 4096;       % lms to ictcp matrix, campatibale for PQ transfer

ictcp = colorspace.util.pq_inverse_eotf(reshape(xyz, [], 3) * m2) * m3;
ictcp = reshape(ictcp, input_size);
end