function plot_yuv(y, u, v, varargin)
% DESCRIPTION
%   It displays YCbCr data properly. If not specified, it shows uv components as half size as y
%   component, and place them side by side along the long side of y component.
% SYNTAX
%   plot_yuv(y, u, v);
%   plot_yuv(..., Name, Value...);
% INPUT
%   y:          m*n array. Range in [0, 1].
%   u, v:       m/2*n/2 array (for 420) or m*n/2 array (for 422) or m*n array (for 444).
%               Range in [-0.5, 0.5].
% OPTIONS
%   All options for imshow().

y_size = size(y);
u_size = size(u);
v_size = size(v);

p = inputParser;
p.addRequired('y', @(x) validateattributes(x, {'numeric'}, {'2d'}));
p.addRequired('u', @(x) all(size(x) == v_size) && ...
    (size(x, 1) == y_size(1) || size(x, 1) == y_size(1) / 2) && ...
    (size(x, 2) == y_size(2) || size(x, 2) == y_size(2) / 2));
p.addRequired('v', @(x) all(size(x) == u_size));
p.parse(y, u, v);

if any(u_size ~= y_size)
    u = imresize(u, y_size / 2);
    v = imresize(v, y_size / 2);
end

uv_scale = 1.0;
if y_size(1) < y_size(2)
    % Landscape orientation
    disp_img = [repmat(y, [1, 1, 3]);
        colorspace.ycbcr2rgb(cat(3, ones(u_size) * 0.5, u * uv_scale, zeros(u_size)), ...
        'srgb', 'srgb'), ...
        colorspace.ycbcr2rgb(cat(3, ones(v_size) * 0.5, zeros(v_size), v * uv_scale), ...
        'srgb', 'srgb')];
else
    % Portrait orientation
    disp_img = [repmat(y, [1, 1, 3]), ...
        [colorspace.ycbcr2rgb(cat(3, ones(u_size) * 0.5, u * uv_scale, zeros(u_size)), ...
        'srgb', 'srgb'); ...
        colorspace.ycbcr2rgb(cat(3, ones(v_size) * 0.5, zeros(v_size), v * uv_scale), ...
        'srgb', 'srgb')]];
end

imshow(disp_img, varargin{:});
end