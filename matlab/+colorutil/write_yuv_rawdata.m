function write_yuv_rawdata(filename, varargin)
% DESCRIPTION
%   It writes YUV data to a rawdata file (like a '*.yuv' file).
% SYNTAX
%   write_yuv_rawdata(filename, y, u, v);
%   write_yuv_rawdata(filename, yuv);
%   write_yuv_rawdata(filename, yuv, bits);
%   write_yuv_rawdata(filename, yuv, bits, range);
%   write_yuv_rawdata(filename, yuv, bits, range, pix_fmt);
% INPUT
%   filename:           A string for yuv file path.
%   y, u, v:            m*n array, or (m*n, m*n/2, m*n/2) array, or (m*n, m/2*n/2, m/2*n/2) of integer type.
%   yuv:                m*n*3 double image.
%   bits:               8, 10, 16. Default is 8.
%   range               'tv' | 'limited' | 'pc' | 'full'. Default is 'tv'.
%   pix_fmt:            '420' | '422' | '444'. Default is '420'.

p = inputParser;
p.addRequired('filename', @ischar);
p.parse(filename);

if length(varargin) <1 || length(varargin) > 4
    error('Number of input arguments should be 1 to 4!');
end
if length(varargin) ~= 3 || ischar(varargin{3})
    % yuv, bits, range, pix_fmt
    [y, u, v, data_class] = prepare_float_yuv(varargin{:});
elseif length(varargin) == 2
    % y, u, v
    [y, u, v, data_class] = prepare_integer_yuv(varargin{:});
end

fid = fopen(filename, 'wb');
fwrite(fid, y', data_class);
fwrite(fid, u', data_class);
fwrite(fid, v', data_class);
fclose(fid);
end


function [y, u, v, data_class] = prepare_integer_yuv(varargin)
y = varargin{1};
u = varargin{2};
v = varargin{3};
y_size = size(y);
u_size = size(u);
data_class = class(y);

p = inputParser;
p.addRequired('y', @isinteger);
p.addRequired('u', @(x) isinteger(x) && strcmp(class(x), data_class) && ...
    (size(x, 1) == y_size(1) || size(x, 1) == y_size(1) / 2) && ...
    (size(x, 2) == y_size(2) || size(x, 2) == y_size(2) / 2));
p.addRequired('v', @(x) isinteger(x) && strcmp(class(x), data_class) && all(size(x) == u_size));
p.parse(y, u, v);

if strcmp(data_class(1:4), 'uint')
    error('We do not support signed integer data!');
end
if str2double(data_class(5:end)) > 16
    error('We do not support bit depth greater than 16!');
end
end


function [y, u, v, data_class] = prepare_float_yuv(varargin)
p = inputParser;
p.addRequired('yuv', @(x) length(size(x)) == 3 && size(x, 3) == 3);
p.addOptional('bits', 8, @(x) abs(x - round(x)) < 1e-8);
p.addOptional('range', 'tv', @(x) strcmpi(x, 'tv') || strcmpi(x, 'limited') || ...
    strcmpi(x, 'pc') || strcmpi(x, 'full'));
p.addOptional('pix_fmt', '420', @(x) strcmpi(x, '420') || strcmpi(x, '422') || strcmpi(x, '444'));
p.parse(varargin{:});

y = p.Results.yuv(:, :, 1);
if strcmpi(p.Results.pix_fmt, '420')
    u = p.Results.yuv(1:2:end, 1:2:end, 2);
    v = p.Results.yuv(1:2:end, 1:2:end, 3);
elseif strcmpi(p.Results.pix_fmt, '422')
    u = p.Results.yuv(:, 1:2:end, 2);
    v = p.Results.yuv(:, 1:2:end, 3);
elseif strcmpi(p.Results.pix_fmt, '444')
    u = p.Results.yuv(:, :, 2);
    v = p.Results.yuv(:, :, 3);
else
    error('Cannot recognize pix_fmt!');
end

data_class = sprintf('uint%d', ceil(p.Results.bits / 8) * 8);
[y, u, v] = colorutil.ycbcr_double2int(y, u, v, p.Results.bits, p.Results.range);
end
