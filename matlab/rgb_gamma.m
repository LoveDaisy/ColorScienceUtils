function rgb = rgb_gamma(rgb_lin, varargin)
% DESCRIPTION
%   Covert RGB data from linear RGB to nonlinear RGB.
% SYNTAX
%   rgb = rgb_gamma(rgb_lin);
%   rgb = rgb_gamma(rgb_lin, cs_name);
%   rgb = rgb_gamma(rgb_lin, param);
% INPUT
%   rgb:                n*3 matrix, each row represents a color.
%   cs_name:            A string of colorspace name. See internal.cs_name_validator for detail.
%   param:              A struct from internal.get_colorspace_param;
% OUTPUT
%   rgb:                n*3 matrix, the converted color.

p = inputParser;
p.addRequired('rgb', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.addOptional('param', 'sRGB', @internal.cs_validator);
p.parse(rgb_lin, varargin{:});

if ischar(p.Results.param)
    param = internal.get_colorspace_param(p.Results.param);
else
    param = p.Results.param;
end

g = 1 / param.gamma;
x0 = ((1 + param.alpha) * (1 - g) / param.alpha)^(-1 / g);
k = (1 + param.alpha) * x0^(g - 1);
idx = abs(rgb_lin) < x0;

rgb = rgb_lin;
rgb(idx) = rgb(idx) * k;
rgb(~idx) = sign(rgb(~idx)) .* abs(rgb(~idx)).^g * (1 + param.alpha) - param.alpha;
end