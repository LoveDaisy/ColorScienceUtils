function xyz = ictcp2xyz(ictcp)
% DESCRIPTION
%   Convert ICtCp data to XYZ colorspace.
% SYNTAX
%   xyz = ictcp2xyz(ictcp);
% INPUT
%   ictcp:          n*3 matrix, each row represents a color; or m*n*3 for 3-channel image.
% OUTPUT
%   xyz:            The same shape to input ictcp.

input_size = size(ictcp);

p = inputParser;
p.addRequired('ictcp', @colorutil.image_shape_validator);
p.parse(ictcp);

m2 = colorspace.xyz_lms_mat();          % xyz to lms matrix
m3 = [2048, 2048, 0;
    6610, -13613, 7003;
    17933, -17390, -543]' / 4096;       % lms to ictcp matrix, campatibale for PQ transfer

xyz = colorspace.pq_eotf(reshape(ictcp, [], 3) / m3) / m2;
xyz = reshape(xyz, input_size);
end