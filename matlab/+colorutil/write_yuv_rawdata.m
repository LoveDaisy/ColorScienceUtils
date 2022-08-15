function write_yuv_rawdata(filename, y, u, v)
% DESCRIPTION
%   It reads YUV data from rawdata file (usually *.yuv).
% SYNTAX
%   write_yuv_rawdata(filename, frame_size, y, u, v);
% INPUT
%   filename:           A string for yuv file path.
%   y:                  m*n array of integer type.
%   u, v:               m/2*n/2 array (for 420) or m*n/2 array (for 422) or m*n array (for 444)

y_size = size(y);
u_size = size(u);
data_class = class(y);

p = inputParser;
p.addRequired('filename', @ischar);
p.addRequired('y', @isinteger);
p.addRequired('u', @(x) isinteger(x) && strcmp(class(x), data_class) && ...
    (size(x, 1) == y_size(1) || size(x, 1) == y_size(1) / 2) && ...
    (size(x, 2) == y_size(2) || size(x, 2) == y_size(2) / 2));
p.addRequired('v', @(x) isinteger(x) && strcmp(class(x), data_class) && all(size(x) == u_size));
p.parse(filename, y, u, v);

if data_class(1) ~= 'uint'
    error('We do not support signed integer data!');
end
if str2double(data_class(5:end)) > 16
    error('We do not support bit depth greater than 16!');
end

fid = fopen(filename, 'wb');
fwrite(fid, y', data_class);
fwrite(fid, u', data_class);
fwrite(fid, v', data_class);
fclose(fid);
end