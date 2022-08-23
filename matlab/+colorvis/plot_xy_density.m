function [img_x, img_y, density, color] = plot_xy_density(data, space, varargin)
% DESCRIPTION
%   Plots 2D density map on (projecting data on x + y + z = 1 plane) chromaticity diagram.
% SYNTAX
%   [img_x, img_y, density, color] = plot_xy_density(data, space)
%   [img_x, img_y, density, color] = plot_xy_density(__, Name, Value...)
% INPUT
%   data:           n*3 array or m*n*3 image. See colorutil.image_shape_validator for detail.
%   space:          A string for colorspace, or a struct return from colorspace.get_param, or 'xyz'.
% OPTIONS
%   'Background':   3-element vector. RGB color. It provides a reference, that all density color
%                   darker than this will be set to this color. Default is [0, 0, 0].
%   'DarkTh':       A scalar. The percentage of darkest pixels to be ignored.
%                   It should be in [0, 100]. Default is 0.
%   'GridDensity':  A scalar. The greater the grids are denser. Default is 1.
%   'Smoothness':   A scalar. The greater the density map is smoother. It should be in [0, 1]. Default is 0.

p = inputParser;
p.addRequired('data', @colorutil.image_shape_validator);
p.addRequired('space', @(x) colorutil.cs_param_validator(x) || strcmpi(x, 'xyz'));
p.addParameter('Background', [0, 0, 0], @(x) isnumeric(x) && isvector(x) && length(x) == 3 && ...
    all(0 <= x) && all(x <= 1));
p.addParameter('DarkTh', 0, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x <= 100);
p.addParameter('GridDensity', 1, @(x) isnumeric(x) && isscalar(x));
p.addParameter('Smoothness', 0, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x <= 1);
p.parse(data, space, varargin{:});

data = reshape(data, [], 3);
if ~ischar(space) || ~strcmpi(space, 'xyz')
    dither = randn(size(data)) * 2e-3 * p.Results.Smoothness;
    idx = min(dither + data, [], 2) < 0 | max(dither + data, [], 2) > 1;
    dither(idx, :) = 0;
    data = data + dither;
    xyz = colorspace.rgb2xyz(data, space);
else
    xyz = data;
end
valid_idx = xyz(:, 2) > prctile(xyz(:, 2), p.Results.DarkTh);
xyz = max(xyz(valid_idx, :), 1e-8);
xy = xyz(:, 1:2) ./ sum(xyz, 2);

grid = .0025 / p.Results.GridDensity;
img_x = 0:grid:0.8;
img_y = 0:grid:0.9;

hist_img_size = [length(img_y), length(img_x)];
idx = sub2ind(hist_img_size, ...
    min(max(floor(xy(:, 2) / grid) + 1, 1), hist_img_size(1)), ...
    min(max(floor(xy(:, 1) / grid) + 1, 1), hist_img_size(2)));
cnt = accumarray(idx, 1, [prod(hist_img_size), 1]);
k = (cnt(:) / max(cnt(:)) * 1.2).^(0.6);        % Just for visual comfort
density = reshape(cnt / sum(cnt(:)), hist_img_size);

[xx, yy] = meshgrid(img_x, img_y);
xy_grid = [xx(:), yy(:)];

xyz = [xy_grid, 1 - sum(xy_grid, 2)] ./ xy_grid(:, 2) .* k * 1.2;
color = max(colorspace.xyz2rgb(xyz), p.Results.Background);
color = reshape(color, [hist_img_size, 3]);

if nargout == 0
    imagesc(img_x, img_y, color);
end
end
