function rgb = rgb_gamma(rgb_lin, varargin)
% DESCRIPTION
%   Covert RGB data from linear RGB to nonlinear RGB.
% SYNTAX
%   rgb = rgb_gamma(rgb_lin);
%   rgb = rgb_gamma(rgb_lin, cs_name);
%   rgb = rgb_gamma(rgb_lin, param);
% INPUT
%   rgb:                n*3 matrix, each row represents a color.
%   cs_name:            A string of colorspace name. See internal.rgb_name_validator for detail.
%   param:              A struct from colorspace.get_param;
% OUTPUT
%   rgb:                n*3 matrix, the converted color.

p = inputParser;
p.addRequired('rgb', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.addOptional('param', 'sRGB', @internal.rgb_param_validator);
p.parse(rgb_lin, varargin{:});

if ischar(p.Results.param)
    param = colorspace.get_param(p.Results.param);
else
    param = p.Results.param;
end

g = 1 / param.tsf(3);
a = param.tsf(1);
x0 = param.tsf(2);
k = param.tsf(4);

assert(~isnan(g) && ~isnan(a));

if isnan(x0)
    x0 = ((1 + a) * (1 - g) / a)^(-1 / g);
end
if isnan(k)
    k = (1 + a) * x0^(g - 1);
end
idx = abs(rgb_lin) < x0;

rgb = rgb_lin;
rgb(idx) = rgb(idx) * k;
rgb(~idx) = sign(rgb(~idx)) .* abs(rgb(~idx)).^g * (1 + a) - a;
end