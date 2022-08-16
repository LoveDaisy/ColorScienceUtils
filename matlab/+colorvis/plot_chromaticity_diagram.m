function plot_chromaticity_diagram(varargin)
% DESCRIPTION
%   Plot the chromaticity diagram.
% SYNTAX
%   plot_chromaticity_diagram();
%   plot_chromaticity_diagram(Name, Value...)
% OPTIONS
%   'XYZData':          n*3 array, or m*n*3 image, xyz data used for 2d histogram.
%   'DarkTh':           A scalar in [0, 1]. Y components less than prctile(Y, DarkTh) will not count in
%                       for histogram. Default is 1, which means Y must be brighter than darkest 1% pixels.
%   'Fill':             true | false. Whether to fill the diagram with (approximate) RGB color.
%                       If XYZData is set, this option will be ignore.
%   'Background':       3-elements RGB value. Default is [0.1, 0.1, 0.1].
%   'LineWidth':        A scalar. Default is 1.2.
%   'Pri':              A string for colorspace name, or a struct of colorspace parameter. See
%                       colorutil.cs_param_validator for detail. Default is empty.
%   'PriColor':         3-elements RGB value. Default is [0.6, 0.6, 0.6]. The color for
%                       primary vertices and boundary.
%   'Lambda':           row vector, the wavelength values. Default is 420:760.

p = inputParser;
p.addParameter('XYZData', [], @colorutil.image_shape_validator);
p.addParameter('DarkTh', 1, @isnumeric);
p.addParameter('Fill', false, @islogical);
p.addParameter('Background', [0.1, 0.1, 0.1], @(x) isnumeric(x) && isvector(x) && length(x) == 3);
p.addParameter('LineWidth', 1.2, @isscalar);
p.addParameter('Pri', [], @colorutil.cs_param_validator);
p.addParameter('PriColor', [0.6, 0.6, 0.6], @(x) isnumeric(x) && isvector(x) && length(x) == 3);
p.addParameter('Lambda', 420:760, @(x) validateattributes(x, {'numeric'}, {'row'}));
p.parse(varargin{:});

nextplot = get(gca, 'NextPlot');
hold on;

if ~isempty(p.Results.XYZData)
    grid = 0.0025;
    plot_xy_hist(p.Results.XYZData, grid, p.Results.Background, p.Results.DarkTh);
end

if isempty(p.Results.XYZData) && p.Results.Fill
    fill_chromaticity(p.Results.Lambda, p.Results.Background);
end

if p.Results.LineWidth > 0 && ~p.Results.Fill
    draw_boundary(p.Results.Lambda, p.Results.LineWidth);
end

if ~isempty(p.Results.Pri)
    show_primaries(p.Results.Pri, p.Results.PriColor);
end

box on;
axis equal; axis tight;
set(gca, 'color', p.Results.Background, 'NextPlot', nextplot, 'xlim', [-0.05, 0.81], 'ylim', [-0.01, 0.91]);
end


function fill_chromaticity(lambda, background)
% DESCRIPTION
%   It fills the diagram with approximate RGB color.

w0 = colorspace.get_white_point('D65');

grid = 0.00025;
img_x = 0:grid:0.8;
img_y = 0:grid:0.9;
img_size = [length(img_y), length(img_x)];

cmf = colorspace.xyz_cmf();
xyz0 = interp1(cmf(:, 1), cmf(:, 2:4), lambda);
xy0 = xyz0(:, 1:2) ./ sum(xyz0, 2);
xy0_int = min(max(floor(xy0 / grid) + 1, 1), wrev(img_size));
mask = poly2mask(xy0_int(:, 1), xy0_int(:, 2), img_size(1), img_size(2));

[xx, yy] = meshgrid(img_x, img_y);

xyz = [xx(:), yy(:), 1 - xx(:) - yy(:)];
alpha = 0.75 ./ (sqrt((xx(:) - w0(1) / sum(w0)).^2 + (yy(:) - w0(2) / sum(w0)).^2) + 0.18);
rgb = colorspace.xyz2rgb(xyz .* alpha);
rgb = reshape(rgb, [img_size, 3]);
img = rgb .* mask + reshape(background, [1, 1, 3]) .* ~mask;

imagesc(img_x, img_y, img);
end


function show_primaries(pri, pri_color)
% DESCRIPTION
%   It shows gamut RGB primaries and white point.

if ischar(pri)
    param = colorspace.get_param(pri);
else
    param = pri;
end
plot([param.rgb(:, 1); param.rgb(1, 1)], [param.rgb(:, 2); param.rgb(1, 2)], '-s', 'color', pri_color);
plot(param.w(:, 1) / sum(param.w), param.w(:, 2) / sum(param.w), 'wo');
end


function draw_boundary(lambda, linewidth)
% DESCRIPTION
%   It draws the boundary of chromaticity diagram

cmf = colorspace.xyz_cmf();
xyz0 = interp1(cmf(:, 1), cmf(:, 2:4), lambda);
xy0 = xyz0(:, 1:2) ./ sum(xyz0, 2);
xy_line = interp1([1; 0], [xy0(end, :); xy0(1, :)], linspace(1, 0, 20));
xy = [xy0; xy_line];
xyz = [xy, 1 - sum(xy, 2)];
xyz = xyz ./ max(xyz(:, 2)) * 1.5;
rgb = colorspace.xyz2rgb(xyz);
for i = 2:size(xy, 1)
    plot(xy(i-1:i, 1), xy(i-1:i, 2), 'color', rgb(i-1, :), 'linewidth', linewidth);
end
end


function plot_xy_hist(xyz, grid, background, dark_th)
% DESCRIPTION
%   Plots 2D histogram of projected xyz data on chromaticity diagram.

xyz = reshape(xyz, [], 3);
valid_idx = xyz(:, 2) > prctile(xyz(:, 2), dark_th);
xyz = max(xyz(valid_idx, :), 1e-8);
xy = xyz(:, 1:2) ./ sum(xyz, 2);

hist_img_x = 0:grid:0.8;
hist_img_y = 0:grid:0.9;
hist_img_size = [length(hist_img_y), length(hist_img_x)];
idx = sub2ind(hist_img_size, ...
    min(max(floor(xy(:, 2) / grid) + 1, 1), hist_img_size(1)), ...
    min(max(floor(xy(:, 1) / grid) + 1, 1), hist_img_size(2)));
cnt = accumarray(idx, 1, [prod(hist_img_size), 1]);
k = (cnt(:) / max(cnt(:)) * 1.2).^(0.8);

[xx, yy] = meshgrid(hist_img_x, hist_img_y);
xy_grid = [xx(:), yy(:)];

xyz = [xy_grid, 1 - sum(xy_grid, 2)] ./ xy_grid(:, 2) .* k * 1.2;
color = max(colorspace.xyz2rgb(xyz), background);
color = reshape(color, [hist_img_size, 3]);

imagesc(hist_img_x, hist_img_y, color);
end
