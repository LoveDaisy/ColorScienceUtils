function plot_chromaticity_xy_boundary(varargin)
% DESCRIPTION
%   It draws the boundary of chromaticity diagram.
% SYNTAX
%   plot_chromaticity_xy_boundary()
%   plot_chromaticity_xy_boundary(Name, Value...)
% OPTIONS
%   'LineWidth':            A scalar. Default is 0.8.
%   'ZPosition':            A scalar. Specifies z-position in a 3D chart. Default is [].

p = inputParser;
p.addParameter('LineWidth', 0.8, @(x) isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('ZPosition', [], @(x) isnumeric(x) && isscalar(x));
p.parse(varargin{:});

lambda = 420:760;
cmf = colorspace.xyz_cmf();
xyz0 = interp1(cmf(:, 1), cmf(:, 2:4), lambda);
xy0 = xyz0(:, 1:2) ./ sum(xyz0, 2);
xy_line = interp1([1; 0], [xy0(end, :); xy0(1, :)], linspace(1, 0, 20));
xy = [xy0; xy_line];
xyz = [xy, 1 - sum(xy, 2)];
xyz = xyz ./ max(xyz(:, 2)) * 1.5;
rgb = colorspace.xyz2rgb(xyz);

if isempty(p.Results.ZPosition)
    for i = 2:size(xy, 1)
        plot(xy(i-1:i, 1), xy(i-1:i, 2), 'color', rgb(i-1, :), 'linewidth', p.Results.LineWidth);
    end
else
    for i = 2:size(xy, 1)
        plot3(xy(i-1:i, 1), xy(i-1:i, 2), ones(2, 1) * p.Results.ZPosition, 'color', rgb(i-1, :), ...
            'linewidth', p.Results.LineWidth);
    end
end
end
