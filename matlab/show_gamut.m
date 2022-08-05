function show_gamut(rgb_gamut, varargin)
% DESCRIPTION
%   Show RGB gamut in a given space (such as Lab or ICtCp etc.).
% SYNTAX
%   show_gamut(rgb_gamut);              % Default in Lab space
%   show_gamut(rgb_gamut, space);       % Plot in given space
%   show_gamut(..., Name, Value...);    % Set some parameters
% INPUT
%   rgb_gamut:          A string for RGB gamut name.
%                       See internal.cs_name_validator for detail.
%   space:              A string for the space in which gamut will be display.
% PARAMETER
%   'Fill':             true | false. Default is false. Whether to fill the gamut or
%                       just draw the boundaries.
%   'Vertex':           true | false. Default is false. Whether to plot vertices of
%                       the RGB gamut

p = inputParser;
p.addRequired('rgb_gamut', @internal.cs_name_validator);
p.addOptional('space', 'Lab', @(x) ischar(x) && (strcmpi(x, 'Lab') || strcmpi(x, 'ICtCp')));
p.addParameter('Fill', false, @(x) islogical(x) && isscalar(x));
p.addParameter('Vertex', false, @(x) islogical(x) && isscalar(x));
p.parse(rgb_gamut, varargin{:});

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

next_plot = get(gca, 'NextPlot');
hold on;

xy_lim = [-1, 1] * 0.5;
z_lim = [0, 1];
m = colorspace.xyz_rgb_mat(rgb_gamut);
switch lower(p.Results.space)
    case 'lab'
        tf = @(x) colorspace.rgb2lab(x, rgb_gamut);
        inv_tf = @(x) colorspace.lab2xyz(x) * m;
    case 'ictcp'
        scale = 100;
        tf = @(x) colorspace.rgb2ictcp(x, rgb_gamut, 'Scale', scale);
        inv_tf = @(x) colorspace.ictcp2xyz(x) * m / scale;
        ictcp = colorspace.rgb2ictcp([1, 1, 1], rgb_gamut, 'Scale', scale);
        z_lim = [0, ictcp(1)];
    otherwise
        warning('Space %s cannot be recognized! Use default Lab!');
        tf = @(x) colorspace.rgb2lab(x, rgb_gamut);
        inv_tf = @(x) colorspace.lab2xyz(x) * m;
end

% Plot vertices
if p.Results.Vertex
    rgb = [end_points(:, 1:3) + end_points(:, 4:6); end_points(:, 4:6); 0, 0, 0];
    rgb = unique(rgb, 'rows');
    data = tf(rgb);
    scatter3(data(:, 2), data(:, 3), data(:, 1), 60, rgb, 'MarkerFaceColor', 'flat');
end

% Fill gamut
if p.Results.Fill
    dx = 0.005;
    [xx, yy, zz] = meshgrid(xy_lim(1):dx:xy_lim(2), xy_lim(1):dx:xy_lim(2), z_lim(1):dx:z_lim(2));
    data = [zz(:), xx(:), yy(:)];
    rgb = inv_tf(data);
    idx = min(rgb, [], 2) >= 0 & max(rgb, [], 2) <= 1 & ...
        (min(rgb, [], 2) <= 0.05 | max(rgb, [], 2) >= 1 - 0.05);
    data = data(idx, :);
    rgb = rgb(idx, :);
    rgb = colorspace.rgb_gamma(rgb, rgb_gamut);
    scatter3(data(:, 2), data(:, 3), data(:, 1), 6, rgb, 'MarkerFaceColor', 'flat');
end

% Plot boundary
for i = 1:size(end_points, 1)
    rgb = (0:.01:1)' * end_points(i, 4:6) + end_points(i, 1:3);
    data = tf(rgb);
    plot3(data(:, 2), data(:, 3), data(:, 1), 'color', [1, 1, 1] * 0.25);
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