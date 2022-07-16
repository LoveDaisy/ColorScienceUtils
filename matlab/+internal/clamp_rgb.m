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

switch lower(p.Results.method)
    case 'none'
        return;
    case 'clip'
        rgb = clip(rgb);
        return
end

if ~p.Results.Linear
    rgb = colorspace.rgb_ungamma(rgb, param);
end
switch lower(p.Results.method)
    case 'desat'
        rgb = desat(rgb);
    case 'greying'
        rgb = greying(rgb, param);
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


function rgb_lin = minitp(rgb_lin, param)
% Scale in XYZ space
m1 = colorspace.xyz_rgb_mat(param);     % xyz to rgb matrix
m2 = colorspace.xyz_lms_mat();          % xyz to lms matrix
m3 = [2048, 2048, 0;
    6610, -13613, 7003;
    17933, -17390, -543]' / 4096;       % lms to ictcp matrix

scale = 150;
rgb_ictcp = @(x) colorspace.pq_inverse_eotf(x * scale / m1 * m2) * m3;
ictcp_rgb = @(x) colorspace.pq_eotf(x / m3) / m2 * m1 / scale;

ictcp = rgb_ictcp(rgb_lin);

options = optimoptions(@fminunc, 'Display', 'off');
% options = optimset('Display', 'off', 'MaxFunEvals', 1000);
f = @(x, c, lambda) log(norm(x .* [1, .5, 1]) + ...
    lambda * sum(max(abs(ictcp_rgb(x + c) - 0.5) - 0.5, 0)));

d_ictcp = zeros(size(ictcp));
for i = 1:size(ictcp, 1)
    dx0 = [0, -0.3*ictcp(i, 2:3)];
%     for lambda = exp(-1.6:.4:3.2)
%         [dx0, e, flag, info] = fminunc(@(x) f(x, ictcp(i, :), lambda), dx0, options);
%     end
    lambda = 1;
    [dx0, e, flag, info] = fminunc(@(x) f(x, ictcp(i, :), lambda), dx0, options);
    d_ictcp(i, :) = dx0;
end

rgb_lin = ictcp_rgb(ictcp + d_ictcp);
end
