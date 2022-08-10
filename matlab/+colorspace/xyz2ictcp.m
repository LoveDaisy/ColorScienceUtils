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
p.addRequired('xyz', @colorspace.util.image_shape_validator);
p.parse(xyz);

m2 = colorspace.xyz_lms_mat();          % xyz to lms matrix
m3 = [2048, 2048, 0;
    6610, -13613, 7003;
    17933, -17390, -543]' / 4096;       % lms to ictcp matrix, campatibale for PQ transfer

ictcp = colorspace.util.pq_inverse_eotf(reshape(xyz, [], 3) * m2) * m3;
ictcp = reshape(ictcp, input_size);
end