function [y, u, v] = yuv2double(y, u, v, varargin)
% DESCRIPTION
%   It converts integer YCbCr values to double value, and scale them properly, so that
%   Y component is expected in range [0, 1], Cb and Cr components are expected in range [-0.5, 0.5].
%   It DOES NOT clip any value out of range.
% SYNTAX
%   [y, u, v] = yuv2double(y, u, v);
%   [y, u, v] = yuv2double(y, u, v, bits);
%   [y, u, v] = yuv2double(y, u, v, bits, color_range);
% INPUT
%   y:              Any shape array of integer type. If it is of double type, it will return immediately.
%   u, v:           Any shape array of integer type. If it is of double type, it will return immediately.
%   bits:           An integer. The bit depth of a pixel. Default is 8.
%   color_range:    'tv' | 'limited' | 'pc' | 'full'
% OUTPUT
%   yuv:            The same shape to input yuv.

u_size = size(u);

if isfloat(y) && isfloat(u) && isfloat(v)
    return;
end

p = inputParser;
p.addRequired('y', @isnumeric);
p.addRequired('u', @(x) strcmp(class(x), class(y)));
p.addRequired('v', @(x) all(size(x) == u_size) && strcmp(class(x), class(y)));
p.addOptional('bits', 8, @(x) isreal(x) && abs(x - round(x)) < 1e-10);
p.addOptional('range', 'tv', @(x) strcmpi(x, 'tv') || strcmpi(x, 'limited') || ...
    strcmpi(x, 'pc') || strcmpi(x, 'full'));
p.parse(y, u, v, varargin{:});

y = double(y) / 2^p.Results.bits;
u = double(u) / 2^p.Results.bits - 0.5;
v = double(v) / 2^p.Results.bits - 0.5;

if strcmpi(p.Results.range, 'tv') || strcmpi(p.Results.range, 'limited')
    y = (y - 16 / 256) * 256 / 219;
    u = u * 256 / 224;
    v = v * 256 / 224;
end
end