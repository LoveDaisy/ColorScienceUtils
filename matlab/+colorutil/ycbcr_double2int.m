function [y, u, v] = ycbcr_double2int(y, u, v, varargin)
% DESCRIPTION
%   It converts float YCbCr values to integer values, and scale them properly, according to
%   given parameters (such as color range, etc.).
% SYNTAX
%   [y, u, v] = ycbcr_double2int(y, u, v);
%   [y, u, v] = ycbcr_double2int(y, u, v, bits);
%   [y, u, v] = ycbcr_double2int(y, u, v, bits, color_range);
% INPUT
%   y:              Any shape array of float type. If it is already integer type, it will return immediately.
%   u, v:           Any shape array of float type. If it is already integer type, it will return immediately.
%   bits:           An integer. The bit depth of a pixel. Default is 8.
%   color_range:    'tv' | 'limited' | 'pc' | 'full'
% OUTPUT
%   yuv:            The same shape to input yuv.

u_size = size(u);

if isinteger(y) && isinteger(u) && isinteger(v)
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

if strcmpi(p.Results.range, 'tv') || strcmpi(p.Results.range, 'limited')
    y = y * 219 / 256 + 16 / 256;
    u = u * 224 / 256 + 0.5;
    v = v * 224 / 256 + 0.5;
end

y = y * 2^p.Results.bits;
u = u * 2^p.Results.bits;
v = v * 2^p.Results.bits;

if bits <= 8
    y = uint8(y);
    u = uint8(u);
    v = uint8(v);
elseif bits <= 16
    y = uint16(y);
    u = uint16(u);
    v = uint16(v);
else
    warning('Bits is greater than 16! Treat it as 16!');
    y = uint16(y);
    u = uint16(u);
    v = uint16(v);
end
end