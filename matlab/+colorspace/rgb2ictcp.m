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
p.addOptional('param', 'sRGB', @colorspace.util.cs_param_validator);
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
    param.tsf = [0, 0. 1, 0];
else
    rgb_lin = rgb;
end

scale = p.Results.Scale;
xyz = colorspace.rgb2xyz(rgb_lin * scale, param);
ictcp = colorspace.xyz2ictcp(xyz);
end