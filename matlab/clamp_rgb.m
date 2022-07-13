function rgb = clamp_rgb(rgb, varargin)
% DESCRIPTION
%   If input rgb data is out of range [0, 1], then adjust it back within range,
%   and try to keep it perceptively the same.
% SYNTAX
%   rgb = clamp_rgb(rgb);
%   rgb = clamp_rgb(rgb, cs_name);
%   rgb = clamp_rgb(rgb, param);
%   rgb = clamp_rgb(..., method);
% INPUT
%   rgb:                n*3 matrix. Each row represents a color.
%   cs_name:            A string for colorspace name. Default is 'sRGB'.
%                       See internal.cs_name_validator for detail.
%   param:              A struct returned by internal.get_colorspace_param.
%   method:             Method used for adjustment. One of 'Clip', 'Greying', 'MinDeltaE'.
%                       Default is 'Greying'.

p = inputParser;
p.addRequired('rgb', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.addOptional('param', 'sRGB', @internal.cs_validator);
p.addOptional('method', 'Greying', @internal.rgb_clamping_validator);
p.parse(rgb, varargin{:});

if ischar(p.Results.param)
    param = internal.get_colorspace_param(p.Results.param);
else
    param = p.Results.param;
end

switch lower(p.Results.method)
    case 'clip'
        rgb = clip(rgb);
    case 'desat'
        rgb = desat(rgb);
    case 'greying'
        rgb = greying(rgb, param);
    case 'mindeltae'
        rgb = mindeltae(rgb);
    otherwise
        warning('Cannot recognize method! Use clip as default!');
        rgb = clip(rgb);
end
end


function rgb = clip(rgb)
% Clip method
rgb = min(max(rgb, 0), 1);
end


function rgb = desat(rgb)
% De-saturating method
gray = rgb2gray(rgb);

a0 = -gray ./ (rgb - gray);
a1 = (1 - gray) ./ (rgb - gray);
a0(a0 < 0) = inf;
a1(a1 < 0) = inf;

a = min(min(a0, [], 2), min(a1, [], 2));
rgb = a .* rgb + (1 - a) .* gray;
end


function rgb = greying(rgb, param)
% Greying method
xyz = rgb_to_xyz(rgb, param);
greys = xyz(:, 2) * param.w;
end