function yuv = rgb2ycbcr(rgb, varargin)
% DESCRIPTION
%   It converts RGB color to YCbCr data, with given colorspace parameter
%   (may get from colorspace.get_param).
% SYNTAX
%   yuv = rgb2ycbcr(rgb)
%   yuv = rgb2ycbcr(rgb, rgb_name)
%   yuv = rgb2ycbcr(rgb, rgb_param)
%   yuv = rgb2ycbcr(..., target_yuv_name)
%   yuv = rgb2ycbcr(..., target_yuv_param)
% INPUT
%   rgb:                n*3 array, each row represents a color; or m*n*3 array for 3-channel image.
%   rgb_name:           A string for colorspace name. Default is 'sRGB'.
%                       See colorspace.util.cs_name_validator for detail.
%   rgb_param:          A struct returned from colorspace.get_param.
%   target_yuv_name:    A string for colorspace name. Default is '709'.
%                       See colorspace.util.cs_name_validator for detail.
%   target_yuv_param:   A struct returned from colorspace.get_param.
% OUTPUT
%   yuv:                The smae shape to input rgb. uv components are in range [-0.5, 0.5]

input_size = size(rgb);

p = inputParser;
p.addRequired('rgb', @(x) isnumeric(x) && ((length(size(x)) == 2 && size(x, 2) == 3) || ...
    (length(size(x)) == 3 && size(x, 3) == 3)));
p.addOptional('rgb_param', 'sRGB', @colorspace.util.cs_param_validator);
p.addOptional('yuv_param', '709', @colorspace.util.cs_param_validator);
p.parse(rgb, varargin{:});

if ischar(p.Results.rgb_param)
    rgb_param = colorspace.get_param(p.Results.rgb_param);
else
    rgb_param = p.Results.rgb_param;
end
if ischar(p.Results.yuv_param)
    yuv_param = colorspace.get_param(p.Results.yuv_param);
else
    yuv_param = p.Results.yuv_param;
end

coef_y = yuv_param.yuv(1:3);
coef_cb = yuv_param.yuv(4);
coef_cr = yuv_param.yuv(5);

% Convert to target RGB space
rgb = colorspace.rgb2rgb(rgb, rgb_param, yuv_param);

% Construct the matrix:
%   yuv = rgb * m;
m = [coef_y; ([0, 0, 1] - coef_y) / coef_cb; ([1, 0, 0] - coef_y) / coef_cr]';
yuv = reshape(rgb, [], 3) * m;
yuv = reshape(yuv, input_size);
end