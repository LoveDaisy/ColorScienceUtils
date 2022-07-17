function ictcp = rgb2ictcp(rgb, varargin)
% DESCRIPTION
%   Convert RGB data to ICtCp data.
% SYNTAX
%   ictcp = rgb2ictcp(rgb);
%   ictcp = rgb2ictcp(rgb, space);
%   ictcp = rgb2ictcp(rgb, param);
%   ictcp = rgb2ictcp(..., Name, Value...);
% INPUT
%   rgb:            n*3 matrix, each row represents a color.
%   space:          A string for RGB colorspace name.
%   param:          A struct returned by colorspace.get_param.
% PARAMETER
%   'Scale':        A scalar indicating illuminance scale in linear space. Default is 100.
%                   Scale = s means white [1, 1, 1] in linear space should be s cd/m^2 in reality.
%   'Linear':       true | false. Default is false.
% OUTPUT
%   ictcp:          n*3 matrix, each row represents a color.

p = inputParser;
p.addRequired('rgb', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.addOptional('param', 'sRGB', @internal.cs_validator);
p.addParameter('Scale', 100, @(x) validateattributes(x, {'numeric'}, {'scalar'}));
p.addParameter('Linear', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
p.parse(rgb, varargin{:});

if ischar(p.Results.param)
    param = colorspace.get_param(p.Results.param);
else
    param = p.Results.param;
end
if ~p.Results.Linear
    rgb_lin = colorspace.rgb_ungamma(rgb, param);
else
    rgb_lin = rgb;
end

m1 = colorspace.xyz_rgb_mat(param);     % xyz to rgb matrix
m2 = colorspace.xyz_lms_mat();          % xyz to lms matrix
m3 = [2048, 2048, 0;
    6610, -13613, 7003;
    17933, -17390, -543]' / 4096;       % lms to ictcp matrix, campatibale for PQ transfer

scale = p.Results.Scale;
ictcp = internal.pq_inverse_eotf(rgb_lin * scale / m1 * m2) * m3;
end