function rgb = rgb_gamma(rgb, varargin)
% DESCRIPTION
%   Covert RGB data between linear RGB and nonlinear RGB.
% INPUT
%   rgb:                n*3 matrix, each row represents a color.
% PARAMETER
%   'ColorSpace':       One of 'sRGB', 'AdobeRGB'. Default is 'sRGB'
%   'Method':           One of 'l2n', meaning linear-to-nonlinear, or 'n2l',
%                       meaning nonlinear-to-linear. Default is 'l2n'.
% OUTPUT
%   rgb:                n*3 matrix, the converted color.

p = inputParser;
p.addRequired('rgb', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.addParameter('ColorSpace', 'sRGB', @internal.colorspace_validator);
p.addParameter('Method', 'l2n', @(x) ischar(x) && ...
    (strcmpi(x, 'n2l') || strcmpi(x, 'l2n')));
p.parse(rgb, varargin{:});

param = get_colorspace_param(p.Results.ColorSpace);

if strcmpi(p.Results.Method, 'l2n')
    g = 1 / param.gamma;
    x0 = ((1 + param.alpha) * (1 - g) / param.alpha)^(-1 / g);
    k = (1 + param.alpha) * x0^(g - 1);
    idx = rgb < x0;
    rgb(idx) = rgb(idx) * k;
    rgb(~idx) = rgb(~idx).^g * (1 + param.alpha) - param.alpha;
else
    x0 = param.alpha / (param.gamma - 1);
    k = (x0 * param.gamma / (1 + param.alpha))^param.gamma * (param.gamma - 1) / param.alpha;
    idx = rgb < x0;
    rgb(idx) = rgb(idx) * k;
    rgb(~idx) = ((rgb(~idx) + param.alpha) / (1 + param.alpha)).^param.gamma;
end
end