function [c, s, lim] = hist3d(data, scale, density, z_log, dither)
% DESCRIPTION
%   It collects 3D data into discrete grids (bubbles).
% SYNTAX
%   [c, s, lim] = hist3d(data, scale, density, z_log)
% INPUT
%   data:           n*3 array.
%   scale:          A scalar. The greater the bigger bubbles are.
%   density:        A scalar or 2-element vector for xy-density and z-density. The greater the denser bubbles are.
%   z_log:          true | false. Whether treat z-axis as linear or log scale when collecting data.
%   dither:         A scalar in [0, 1].

if z_log
    data(:, 3) = log(data(:, 3) + 1e-4);
end

x_lim = prctile(data(:, 1), [0, 100]);
y_lim = prctile(data(:, 2), [0, 100]);
z_lim = prctile(data(:, 3), [0, 100]);

dxy = min(diff(x_lim), diff(y_lim)) / 20;
dz = diff(z_lim) / 40;
if isscalar(density)
    dxy = dxy / density;
    dz = dz / density;
else
    dxy = dxy / density(1);
    dz = dz / density(2);
end

x_grid = x_lim(1):dxy:x_lim(2);
y_grid = y_lim(1):dxy:y_lim(2);
z_grid = z_lim(1):dz:z_lim(2);
grid = [dxy, dxy, dz];
sub_size = [length(x_grid) - 1, length(y_grid) - 1, length(z_grid) - 1];

sub = min(max(round((data - [x_lim(1), y_lim(1), z_lim(1)]) ./ [dxy, dxy, dz]) + 1, [1, 1, 1]), sub_size);
ind = sub2ind(sub_size, sub(:, 1), sub(:, 2), sub(:, 3));
cnt = accumarray(ind, 1, [prod(sub_size), 1]);
cnt_idx = cnt > 0;
[bx, by, bz] = ind2sub(sub_size, find(cnt_idx));
c = ([bx, by, bz] - 0.5) .* [dxy, dxy, dz] + [x_lim(1), y_lim(1), z_lim(1)];
c = c + (rand(size(c)) - 0.5) .* grid * dither;
cnt = cnt(cnt_idx);

s0 = prctile(cnt, 99.5);
s = min((cnt / s0 + 0.001), 1) * 70 * scale / sqrt(prod(density));

if z_log
    c(:, 3) = exp(c(:, 3));
    z_lim = prctile(c(:, 3), [0, 100]) .* [0.8, 1.3];
end
lim = [x_lim; y_lim; z_lim];
end