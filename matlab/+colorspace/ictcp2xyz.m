function xyz = ictcp2xyz(ictcp)
% DESCRIPTION
%   Convert ICtCp data to XYZ colorspace.
% SYNTAX
%   xyz = ictcp2xyz(ictcp);
% INPUT
%   ictcp:          n*3 matrix, each row represents a color.
% OUTPUT
%   ictcp:          n*3 matrix, each row represents a color.

p = inputParser;
p.addRequired('ictcp', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.parse(ictcp);

m2 = colorspace.xyz_lms_mat();          % xyz to lms matrix
m3 = [2048, 2048, 0;
    6610, -13613, 7003;
    17933, -17390, -543]' / 4096;       % lms to ictcp matrix, campatibale for PQ transfer

xyz = colorspace.util.pq_eotf(ictcp / m3) / m2;
end