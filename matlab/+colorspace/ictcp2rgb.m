function rgb = ictcp2rgb(ictcp, varargin)
% DESCRIPTION
%   Convert ICtCp data to RGB data.
% SYNTAX
%   rgb = ictcp2rgb(ictcp);
%   rgb = ictcp2rgb(ictcp, space);
%   rgb = ictcp2rgb(ictcp, param);
%   rgb = ictcp2rgb(..., Name, Value...);
% INPUT
%   ictcp:          n*3 matrix, each row represents a color; or m*n*3 for 3-channel image.
%   space:          A string for RGB colorspace name. Default is 'sRGB'.
%   param:          A struct returned by colorspace.get_param.
% PARAMETER
%   'Scale':        A scalar indicating illuminance scale in linear space. Default is 100.
%                   Scale = s means white [1, 1, 1] in linear space should be s cd/m^2 in reality.
%   'Linear':       true | false. Default is false.
% OUTPUT
%   rgb:            The same shape to input ictcp.

p = inputParser;
p.addRequired('ictcp', @colorutil.image_shape_validator);
p.addOptional('param', 'sRGB', @colorutil.cs_param_validator);
p.addParameter('Scale', 100, @(x) validateattributes(x, {'numeric'}, {'scalar'}));
p.addParameter('Linear', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
p.parse(ictcp, varargin{:});

if ischar(p.Results.param)
    param = colorspace.get_param(p.Results.param);
else
    param = p.Results.param;
end
if p.Results.Linear
    param.tsf = [0, 0, 1 0];
end

scale = p.Results.Scale;
xyz = colorspace.ictcp2xyz(ictcp);
rgb = colorspace.xyz2rgb(xyz / scale, param);
end