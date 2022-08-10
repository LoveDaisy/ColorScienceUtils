function plot_chromaticity_diagram(varargin)
% DESCRIPTION
%   Plot the chromaticity diagram.
% SYNTAX
%   plot_chromaticity_diagram();
%   plot_chromaticity_diagram(Name, Value...)
% OPTIONS
%   'xy':               n*2 array.
%   'fill':             true | false. Whether to fill the diagram with (approximate) RGB color.
%                       If xy is set, this option will be ignore.
%   'color':            'real' | 3-elements RGB value. Default is 'real'.
%   'background':       3-elements RGB value. Default is [0.1, 0.1, 0.1].
%   'linewidth':        A scalar. Default is 1.2.
%   'primaries':        A string for colorspace name, or a struct of colorspace parameter. See
%                       colorspace.util.cs_param_validator for detail. Default is empty.
%   'pri_color':        3-elements RGB value. Default is [0.6, 0.6, 0.6]. The color for
%                       primary vertices and boundary.
%   'lambda':           row vector, the wavelength values. Default is 400:760.

p = inputParser;
p.addParameter('lambda', 400:760, @(x) validateattributes(x, {'numeric'}, {'row'}));
p.addParameter('color', 'real', @(x) ischar(x) && strcmpi(x, 'real') || ...
    isnumeric(x) && isvector(x) && length(x) == 3);
p.addParameter('background', [0.1, 0.1, 0.1], @(x) isnumeric(x) && isvector(x) && length(x) == 3);
p.addParameter('linewidth', 1.2, @isscalar);
p.addParameter('primaries', [], @colorspace.util.cs_param_validator);
p.addParameter('pri_color', [0.6, 0.6, 0.6], @(x) isnumeric(x) && isvector(x) && length(x) == 3);
p.addParameter('xy', [], @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 2}));
p.addParameter('fill', false, @islogical);
p.parse(varargin{:});

nextplot = get(gca, 'NextPlot');
hold on;

if ~isempty(p.Results.xy)
    grid = 0.0025;
    plot_xy_hist(p.Results.xy, grid, p.Results.background);
end

if isempty(p.Results.xy) && p.Results.fill
    % Fill the diagram
    fill_chromaticity(p.Results.background);
end

if p.Results.linewidth > 0
    draw_boundary(p.Resultss.lambda, p.Results.color, p.Results.linewidth);
end

if ~isempty(p.Results.primaries)
    show_primaries(p.Results.primaries, p.Results.pri_color);
end

set(gca, 'color', p.Results.background, 'NextPlot', nextplot);
end


function fill_chromaticity(background)
% DESCRIPTION
%   It fills the diagram with approximate RGB color.

w0 = colorspace.util.get_white_point('D65');

grid = 0.0005;
img_x = 0:grid:0.8;
img_y = 0:grid:0.9;
img_size = [length(img_y), length(img_x)];

cmf = colorspace.util.xyz_cmf();
xy0 = cmf(:, 2:3) ./ sum(cmf(:, 2:4), 2);
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


function draw_boundary(lambda, color, linewidth)
% DESCRIPTION
%   It draws the boundary of chromaticity diagram

cmf = colorspace.util.xyz_cmf();
xyz0 = interp1(cmf(:, 1), cmf(:, 2:4), lambda);
xy0 = xyz0(:, 1:2) ./ sum(xyz0, 2);
xy_line = interp1([1; 0], [xy0(end, :); xy0(1, :)], linspace(1, 0, 20));
xy = [xy0; xy_line];
xyz = [xy, 1 - sum(xy, 2)];
if ischar(color)
    xyz = xyz ./ max(xyz(:, 2)) * 1.5;
    rgb = colorspace.xyz2rgb(xyz);
    for i = 2:size(xy, 1)
        plot(xy(i-1:i, 1), xy(i-1:i, 2), 'color', rgb(i-1, :), 'linewidth', linewidth);
    end
else
    plot(xy(:, 1), xy(:, 2), 'color', color, 'linewidth', linewidth);
end
end


function plot_xy_hist(xy, grid, background)
% DESCRIPTION
%   Plots 2D histogram of xy data on chromaticity diagram.

hist_img_x = 0:grid:0.8;
hist_img_y = 0:grid:0.9;
hist_img_size = [length(hist_img_y), length(hist_img_x)];
idx = sub2ind(hist_img_size, ...
    min(max(floor(xy(:, 2) / grid) + 1, 1), hist_img_size(1)), ...
    min(max(floor(xy(:, 1) / grid) + 1, 1), hist_img_size(2)));
cnt = accumarray(idx, 1, [prod(hist_img_size), 1]);
k = (cnt(:) / max(cnt(:))).^0.45;

[xx, yy] = meshgrid(hist_img_x, hist_img_y);
xy_grid = [xx(:), yy(:)];

xyz = [xy_grid, 1 - sum(xy_grid, 2)] ./ xy_grid(:, 2) .* k * 1.2;
color = max(colorspace.xyz2rgb(xyz), background);
color = reshape(color, [hist_img_size, 3]);

imagesc(hist_img_x, hist_img_y, color);
end