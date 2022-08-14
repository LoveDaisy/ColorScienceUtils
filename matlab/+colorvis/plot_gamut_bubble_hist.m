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
%   rgb:            n*3 array or m*n*3 image.
%   src_space:      A string for input color space, or a struct from colorspace.get_param.
%                   See colorutil.cs_param_validator for detail.
%   ucs:            A string for UCS (uniform color space). One of {'xyY', 'Lab'}
% OPTIONS
%   'ZScale':       'Linear' | 'log'. Default is linear.
%   'Background':   3-element RGB color. Default is [0.1, 0.1, 0.1].
%   'DarkTh':       A scalar. Default is 0.05.

p = inputParser;
p.addRequired('rgb', @colorutil.image_shape_validator);
p.addOptional('src_space', 'sRGB', @colorutil.cs_param_validator);
p.addOptional('ucs', 'Lab', @(x) ischar(x) && (strcmpi(x, 'lab') || strcmpi(x, 'xyy')));
p.addParameter('zscale', 'linear', @(x) strcmpi(x, 'linear') || strcmpi(x, 'log'));
p.addParameter('background', [1, 1, 1]*0.1, @(x) isnumeric(x) && isvector(x) && length(x) == 3);
p.addParameter('DarkTh', 0.05, @(x) isnumeric(x) && isscalar(x));
p.parse(rgb, varargin{:});

zscale_log = strcmpi(p.Results.zscale, 'log');

rgb = reshape(rgb, [], 3);
if strcmpi(p.Results.ucs, 'xyy')
    data = colorspace.rgb2xyz(rgb, p.Results.src_space);
    data = max(data, 1e-6);
    data = [data(:, 1:2) ./ sum(data, 2), data(:, 2)];
    data = data(data(:, 3) > p.Results.DarkTh, :);
    inv_tf = @(x) colorspace.xyz2rgb([x(:, 1:2), 1 - sum(x(:, 1:2), 2)] ./ x(:, 2) .* ...
        (x(:, 3) + 0.015 * max(x(:, 3))) / max(x(:, 3)) * 1.2, 'sRGB');
elseif strcmpi(p.Results.ucs, 'lab')
    data = colorspace.rgb2lab(rgb, p.Results.src_space);
    data = data(:, [2, 3, 1]);
    data = data(data(:, 3) > p.Results.DarkTh, :);
    inv_tf = @(x) colorspace.lab2rgb(x(:, [3, 1, 2]), 'sRGB');
else
    warning('Cannot recogniza ucs! Treat as xyY.');
    data = colorspace.rgb2xyz(rgb, p.Results.src_space);
    data = max(data, 1e-6);
    data = [data(:, 1:2) ./ sum(data, 2), data(:, 2)];
    data = data(data(:, 3) > p.Results.DarkTh, :);
    inv_tf = @(x) colorspace.xyz2rgb([x(:, 1:2), 1 - sum(x(:, 1:2), 2)] ./ x(:, 2) .* ...
        (x(:, 3) + 0.015 * max(x(:, 3))) / max(x(:, 3)) * 1.2, 'sRGB');
end

z_scale = 'linear';
if zscale_log
    data(:, 3) = log(data(:, 3) + 1e-4);
    z_scale = 'log';
end
x_lim = prctile(data(:, 1), [0, 100]);
y_lim = prctile(data(:, 2), [0, 100]);
z_lim = prctile(data(:, 3), [0, 100]);
dxy = min(diff(x_lim), diff(y_lim)) / 50;
dz = diff(z_lim) / 100;

x_grid = x_lim(1):dxy:x_lim(2);
y_grid = y_lim(1):dxy:y_lim(2);
z_grid = z_lim(1):dz:z_lim(2);
grid_size = [length(x_grid) - 1, length(y_grid) - 1, length(z_grid) - 1];

sub = min(max(round((data - [x_lim(1), y_lim(1), z_lim(1)]) ./ [dxy, dxy, dz]) + 1, [1, 1, 1]), grid_size);
ind = sub2ind(grid_size, sub(:, 1), sub(:, 2), sub(:, 3));
cnt = accumarray(ind, 1, [prod(grid_size), 1]);
cnt_idx = cnt > 0;
[bx, by, bz] = ind2sub(grid_size, find(cnt_idx));
bubble_center = ([bx, by, bz] - 0.5) .* [dxy, dxy, dz] + [x_lim(1), y_lim(1), z_lim(1)];
cnt = cnt(cnt_idx);
if zscale_log
    bubble_center(:, 3) = exp(bubble_center(:, 3));
    z_lim = [min(bubble_center(:, 3)) * 0.8, max(bubble_center(:, 3)) * 1.3];
end

s0 = prctile(cnt, 99.5);
bubble_size = min((cnt / s0 + 0.001), 1) * 80;
bubble_color = inv_tf(bubble_center);

next_plot = get(gca, 'NextPlot');

scatter3(bubble_center(:, 1), bubble_center(:, 2), bubble_center(:, 3), ...
    bubble_size, bubble_color, 'Filled');

set(gca, 'NextPlot', next_plot, 'Projection', 'Perspective', ...
    'DataAspectRatio', [1, 1, diff(z_lim) / max(diff(x_lim), diff(y_lim)) * 0.8], ...
    'Color', p.Results.background, 'GridColor', [1, 1, 1] * 0.7, ...
    'zlim', z_lim, 'zscale', z_scale);
end