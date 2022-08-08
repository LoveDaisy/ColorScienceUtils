function ictcp = xyz2ictcp(xyz)
% DESCRIPTION
%   Convert XYZ data to ICtCp colorspace.
% SYNTAX
%   ictcp = xyz2ictcp(xyz);
% INPUT
%   xyz:            n*3 matrix, each row represents a color.
% OUTPUT
%   ictcp:          n*3 matrix, each row represents a color.

p = inputParser;
p.addRequired('xyz', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.parse(xyz);

m2 = colorspace.xyz_lms_mat();          % xyz to lms matrix
m3 = [2048, 2048, 0;
    6610, -13613, 7003;
    17933, -17390, -543]' / 4096;       % lms to ictcp matrix, campatibale for PQ transfer

ictcp = colorspace.util.pq_inverse_eotf(xyz * m2) * m3;
end