function rgb = ycbcr2rgb(yuv, varargin)
% DESCRIPTION
%   It converts YCbCr color to RGB color, with given colorspace parameter
%   (may get from colorspace.get_param).
% SYNTAX
%   rgb = ycbcr2rgb(yuv)
%   rgb = ycbcr2rgb(yuv, yuv_name)
%   rgb = ycbcr2rgb(yuv, yuv_param)
%   rgb = ycbcr2rgb(..., target_rgb_name)
%   rgb = ycbcr2rgb(..., target_rgb_param)
% INPUT
%   yuv:                n*3 array, each row represents a color; or m*n*3 array. uv components are in range [-0.5, 0.5].
%   yuv_name:           A string for colorspace name. Default is '709'.
%                       See colorutil.cs_name_validator for detail.
%   yuv_param:          A struct returned from colorspace.get_param.
%   target_rgb_name:    A string for colorspace name. Default is 'sRGB'.
%                       See colorutil.cs_name_validator for detail.
%   target_rgb_param:   A struct returned from colorspace.get_param.
% OUTPUT
%   rgb:                Same shape to input yuv.

input_size = size(yuv);

p = inputParser;
p.addRequired('yuv', @colorutil.image_shape_validator);
p.addOptional('yuv_param', '709', @colorutil.cs_param_validator);
p.addOptional('rgb_param', 'sRGB', @colorutil.cs_param_validator);
p.parse(yuv, varargin{:});

if ischar(p.Results.yuv_param)
    yuv_param = colorspace.get_param(p.Results.yuv_param);
else
    yuv_param = p.Results.yuv_param;
end
if ischar(p.Results.rgb_param)
    rgb_param = colorspace.get_param(p.Results.rgb_param);
else
    rgb_param = p.Results.rgb_param;
end

coef_y = yuv_param.yuv(1:3);
coef_cb = yuv_param.yuv(4);
coef_cr = yuv_param.yuv(5);

% Construct the matrix:
%   yuv = rgb * m;
m = [coef_y; ([0, 0, 1] - coef_y) / coef_cb; ([1, 0, 0] - coef_y) / coef_cr]';
rgb = reshape(yuv, [], 3) / m;

% Then convert to target RGB space
rgb = colorspace.rgb2rgb(rgb, yuv_param, rgb_param);
rgb = reshape(rgb, input_size);
end