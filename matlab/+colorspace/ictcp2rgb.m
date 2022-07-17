function rgb = ictcp2rgb(ictcp, varargin)
% DESCRIPTION
%   Convert ICtCp data to RGB data.
% SYNTAX
%   rgb = ictcp2rgb(ictcp);
%   rgb = ictcp2rgb(ictcp, space);
%   rgb = ictcp2rgb(ictcp, param);
%   rgb = ictcp2rgb(..., Name, Value...);
% INPUT
%   rgb:            n*3 matrix, each row represents a color.
%   space:          A string for RGB colorspace name. Default is 'sRGB'.
%   param:          A struct returned by colorspace.get_param.
% PARAMETER
%   'Scale':        A scalar indicating illuminance scale in linear space. Default is 100.
%                   Scale = s means white [1, 1, 1] in linear space should be s cd/m^2 in reality.
%   'Linear':       true | false. Default is false.
% OUTPUT
%   rgb:            n*3 matrix, each row represents a color.

p = inputParser;
p.addRequired('ictcp', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.addOptional('param', 'sRGB', @internal.cs_validator);
p.addParameter('Scale', 100, @(x) validateattributes(x, {'numeric'}, {'scalar'}));
p.addParameter('Linear', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
p.parse(ictcp, varargin{:});

if ischar(p.Results.param)
    param = colorspace.get_param(p.Results.param);
else
    param = p.Results.param;
end

m1 = colorspace.xyz_rgb_mat(param);     % xyz to rgb matrix
m2 = colorspace.xyz_lms_mat();          % xyz to lms matrix
m3 = [2048, 2048, 0;
    6610, -13613, 7003;
    17933, -17390, -543]' / 4096;       % lms to ictcp matrix, campatibale for PQ transfer

scale = p.Results.Scale;
rgb_lin = internal.pq_eotf(ictcp / m3) / m2 * m1 / scale;
if ~p.Results.Linear
    rgb = colorspace.rgb_gamma(rgb_lin, param);
else
    rgb = rgb_lin;
end
end