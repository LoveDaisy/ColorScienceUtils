function yuv = merge_ycbcr_channel(y, u, v)
% DESCRIPTION
%   It merge separated YUV components into a 3-channel image. It resizes uv components to fit
%   size of y component if necessary.
% SYNTAX
%   yuv = merge_ycbcr_channel(y, u, v);
% INPUT
%   y:              m*n array.
%   uv:             m/2*n/2 array (for 420), or m*n/2 array (for 422), or m*n array (for 444)
% OUTPUT
%   yuv:            m*n*3 image.

p = inputParser;
p.addRequired('y', @(x) length(size(x)) == 2);
p.addRequired('u', @(x) length(size(x)) == 2);
p.addRequired('v', @(x) length(size(x)) == 2);

y_size = size(y);
u_size = size(u);
v_size = size(v);

if any(y_size ~= u_size)
    u = imresize(u, y_size, 'nearest');
end
if any(y_size ~= v_size)
    v = imresize(v, y_size, 'nearest');
end

yuv = cat(3, y, u, v);
end