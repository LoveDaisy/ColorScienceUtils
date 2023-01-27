function parade_diagram(image, varargin)
% DESCRIPTION
%   This function displays a parade diagram of an image, which shows the 
%   individual channels (RGB/YUV) of the image in separate subplots.
% SYNTAX
%   parade_diagram(image)
%   parade_diagram(..., option_name, option_value, ...)
% INPUT
%   image:              A 2D or 3D image array, the image for the parade diagram
% OPTION                      
%   'Type':             String, 'merge' or 'seperate'(default), 
%                       specify the type of parade diagram. 
%   'ColorSpace':       String, specify the color space of the image, 
%                       'RGB'(default) or 'YUV'
%   'Range':            String, 'auto'(default) or [min max], specify the range of display.
%                       If 'auto' is set, the range will determined by data type of image.
%                       For double, the range is [0, 1]; for int8 it will be [0, 255]; for
%                       int16 it will be [0, 65535].
% OUTPUT
%   None

% parse inputs
p = inputParser;
p.addRequired('image', @colorutil.image_shape_validator);
p.addParameter('Type', 'seperate', @(x) validatestring(lower(x), {'merge', 'seperate'}));
p.addParameter('ColorSpace', 'rgb', @(x) validatestring(lower(x), {'rgb', 'yuv'}));
p.addParameter('Range', 'auto', @(x) (ischar(x) && strcmpi(x, 'auto')) || (isnumeric(x) && numel(x) == 2));
p.parse(image, varargin{:});

image_size = size(image);

fig = gcf;
h0 = 450;
w0 = floor(image_size(2) / image_size(1) * h0);
if strcmpi(p.Results.Type, 'seperate')
    fig.InnerPosition = [50, 150, w0 * 2.1, h0];
    asp = fig.InnerPosition(3) / fig.InnerPosition(4);  % w/h

    axes('Position', [0, 0, w0/h0/asp, 1]);
    imagesc(image);
    axis tight; axis equal; axis off;

    wv_map = colorvis.waveform(image, 'MapColor', true, 'Smooth', 5);
    wv_h = size(wv_map, 1);
    wv_w = size(wv_map, 2);
    ax = axes('Position', [w0/h0/asp * 1.01, 0.01, w0/h0/asp * 1/3, .98]);
    imagesc(1:wv_w, 0:wv_h-1, wv_map(:, :, :, 1));
    axis xy;
    set(ax, 'xtick', [], 'ytick', [], 'yaxislocation', 'right');
    
    ax = axes('Position', [w0/h0/asp * (1.01 + 1/3), 0.01, w0/h0/asp * 1/3, .98]);
    imagesc(1:wv_w, 0:wv_h-1, wv_map(:, :, :, 2));
    axis xy;
    set(ax, 'xtick', [], 'ytick', [], 'yaxislocation', 'right');

    ax = axes('Position', [w0/h0/asp * (1.01 + 2/3), 0.01, w0/h0/asp * 1/3, .98]);
    imagesc(1:wv_w, 0:wv_h-1, wv_map(:, :, :, 3));
    axis xy;
    set(ax, 'xtick', [], 'ytick', [0, 128, 256, 384, 512, 640, 768, 896, 1023], 'yaxislocation', 'right');
else
    fig.Position = [50, 50, w0, h0 * 2.2];
end
end
