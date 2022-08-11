function [y, u, v] = read_yuv_rawdata(filename, frame_size, varargin)
% DESCRIPTION
%   It reads YUV data from rawdata file (usually *.yuv).
% SYNTAX
%   y = read_yuv_rawdata(filename, frame_size);
%   [y, u, v] = read_yuv_rawdata(filename, frame_size);
%   ... = read_yuv_rawdata(filename, frame_size, pix_fmt);
% INPUT
%   filename:           A string for yuv file path.
%   frame_size:         [width, height], the size of frame.
%   pix_fmt:            A string for pixel format, e.g. 'yuv422p', 'yuv420p10le'.
%                       See colorutil.pix_fmt_validator for detail.
% OUTPUT
%   y:                  height*width array. It is of integer type, determined by pix_fmt.
%   u, v:               height*width, or heigh*width/2, or height/2*width/2.

p = inputParser;
p.addRequired('filename', @ischar);
p.addRequired('frame_size', @(x) isvector(x) && length(x) == 2);
p.addOptional('pix_fmt', 'yuv420p', @colorutil.pix_fmt_validator);
p.parse(filename, frame_size, varargin{:});

[size_factor, precision] = colorutil.parse_pix_fmt(p.Results.pix_fmt);
fid = fopen(filename, 'rb');
y = fread(fid, size_factor(1, :) .* frame_size, sprintf('%s=>%s', precision, precision))';
u = fread(fid, size_factor(2, :) .* frame_size, sprintf('%s=>%s', precision, precision))';
v = fread(fid, size_factor(2, :) .* frame_size, sprintf('%s=>%s', precision, precision))';
fclose(fid);
end