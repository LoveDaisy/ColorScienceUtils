function plot_yuv(varargin)
% DESCRIPTION
%   It displays YCbCr data properly. If not specified, it shows uv components as half size as y
%   component, and place them side by side along the long side of y component.
% SYNTAX
%   plot_yuv(y, u, v);
%   plot_yuv(data);
%   plot_yuv(..., Name, Value...);
% INPUT
%   y:          m*n array. Range in [0, 1].
%   u, v:       m/2*n/2 array (for 420) or m*n/2 array (for 422) or m*n array (for 444).
%               Range in [-0.5, 0.5].
%   data:       A struct with field yfp, ufp, vfp
% OPTIONS
%   All options for imshow().

input_arg_yuv = isnumeric(varargin{1});
p = inputParser;
if input_arg_yuv
    p.addRequired('y', @(x) validateattributes(x, {'numeric'}, {'2d'}));
    p.addRequired('u', @(x) validateattributes(x, {'numeric'}, {'2d'}));
    p.addRequired('v', @(x) validateattributes(x, {'numeric'}, {'2d'}));
    p.parse(varargin{1:3});
    if length(varargin) > 3
        varargin = varargin(4:end);
    else
        varargin = {};
    end
else
    p.addOptional('data', [], @(x) isstruct(x) && isfield(x, 'yfp') && isfield(x, 'ufp') && isfield(x, 'vfp'));
    p.parse(varargin{1});
    if length(varargin) > 1
        varargin = varargin(2:end);
    else
        varargin = {};
    end
end

if ~input_arg_yuv
    y = p.Results.data.yfp;
    u = p.Results.data.ufp;
    v = p.Results.data.vfp;
else
    y = p.Results.y;
    u = p.Results.u;
    v = p.Results.v;
end

y_size = size(y);
u_size = size(u);
v_size = size(v);
if any(u_size ~= v_size) || any(~(u_size == y_size | u_size * 2 == y_size)) || ...
    any(~(v_size == y_size | v_size * 2 == y_size))
    error('YUV size NOT match!');
end

if any(u_size ~= y_size / 2)
    u = imresize(u, y_size / 2);
    v = imresize(v, y_size / 2);
    u_size = size(u);
    v_size = size(v);
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
