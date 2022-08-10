function plot_chromaticity_diagram(varargin)
% DESCRIPTION
%   Plot the chromaticity diagram.
% SYNTAX
%   plot_chromaticity_diagram();
%   plot_chromaticity_diagram(Name, Value...)
% OPTIONS
%   'lambda':           row vector, the wavelength values. Default is 400:760.
%   'color':            'real' | 3-elements RGB value. Default is 'real'.
%   'background':       3-elements RGB value. Default is [0.1, 0.1, 0.1].
%   'linewidth':        A scalar. Default is 1.2.
%   'primaries':        A string for colorspace name, or a struct of colorspace parameter. See
%                       colorspace.util.cs_param_validator for detail. Default is empty.
%   'xy':               n*2 array.

p = inputParser;
p.addParameter('lambda', 400:760, @(x) validateattributes(x, {'numeric'}, {'row'}));
p.addParameter('color', 'real', @(x) ischar(x) && strcmpi(x, 'real') || ...
    isnumeric(x) && isvector(x) && length(x) == 3);
p.addParameter('background', [0.1, 0.1, 0.1], @(x) isnumeric(x) && isvector(x) && length(x) == 3);
p.addParameter('linewidth', 1.2, @isscalar);
p.addParameter('primaries', [], @colorspace.util.cs_param_validator);
p.addParameter('xy', [], @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 2}));
p.parse(varargin{:});

nextplot = get(gca, 'NextPlot');
hold on;

if ~isempty(p.Results.xy)
    grid = 0.0025;
    hist_img_x = 0:grid:0.8;
    hist_img_y = 0:grid:0.9;
    hist_img_size = [length(hist_img_y), length(hist_img_x)];
    idx = sub2ind(hist_img_size, floor(p.Results.xy(:, 2) / grid) + 1, floor(p.Results.xy(:, 1) / grid) + 1);
    cnt = accumarray(idx, 1, [prod(hist_img_size), 1]);
    k = (cnt / max(cnt)).^0.45;
    
    [xx, yy] = meshgrid(hist_img_x, hist_img_y);
    xy_grid = [xx(:), yy(:)];
    
    xyz = [xy_grid, 1 - sum(xy_grid, 2)] ./ xy_grid(:, 2) .* k * 1.2;
    color = max(colorspace.xyz2rgb(xyz), p.Results.background);
    color = reshape(color, [hist_img_size, 3]);
    
    imagesc(hist_img_x, hist_img_y, color);
end

if p.Results.linewidth > 0
    lambda = p.Results.lambda(:);
    cmf = colorspace.util.xyz_cmf();
    xyz0 = interp1(cmf(:, 1), cmf(:, 2:4), lambda);
    xy0 = xyz0(:, 1:2) ./ sum(xyz0, 2);
    xy_line = interp1([1; 0], [xy0(end, :); xy0(1, :)], linspace(1, 0, 20));
    xy = [xy0; xy_line];
    xyz = [xy, 1 - sum(xy, 2)];
    if ischar(p.Results.color)
        xyz = xyz ./ max(xyz(:, 2)) * 1.5;
        rgb = colorspace.xyz2rgb(xyz);
        for i = 2:size(xy, 1)
            plot(xy(i-1:i, 1), xy(i-1:i, 2), 'color', rgb(i-1, :), 'linewidth', p.Results.linewidth);
        end
    else
        plot(xy(:, 1), xy(:, 2), 'color', p.Results.color, 'linewidth', p.Results.linewidth);
    end
end

if ~isempty(p.Results.primaries)
    if ischar(p.Results.primaries)
        param = colorspace.get_param(p.Results.primaries);
    else
        param = p.Results.primaries;
    end
    plot(param.rgb(:, 1), param.rgb(:, 2), 'ws');
    plot(param.w(:, 1) / sum(param.w), param.w(:, 2) / sum(param.w), 'wo');
end

set(gca, 'color', p.Results.background, 'NextPlot', nextplot);
end