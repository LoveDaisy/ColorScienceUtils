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
%   ucs:            A string for UCS (uniform color space). One of {'XYZ', 'Lab'}
% OPTIONS
%   'Boundary':     true | false. Default is true.

p = inputParser;
p.addRequired('rgb', @colorutil.image_shape_validator);
p.addOptional('src_space', 'sRGB', @colorutil.cs_param_validator);
p.addOptional('ucs', 'Lab', @(x) ischar(x) && (strcmpi(x, 'lab') || strcmpi(x, 'xyz') || ...
    strcmpi(x, 'xyy')));
p.addParameter('boundary', true, @(x) islogical(x) && isscalar(x));
p.parse(rgb, varargin{:});

rgb = reshape(rgb, [], 3);
if strcmpi(p.Results.ucs, 'xyz')
    data = colorspace.rgb2xyz(rgb, p.Results.src_space);
    data = data(:, [3, 1, 2]);
    inv_tf = @(x) colorspace.xyz2rgb(x(:, [2, 3, 1]), 'sRGB');
elseif strcmpi(p.Results.ucs, 'xyy')
    data = colorspace.rgb2xyz(rgb, p.Results.src_space);
    data = max(data, 1e-9);
    data = [data(:, 1:2) ./ sum(data, 2), data(:, 2)];
    inv_tf = @(x) colorspace.xyz2rgb([x(:, 1:2), 1 - sum(x(:, 1:2), 2)] ./ x(:, 2) .* x(:, 3), 'sRGB');
elseif strcmpi(p.Results.ucs, 'lab')
    data = colorspace.rgb2lab(rgb, p.Results.src_space);
    data = data(:, [2, 3, 1]);
    inv_tf = @(x) colorspace.lab2rgb(x(:, [3, 1, 2]), 'sRGB');
else
    warning('Cannot recogniza ucs! Treat as XYZ.');
    data = colorspace.rgb2xyz(rgb, p.Results.src_space);
    data = data(:, [3, 1, 2]);
    inv_tf = @(x) colorspace.xyz2rgb(x(:, [2, 3, 1]), 'sRGB');
end

z_lim = prctile(data(:, 3), [0, 100]);
xy_lim = prctile([data(:, 1); data(:, 2)], [0, 100]);

dxy = diff(xy_lim) / 100;
dz = diff(z_lim) / 50;

x_grid = xy_lim(1):dxy:xy_lim(2);
y_grid = xy_lim(1):dxy:xy_lim(2);
z_grid = z_lim(1):dz:z_lim(2);
grid_size = [length(x_grid), length(y_grid), length(z_grid)];

sub = min(max(round(data ./ [dxy, dxy, dz]) + 1, [1, 1, 1]), grid_size);
ind = sub2ind(grid_size, sub(:, 1), sub(:, 2), sub(:, 3));
cnt = accumarray(ind, 1, [prod(grid_size), 1]);
cnt_idx = cnt > 0;
[bx, by, bz] = ind2sub(grid_size, find(cnt_idx));
bubble_center = [bx, by, bz] .* [dxy, dxy, dz];
cnt = cnt(cnt_idx);
bubble_size = (cnt / max(cnt)) * 150;
bubble_color = inv_tf(bubble_center ./ [1, 1, max(z_lim(2), 1)]);

next_plot = get(gca, 'NextPlot');

scatter3(bubble_center(:, 1), bubble_center(:, 2), bubble_center(:, 3), ...
    bubble_size, bubble_color, 'Filled');

set(gca, 'NextPlot', next_plot, 'DataAspectRatio', [1, 1, diff(z_lim) / diff(xy_lim) * 1.2], ...
    'Projection', 'Perspective');
end