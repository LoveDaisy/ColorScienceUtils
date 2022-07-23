function rgb = rgb_compression(rgb, varargin)
% DESCRIPTION
%   If input rgb data is out of range [0, 1], then adjust it back within range,
%   and try to keep it perceptively the same.
% SYNTAX
%   rgb = rgb_compression(rgb);
%   rgb = rgb_compression(rgb, cs_name);
%   rgb = rgb_compression(rgb, param);
%   rgb = rgb_compression(..., method);
%   rgb = rgb_compression(..., Name, Value...);
% INPUT
%   rgb:                n*3 matrix. Each row represents a color.
%   cs_name:            A string for colorspace name. Default is 'sRGB'.
%                       See internal.rgb_name_validator for detail.
%   param:              A struct returned by colorspace.get_param.
%   method:             Method used for adjustment. Default is 'Greying'.
%                       See internal.rgb_compression_validator
% PARAMETER
%   'Linear':           {true} | false. Whether input RGB is in linear space.

p = inputParser;
p.addRequired('rgb', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.addOptional('param', 'sRGB', @internal.rgb_param_validator);
p.addOptional('method', 'Greying', @internal.rgb_compression_validator);
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
        rgb = greying_xyz(rgb, param);
    case 'greyingxyz'
        rgb = greying_xyz(rgb, param);
    case 'greyinglab'
        rgb = greying_lab(rgb, param);
    case 'greyingictcp'
        rgb = greying_ictcp(rgb, param);
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


function rgb_lin = greying_xyz(rgb_lin, param)
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


function rgb_lin = greying_lab(rgb_lin, param)
% Greying in Lab space
m = colorspace.xyz_rgb_mat(param);
num = size(rgb_lin, 1);
lab = colorspace.xyz2lab(rgb_lin / m);
lab_E = [lab(:, 1), zeros(num, 2)];

% Binary search for a0
fun = @(a, idx) min(colorspace.lab2xyz(a(idx) .* lab(idx, :) + ...
    (1 - a(idx)) .* lab_E(idx, :)) * m, [], 2);
a0 = internal.solve_equation_binary(fun, ...
    zeros(num, 1), zeros(num, 1), ones(num, 1));

% Binary search for a1
fun = @(a, idx) max(colorspace.lab2xyz(a(idx) .* lab(idx, :) + ...
    (1 - a(idx)) .* lab_E(idx, :)) * m, [], 2);
a1 = internal.solve_equation_binary(fun, ...
    ones(num, 1), zeros(num, 1), ones(num, 1));

a = min(a0, a1);

lab = a .* lab + (1 - a) .* lab_E;
lab(lab(:, 1) >= 1, 2:3) = 0;
rgb_lin = colorspace.lab2xyz(lab) * m;
end


function rgb_lin = greying_ictcp(rgb_lin, param)
% Greying in Lab space
m = colorspace.xyz_rgb_mat(param);
scale = 1;
num = size(rgb_lin, 1);
ictcp = colorspace.xyz2ictcp(rgb_lin / m * scale);
ictcp_E = [ictcp(:, 1), zeros(num, 2)];

% Binary search for a0
fun = @(a, idx) min(colorspace.ictcp2xyz(a(idx) .* ictcp(idx, :) + ...
    (1 - a(idx)) .* ictcp_E(idx, :)) * m / scale, [], 2);
a0 = internal.solve_equation_binary(fun, zeros(num, 1), zeros(num, 1), ones(num, 1));

% Binary search for a1
fun = @(a, idx) max(colorspace.ictcp2xyz(a(idx) .* ictcp(idx, :) + ...
    (1 - a(idx)) .* ictcp_E(idx, :)) * m / scale, [], 2);
a1 = internal.solve_equation_binary(fun, ones(num, 1), zeros(num, 1), ones(num, 1));

a = min(a0, a1);

ictcp = a .* ictcp + (1 - a) .* ictcp_E;
ictcp(ictcp(:, 1) >= internal.pq_inverse_eotf(scale), 2:3) = 0;
rgb_lin = colorspace.ictcp2xyz(ictcp) * m / scale;
end
