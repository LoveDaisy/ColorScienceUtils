function rgb = clamp_rgb(rgb, varargin)
% DESCRIPTION
%   If input rgb data is out of range [0, 1], then adjust it back within range,
%   and try to keep it perceptively the same.
% SYNTAX
%   rgb = clamp_rgb(rgb);
%   rgb = clamp_rgb(rgb, cs_name);
%   rgb = clamp_rgb(rgb, param);
%   rgb = clamp_rgb(..., method);
%   rgb = clamp_rgb(..., Name, Value...);
% INPUT
%   rgb:                n*3 matrix. Each row represents a color.
%   cs_name:            A string for colorspace name. Default is 'sRGB'.
%                       See internal.cs_name_validator for detail.
%   param:              A struct returned by colorspace.get_param.
%   method:             Method used for adjustment. Default is 'Greying'.
%                       See internal.rgb_clamping_validator
% PARAMETER
%   'Linear':           {true} | false. Whether input RGB is in linear space.

p = inputParser;
p.addRequired('rgb', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.addOptional('param', 'sRGB', @internal.cs_validator);
p.addOptional('method', 'Greying', @internal.rgb_clamping_validator);
p.addParameter('Linear', true, @(x) islogical(x) && isscalar(x));
p.parse(rgb, varargin{:});

if ischar(p.Results.param)
    param = colorspace.get_param(p.Results.param);
else
    param = p.Results.param;
end

if ~p.Results.Linear
    rgb = colorspace.rgb_ungamma(rgb, param);
end

switch lower(p.Results.method)
    case 'clip'
        rgb = clip(rgb);
    case 'desat'
        rgb = desat(rgb);
    case 'greying'
        rgb = greying(rgb, param);
    case 'minuv'
        rgb = minuv(rgb, param);
    case 'minitp'
        rgb = minitp(rgb, param);
    otherwise
        warning('Cannot recognize method! Use clip as default!');
        rgb = clip(rgb);
end

if ~p.Results.Linear
    rgb = colorspace.rgb_gamma(rgb, param);
end
rgb = min(max(rgb, 0), 1);
end


function rgb = clip(rgb)
% Clip method
rgb = min(max(rgb, 0), 1);
end


function rgb_lin = desat(rgb_lin)
% De-saturating directly in RGB space
gray = rgb2gray(rgb_lin);   % Uses YUV coefficients to make the conversion.

a0 = (0 - gray) ./ (rgb_lin - gray);
a1 = (1 - gray) ./ (rgb_lin - gray);
a0 = min(a0, 1);
a1 = min(a1, 1);
a0(a0 < 0) = inf;
a1(a1 < 0) = inf;

a = min(min(a0, a1), [], 2);
rgb_lin = a .* rgb_lin + (1 - a) .* gray;
end


function rgb_lin = greying(rgb_lin, param)
% De-saturating in XYZ space
m = colorspace.xyz_rgb_mat(param);
xyz = rgb_lin / m;
gray = xyz(:, 2) * param.w;

a0 = (0 - gray * m) ./ ((xyz - gray) * m);
a1 = (1 - gray * m) ./ ((xyz - gray) * m);
a0 = min(a0, 1);
a1 = min(a1, 1);
a0(a0 < 0) = inf;
a1(a1 < 0) = inf;

a = min(min(a0, a1), [], 2);
xyz = a .* xyz + (1 - a) .* gray;
rgb_lin = xyz * m;
end


function rgb_lin = minuv(rgb_lin, param)
% De-saturating directly in Luv space
m = colorspace.xyz_rgb_mat(param);
xyz = rgb_lin / m;
Y = xyz(:, 2);
uv = [4 * xyz(:, 1), 9 * xyz(:, 2)] ./ (xyz * [1; 15; 3]);
gray = Y * param.w;
uv_n = [4 * gray(:, 1), 9 * gray(:, 2)] ./ (gray * [1; 15; 3]);

cu = Y * (9 * m(1, :) - 3 * m(3, :));
cv0 = Y * 4 * m(2, :) - Y * 20 * m(3, :) - 4 * 0;
cv1 = Y * 4 * m(2, :) - Y * 20 * m(3, :) - 4 * 1;
a0 = -(uv_n(:, 1) .* cu + uv_n(:, 2) .* cv0 + Y * 12 * m(3, :)) ./ ...
    ((uv(:, 1) - uv_n(:, 1)) .* cu + (uv(:, 2) - uv_n(:, 2)) .* cv0);
a1 = -(uv_n(:, 1) .* cu + uv_n(:, 2) .* cv1 + Y * 12 * m(3, :)) ./ ...
    ((uv(:, 1) - uv_n(:, 1)) .* cu + (uv(:, 2) - uv_n(:, 2)) .* cv1);
a0 = min(a0, 1);
a1 = min(a1, 1);
a0(a0 < 0) = inf;
a1(a1 < 0) = inf;
a = min(min(a0, a1), [], 2);

uv = a .* uv + (1 - a) .* uv_n;
xyz = [9 * uv(:, 1), 4 * uv(:, 2), 12 - 3 * uv(:, 1) - 20 * uv(:, 2)] .* Y ./ (4 * uv(:, 2));
rgb_lin = xyz * m;
end


function rgb_lin = minitp(rgb_lin, param)
% Scale in XYZ space
m = colorspace.xyz_rgb_mat(param);
xyz = rgb_lin * m;
lms = colorspace.xyz2lms(xyz);
end
