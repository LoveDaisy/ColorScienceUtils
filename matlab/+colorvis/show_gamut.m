function show_gamut(color_volumn, varargin)
% DESCRIPTION
%   Show RGB gamut in a given space (such as Lab or ICtCp etc.).
% SYNTAX
%   show_gamut(color_volumn);           % Default in Lab space
%   show_gamut(color_volumn, ucs);      % Plot in given space
%   show_gamut(..., Name, Value...);    % Set some parameters
% INPUT
%   color_volumn:       A string or a struct returned from colorspace.get_param().
%                       See colorutil.cs_param_validator for detail.
%   ucs:                A string for a uniform color space in which input volumn will be display.
% PARAMETER
%   'Fill':             true | false. Default is false. Whether to fill the gamut or
%                       just draw the boundaries.
%   'Vertex':           true | false. Default is false. Whether to plot vertices of
%                       the RGB gamut

p = inputParser;
p.addRequired('ColorVolumn', @colorutil.cs_param_validator);
p.addOptional('UCS', 'Lab', @(x) ischar(x) && (strcmpi(x, 'Lab') || strcmpi(x, 'ICtCp')));
p.addParameter('Fill', false, @(x) islogical(x) && isscalar(x));
p.addParameter('Vertex', false, @(x) islogical(x) && isscalar(x));
p.parse(color_volumn, varargin{:});

next_plot = get(gca, 'NextPlot');
hold on;

xy_lim = [-1, 1] * 0.5;
z_lim = [0, 1];
switch lower(p.Results.UCS)
    case 'lab'
        tf = @(x) colorspace.rgb2lab(x, color_volumn);
    case 'ictcp'
        scale = 100;
        tf = @(x) colorspace.rgb2ictcp(x, color_volumn, 'Scale', scale);
        % ictcp = colorspace.rgb2ictcp([1, 1, 1], color_volumn, 'Scale', scale);
        % z_lim = [0, ictcp(1)];
    otherwise
        warning('Space %s cannot be recognized! Use default Lab!');
        tf = @(x) colorspace.rgb2lab(x, color_volumn);
end

% Plot vertices
if p.Results.Vertex && ~p.Results.Fill
    plot_vertices(tf);
end

% Fill gamut or just show edges
if p.Results.Fill
    fill_gamut(tf);
else
    plot_edge(tf);
end

% Set axes properties.
cam_lon = -110;
cam_lat = 35;
cam_r = 4;
cam_pos = cam_r * [cosd(cam_lon)*cosd(cam_lat), sind(cam_lon)*cosd(cam_lat), sind(cam_lat)];
axis equal; grid on;
set(gca, 'color', [1, 1, 1] * 0.75, ...
    'xlim', xy_lim, 'ylim', xy_lim, 'zlim', z_lim, ...
    'xtick', -1:.1:1, 'ytick', -1:.1:1, ...
    'Projection', 'Perspective', ...
    'CameraPosition', cam_pos);

set(gca, 'NextPlot', next_plot);
end


function plot_edge(tf)
end_points = [0, 0, 0, 0, 0, 1;
    0, 0, 0, 0, 1, 0;
    0, 0, 0, 1, 0, 0;
    0, 0, 1, 0, 1, 0;
    0, 0, 1, 1, 0, 0;
    0, 1, 0, 0, 0, 1;
    0, 1, 0, 1, 0, 0;
    1, 0, 0, 0, 0, 1;
    1, 0, 0, 0, 1, 0;
    0, 1, 1, 1, 0, 0;
    1, 0, 1, 0, 1, 0;
    1, 1, 0, 0, 0, 1];

for i = 1:size(end_points, 1)
    rgb = (0:.01:1)' * end_points(i, 4:6) + end_points(i, 1:3);
    data = tf(rgb);
    plot3(data(:, 2), data(:, 3), data(:, 1), 'color', [1, 1, 1] * 0.25);
end
end


function plot_vertices(tf)
rgb = [0, 0, 0;
    0, 0, 1;
    0, 1, 0;
    0, 1, 1;
    1, 0, 0;
    1, 0, 1;
    1, 1, 0;
    1, 1, 1];
data = tf(rgb);
scatter3(data(:, 2), data(:, 3), data(:, 1), 60, rgb, 'MarkerFaceColor', 'flat');
end


function fill_gamut(tf)
ds = 0.01;

[xx, yy] = meshgrid(0:ds:1, 0:ds:1);
zz = zeros(size(xx));
rgb = cat(3, xx, yy, zz);
data = tf(rgb);
surface(data(:, :, 2), data(:, :, 3), data(:, :, 1), rgb, 'edgecolor', 'none');
rgb = cat(3, xx, zz, yy);
data = tf(rgb);
surface(data(:, :, 2), data(:, :, 3), data(:, :, 1), rgb, 'edgecolor', 'none');
rgb = cat(3, zz, xx, yy);
data = tf(rgb);
surface(data(:, :, 2), data(:, :, 3), data(:, :, 1), rgb, 'edgecolor', 'none');

zz = ones(size(xx));
rgb = cat(3, xx, yy, zz);
data = tf(rgb);
surface(data(:, :, 2), data(:, :, 3), data(:, :, 1), rgb, 'edgecolor', 'none');
rgb = cat(3, xx, zz, yy);
data = tf(rgb);
surface(data(:, :, 2), data(:, :, 3), data(:, :, 1), rgb, 'edgecolor', 'none');
rgb = cat(3, zz, xx, yy);
data = tf(rgb);
surface(data(:, :, 2), data(:, :, 3), data(:, :, 1), rgb, 'edgecolor', 'none');
end
