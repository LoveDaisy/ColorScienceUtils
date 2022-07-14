function lms = xyx2lms(xyz)
% DESCRIPTION
%   Convert CIE XYZ data to LMS data. It uses von Kries transformation matrix for D65.
%   See [LMS color space](https://en.wikipedia.org/wiki/LMS_color_space) for detail.
% SYNTAX
%   lms = xyz2lms(xyz)
% INPUT
%   xyz:            n*3 matrix, each row represents a color.
% OUTPUT
%   lms:            n*3 matrix, each row represents a color.

m = [0.4002, 0.7076, -0.0808;
    -0.2263, 1.1653, 0.0457;
    0, 0, 0.9182]';
lms = xyz * m;
end