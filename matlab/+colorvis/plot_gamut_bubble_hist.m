function plot_gamut_bubble_hist(rgb, varargin)
% DESCRIPTION
%   It collects color data and plots a 3d buble histogram, in a given uniform color space
%   (such as XYZ, Lab, etc)
% SYNTAX
%   plot_gamut_bubble_hist(rgb)
%   plot_gamut_bubble_hist(rgb, src_space)
%   plot_gamut_bubble_hist(rgb, src_space, ucs)
%   plot_gamut_bubble_hist(..., Name, Value...)
% INPUT
%   rgb:                n*3 array or m*n*3 image.
%   src_space:          A string for input color space, or a struct from colorspace.get_param.
%                       See colorutil.cs_param_validator for detail.
%   ucs:                A string for UCS (uniform color space). One of {'xyY', 'Lab'}
% OPTIONS
%   'ZScale':           'Linear' | 'log'. Default is linear.
%   'Background':       3-element RGB color. Default is [0.23, 0.23, 0.23].
%   'DarkTh':           A scalar. Default is 0. Only luminance greater than prctile(Y, DarkTh) will be counted in.
%   'WhiteTh':          A scalar. Default is 100. Only luminance less than prctile(Y, WhiteTh) will be counted in.
%   'BubbleScale':      A scalar. Default is 1.0.
%   'BubbleDensity':    A scalar, or 2-element vector. Default is 1.0.
%   'BubbleDither':     A scalar, in [0, 1].

p = inputParser;
p.addRequired('rgb', @colorutil.image_shape_validator);
p.addOptional('src_space', 'sRGB', @colorutil.cs_param_validator);
p.addOptional('ucs', 'Lab', @(x) ischar(x) && (strcmpi(x, 'lab') || strcmpi(x, 'xyy') || strcmpi(x, 'luv')));
p.addParameter('zscale', 'linear', @(x) strcmpi(x, 'linear') || strcmpi(x, 'log'));
p.addParameter('background', [1, 1, 1]*0.23, @(x) isnumeric(x) && isvector(x) && length(x) == 3);
p.addParameter('DarkTh', 0, @(x) isnumeric(x) && isscalar(x));
p.addParameter('WhiteTh', 100, @(x) isnumeric(x) && isscalar(x));
p.addParameter('BubbleScale', 1.0, @(x) isnumeric(x) && isscalar(x));
p.addParameter('BubbleDensity', 1.0, @(x) isnumeric(x) && (isscalar(x) || (isvector(x) && length(x) == 2)));
p.addParameter('BubbleDither', 0.0, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x <= 1);
p.parse(rgb, varargin{:});

zscale_log = strcmpi(p.Results.zscale, 'log');

[data, color_func] = convert_data_ucs(rgb, p.Results.src_space, p.Results.ucs, [p.Results.DarkTh, p.Results.WhiteTh]);
[bubble_center, bubble_size, ranges] = colorutil.hist3d(data, p.Results.BubbleScale, ...
    p.Results.BubbleDensity, zscale_log, p.Results.BubbleDither);
bubble_color = color_func(bubble_center);

next_plot = get(gca, 'NextPlot');

scatter3(bubble_center(:, 1), bubble_center(:, 2), bubble_center(:, 3), ...
    bubble_size, bubble_color, 'Filled');

if zscale_log
    z_scale = 'log';
else
    z_scale = 'linear';
end
asp = [1, 1, diff(ranges(3, :)) / max(diff(ranges(1, :)), diff(ranges(2, :))) * 0.8];
cam = [-65, 30, 8 * max(ranges(1:2, 2) - ranges(1:2, 1)) / 2];
cam_pos = [cosd(cam(1)) * cosd(cam(2)), sind(cam(1)) * cosd(cam(2)), sind(cam(2)) * asp(3)] * cam(3) + ...
    [mean(ranges(1, :)), mean(ranges(2, :)), diff(ranges(3, :)) * 0.2 + ranges(3, 1)];
set(gca, 'NextPlot', next_plot, 'Projection', 'Perspective', 'CameraPosition', cam_pos, ...
    'DataAspectRatio', asp, ...
    'Color', p.Results.background, 'GridColor', [1, 1, 1] * 0.7, ...
    'zlim', ranges(3, :), 'zscale', z_scale);
end


function [data, color_func] = convert_data_ucs(rgb, src_space, ucs, range)
rgb = reshape(rgb, [], 3);
if strcmpi(ucs, 'xyy')
    data = colorspace.rgb2xyz(rgb, src_space);
    data = max(data, 1e-6);
    data = [data(:, 1:2) ./ sum(data, 2), data(:, 2)];
    color_func = @xyy_color_func;
elseif strcmpi(ucs, 'lab')
    [data, max_y] = colorspace.rgb2lab(rgb, src_space);
    data = data(:, [2, 3, 1]);
    color_func = @(x) abl_color_func(x, max_y);
elseif strcmpi(ucs, 'luv')
    data = colorspace.rgb2luv(rgb, src_space);
    data = data(:, [2, 3, 1]);
    color_func = @uvl_color_func;
else
    if ischar(ucs)
        error('Cannot recognize ucs: %s', ucs);
    else
        error('Cannot recognize ucs: %s', ucs.short_name);
    end
end
lim = prctile(data(:, 3), range);
data(:, 3) = max(min(data(:, 3), lim(2)), lim(1));
end


function color = xyy_color_func(xyy)
xyz = [xyy(:, 1:2), 1 - sum(xyy(:, 1:2), 2)] ./ xyy(:, 2) .* xyy(:, 3);
if max(xyz(:, 2)) > 1.001
    % HDR color / real scene color. Adjust for better display performance.
    y2 = colorutil.signed_power(xyz(:, 2), 0.45);
    xyz = xyz .* (y2 ./ xyz(:, 2));
end
xyz = xyz / prctile(xyz(:, 2), 99);
color = colorspace.xyz2rgb(xyz, 'sRGB');
end


function color = abl_color_func(abl, max_lum)
lab = abl(:, [3, 1, 2]);
if max_lum > 1.001
    % HDR color / real scene color.
    xyz = colorspace.lab2xyz(lab);
    xyz = xyz * max_lum;
    y2 = min(xyz(:, 2) / prctile(xyz(:, 2), 99), 1.0);
    y2 = colorutil.signed_power(y2, 0.7); % Just for visual comfort
    xyz = xyz .* (y2 ./ xyz(:, 2));
    lab = colorspace.xyz2lab(xyz);
end
color = colorspace.lab2rgb(lab, 'sRGB');
end


function color = uvl_color_func(uvl)
luv = uvl(:, [3, 1, 2]);
max_lum = max(luv(:, 1));
if max_lum > 1.001
    % HDR color / real scene color.
    xyz = colorspace.luv2xyz(luv);
    xyz = xyz * max_lum;
    y2 = min(xyz(:, 2) / prctile(xyz(:, 2), 99), 1.0);
    y2 = colorutil.signed_power(y2, 0.7); % Just for visual comfort
    xyz = xyz .* (y2 ./ xyz(:, 2));
    luv = colorspace.xyz2lab(xyz);
end
color = colorspace.luv2rgb(luv, 'sRGB');
end
