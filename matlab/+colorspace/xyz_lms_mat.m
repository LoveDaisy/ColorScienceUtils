function m = xyz_lms_mat()
% DESCRIPTION
%   It returns the matrix used when converting CIE XYZ data to LMS data.
%   It uses von Kries transformation matrix for D65.
%   See [LMS color space](https://en.wikipedia.org/wiki/LMS_color_space) for detail.
% SYNTAX
%   m = xyz_lms_mat()
% INPUT
%
% OUTPUT
%   m:              3*3 matrix. lms = xyz * m.

m = [0.4002, 0.7076, -0.0808;
    -0.2263, 1.1653, 0.0457;
    0, 0, 0.9182]';
end