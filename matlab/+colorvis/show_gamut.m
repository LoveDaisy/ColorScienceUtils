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
%   'Fill':             true | false. Default is true. Whether to fill the gamut or
%                       just draw the boundaries.
%   'Vertex':           true | false. Default is true. Whether to plot vertices of
%                       the RGB gamut. If Fill is true, this option will be ignored.

p = inputParser;
p.addRequired('ColorVolumn', @colorutil.cs_param_validator);
p.addOptional('UCS', 'Lab', @(x) ischar(x) && (strcmpi(x, 'Lab') || strcmpi(x, 'ICtCp') || strcmpi(x, 'xyY')));
p.addParameter('Fill', true, @(x) islogical(x) && isscalar(x));
p.addParameter('Vertex', true, @(x) islogical(x) && isscalar(x));
p.parse(color_volumn, varargin{:});

next_plot = get(gca, 'NextPlot');
hold on;

ucs_param = get_ucs_param(p.Results.UCS, color_volumn);

% Plot vertices
if p.Results.Vertex && ~p.Results.Fill
    plot_vertices(ucs_param.tf);
end

% Fill gamut or just show edges
if p.Results.Fill
    fill_gamut(ucs_param.tf);
else
    plot_edge(ucs_param.tf);
end

% Set axes properties.
asp = [1, 1, diff(ucs_param.z_lim) / diff(ucs_param.xy_lim) * 0.8];
cam_lon = -110;
cam_lat = 35;
cam_r = 6 * diff(ucs_param.xy_lim);
cam_pos = cam_r * [cosd(cam_lon)*cosd(cam_lat), sind(cam_lon)*cosd(cam_lat), sind(cam_lat) * asp(3)];
grid on;
set(gca, 'color', [1, 1, 1] * 0.75, 'DataAspectRatio', asp, ...
    'xlim', ucs_param.xy_lim, 'ylim', ucs_param.xy_lim, 'zlim', ucs_param.z_lim, ...
    'Projection', 'Perspective', ...
    'CameraPosition', cam_pos);

set(gca, 'NextPlot', next_plot);
end


function p = get_ucs_param(ucs, src_gamut)
% Default is Lab
switch lower(ucs)
    case 'lab'
        tf = @(x) lab_transform(x, src_gamut);
    case 'ictcp'
        tf = @(x) ictcp_transform(x, src_gamut);
    case 'xyy'
        % tf = @(x) xyY_transform(x, src_gamut);
        tf = @(x) colorspace.rgb2xyY(x, src_gamut);
    otherwise
        warning('Space %s cannot be recognized! Use default Lab!');
        tf = @(x) lab_transform(x, src_gamut);
end
vtx = [0, 0, 0;
    0, 0, 1;
    0, 1, 0;
    0, 1, 1;
    1, 0, 0;
    1, 0, 1;
    1, 1, 0;
    1, 1, 1];
vtx_data = tf(vtx);
ranges = prctile(vtx_data, [0, 100])';
xy_lim = max(max(abs(ranges(1:2, :))));
xy_lim = [-1, 1] * xy_lim;
z_lim = ranges(3, :);

if strcmpi(ucs, 'xyy')
    xy_lim = [-0.1, 1];
end

p.tf = tf;
p.xy_lim = xy_lim;
p.z_lim = z_lim;
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
    plot3(data(:, 1), data(:, 2), data(:, 3), 'color', [1, 1, 1] * 0.25);
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
scatter3(data(:, 1), data(:, 2), data(:, 3), 60, rgb, 'MarkerFaceColor', 'flat');
end


function fill_gamut(tf)
ds = 0.01;
[xx, yy] = meshgrid(0:ds:1, 0:ds:1);
zz = zeros(size(xx));
rgb = cat(3, xx, yy, zz);
data = tf(rgb);
surface(data(:, :, 1), data(:, :, 2), data(:, :, 3), rgb, 'edgecolor', 'none');
rgb = cat(3, xx, zz, yy);
data = tf(rgb);
surface(data(:, :, 1), data(:, :, 2), data(:, :, 3), rgb, 'edgecolor', 'none');
rgb = cat(3, zz, xx, yy);
data = tf(rgb);
surface(data(:, :, 1), data(:, :, 2), data(:, :, 3), rgb, 'edgecolor', 'none');

zz = ones(size(xx));
rgb = cat(3, xx, yy, zz);
data = tf(rgb);
surface(data(:, :, 1), data(:, :, 2), data(:, :, 3), rgb, 'edgecolor', 'none');
rgb = cat(3, xx, zz, yy);
data = tf(rgb);
surface(data(:, :, 1), data(:, :, 2), data(:, :, 3), rgb, 'edgecolor', 'none');
rgb = cat(3, zz, xx, yy);
data = tf(rgb);
surface(data(:, :, 1), data(:, :, 2), data(:, :, 3), rgb, 'edgecolor', 'none');
end


function abl = lab_transform(rgb, src_param)
input_size = size(rgb);
lab = colorspace.rgb2lab(rgb, src_param);
lab = reshape(lab, [], 3);
abl = lab(:, [2, 3, 1]);
abl = reshape(abl, input_size);
end


function ctcpi = ictcp_transform(rgb, src_param)
input_size = size(rgb);
scale = 100;
ictcp = colorspace.rgb2ictcp(rgb, src_param, 'Scale', scale);
ictcp = reshape(ictcp, [], 3);
ctcpi = ictcp(:, [2, 3, 1]);
ctcpi = reshape(ctcpi, input_size);
end
