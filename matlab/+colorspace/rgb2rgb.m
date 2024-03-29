function rgb = rgb2rgb(rgb, varargin)
% DESCRIPTION
%   It converts color from one RGB space to another RGB space.
% SYNTAX
%   rgb = rgb2rgb(rgb)
%   rgb = rgb2rgb(rgb, from)
%   rgb = rgb2rgb(rgb, from, to)
%   rgb = rgb2rgb(rgb, from, to, method)
% INPUT
%   rgb:            n*3 array, each row represents a color in RGB space, range in [0, 1];
%                   or m*n*3 array for 3-channel image.
%   from:           A string for colorspace, or a struct get from colorspace.get_param.
%                   Default is 'sRGB'.
%   to:             A string for colorspace, or a struct get from colorspace.get_param.
%                   Default is 'sRGB'.
%   method:         RGB compression method. See colorspace.rgb_compression for detail.
% OUTPUT
%   rgb:            The same shape to input rgb.

p = inputParser;
p.addRequired('rgb', @colorutil.image_shape_validator);
p.addOptional('from', 'sRGB', @colorutil.cs_param_validator);
p.addOptional('to', 'sRGB', @colorutil.cs_param_validator);
p.addOptional('method', 'clip', @ischar);
p.parse(rgb, varargin{:});

if ischar(p.Results.from)
    from_param = colorspace.get_param(p.Results.from);
else
    from_param = p.Results.from;
end
if ischar(p.Results.to)
    to_param = colorspace.get_param(p.Results.to);
else
    to_param = p.Results.to;
end
if strcmpi(from_param.short_name, to_param.short_name)
    % Source and target colorspace are the same. Then do nothing and return.
    return;
end

xyz = colorspace.rgb2xyz(rgb, from_param);
rgb = colorspace.xyz2rgb(xyz, to_param, p.Results.method);
end