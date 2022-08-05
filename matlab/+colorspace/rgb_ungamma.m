function rgb_lin = rgb_ungamma(rgb, varargin)
% DESCRIPTION
%   Covert RGB data from nonlinear RGB to linear RGB.
% SYNTAX
%   rgb_lin = rgb_gamma(rgb);
%   rgb_lin = rgb_gamma(rgb, cs_name);
%   rgb_lin = rgb_gamma(rgb, param);
% INPUT
%   rgb:                Any shape matrix. Non linear signal.
%   cs_name:            A string of colorspace name. See internal.cs_name_validator for detail.
%   param:              A struct from colorspace.get_param;
% OUTPUT
%   rgb_lin:            The same shape to input rgb.

p = inputParser;
p.addRequired('rgb', @(x) isnumeric(x));
p.addOptional('param', 'sRGB', @internal.cs_param_validator);
p.parse(rgb, varargin{:});

if ischar(p.Results.param)
    param = colorspace.get_param(p.Results.param);
else
    param = p.Results.param;
end

g = param.tsf(3);
a = param.tsf(1);
x0 = param.tsf(2) * param.tsf(4);
k = 1 / param.tsf(4);

assert(~isnan(g) && ~isnan(a));

if isnan(x0)
    x0 = a / (g - 1);
end
if isnan(k)
    k = (x0 * g / (1 + a))^g * (g - 1) / a;
end
idx = abs(rgb) < x0;

rgb_lin = rgb;
rgb_lin(idx) = rgb_lin(idx) * k;
rgb_lin(~idx) = sign(rgb_lin(~idx)) .* ((abs(rgb_lin(~idx)) + a) / (1 + a)).^g;
end