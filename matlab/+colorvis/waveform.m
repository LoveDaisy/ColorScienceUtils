function wv_map = waveform(image, varargin)
% DESCRIPTION
%   Calculate waveform map of an image.
% SYNTAX
%   wv_map = waveform(image)
%   wv_map = waveform(..., option_name, option_value, ...)
% INPUT
%   image:          A single or 3-channel image.
% OPTION
%   'FloatRange':   An integer. Default is 1024 (2^10). It is used for dividing bins of float values.
%   'MapColor':     true(default) or false. If set to on, then output wv_map will be colored.
%   'Smooth':       An integer, the kernel size used to smooth histogram of each column. Default is 0.
% OUTPUT
%   wv_map:         m*n or m*n*3 array, when 'MapColor' is true; or m*n*3 or m*n*3*3, when 'MapColor' is false.
%                   Waveform map will be size of [value_range, img_wid] during internal
%                   processing. Then it is scaled to OutputSize. Default is [], which means no scale.
%                   value_range is determined by data type of image. For int8 it is 256 (2^8); for
%                   int16 it is 65536 (2^16) if the max value in image is greater than 1024, or
%                   it is 1024 (2^10) if the max value in image is less than 1024; for double it is
%                   1024 (2^10) as default but can be set with 'FloatRange' option.

p = inputParser;
p.addRequired('image', @(x) colorutil.image_shape_validator(x) && (isa(x, 'double') || ...
    isa(x, 'uint16') || isa(x, 'uint8')));
p.addParameter('FloatRange', 1024, @(x) isscalar(x) && mod(x, 1) == 0);
p.addParameter('MapColor', true, @(x) isscalar(x) && islogical(x));
p.addParameter('Smooth', 0, @(x) isscalar(x) && isnumeric(x) && mod(x, 1) == 0);
p.parse(image, varargin{:});

image_size = size(image);
ch_num = size(image, 3);

if isa(image, 'double')
    value_bins = linspace(0, 1, p.Results.FloatRange + 1);
elseif isa(image, 'uint16')
    if max(image(:)) >= 1024
        value_bins = -0.5:1:65536;
    else
        value_bins = -0.5:1:1024;
    end
elseif isa(image, 'uint8')
    value_bins = -0.5:1:256;
end

wv_map = zeros(length(value_bins) - 1, image_size(2), ch_num);
for x = 1:image_size(2)
    for ch = 1:ch_num
        n = histcounts(image(:, x, ch), value_bins);
        wv_map(:, x, ch) = n(:);
    end
end
if p.Results.Smooth > 0
    wv_map = imfilter(wv_map, ones(p.Results.Smooth, 1));
end
wv_map = wv_map / max(wv_map(:));

if ~p.Results.MapColor
    return;
end
if ch_num == 1
    wv_map = wv_map .* reshape([1, 1, 1], 1, 1, 3);
    return;
end

r_ctcp = [-0.02609, 0.13806];
g_ctcp = [-0.07946, -0.05672];
b_ctcp = [0.1542, -0.07012];

wv_h = size(wv_map, 1);
wv_w = size(wv_map, 2);

r_wv = colorspace.ictcp2rgb(cat(3, wv_map(:, :, 1).^(1/2.0), ...
    0.55 * ones(wv_h, wv_w) .* reshape(r_ctcp, 1, 1, 2)), 'srgb');
g_wv = colorspace.ictcp2rgb(cat(3, wv_map(:, :, 2).^(1/2.0), ...
    0.55 * ones(wv_h, wv_w) .* reshape(g_ctcp, 1, 1, 2)), 'srgb');
b_wv = colorspace.ictcp2rgb(cat(3, wv_map(:, :, 3).^(1/2.0), ...
    0.55 * ones(wv_h, wv_w) .* reshape(b_ctcp, 1, 1, 2)), 'srgb');
wv_map = cat(4, r_wv, g_wv, b_wv);
end