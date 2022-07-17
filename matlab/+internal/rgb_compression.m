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
%                       See internal.cs_name_validator for detail.
%   param:              A struct returned by colorspace.get_param.
%   method:             Method used for adjustment. Default is 'Greying'.
%                       See internal.rgb_compression_validator
% PARAMETER
%   'Linear':           {true} | false. Whether input RGB is in linear space.

p = inputParser;
p.addRequired('rgb', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.addOptional('param', 'sRGB', @internal.cs_validator);
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
        rgb = greying(rgb, param);
    case 'sgck'
        rgb = sgck_lab(rgb, param);
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


function rgb_lin = sgck_lab(rgb_lin, param)
% SGCK algorithm
m = colorspace.xyz_rgb_mat(param);
rgb_pri = [0, 0, 0;
    0, 0, 1;
    0, 1, 0;
    0, 1, 1;
    1, 0, 0;
    1, 0, 1;
    1, 1, 0;
    1, 1, 1];
xyz_pri = rgb_pri / m;
lab_pri = colorspace.xyz2lab(xyz_pri);
[~, idx] = max(sum(lab_pri(:, 2:3).^2, 2));
lab_E = [lab_pri(idx, 1), 0, 0];
lab = colorspace.xyz2lab(rgb_lin / m);
num = size(rgb_lin, 1);

al = zeros(num, 1);
au = ones(num, 1);
d = max(sum(au - al, 2));
while d > 1e-4
    rgbl = colorspace.lab2xyz(al .* lab + (1 - al) .* lab_E) * m;
    rgbu = colorspace.lab2xyz(au .* lab + (1 - au) .* lab_E) * m;
    idx = find(min(rgbl, [], 2) < 0 | max(rgbl, [], 2) > 1 | ...
        min(rgbu, [], 2) < 0 | max(rgbu, [], 2) > 1);
    am = (al(idx) + au(idx)) / 2;
    rgbm = colorspace.lab2xyz(am .* lab(idx, :) + (1 - am) .* lab_E(idx, :)) * m;
    
    tmp_idx = rgbm .* (rgbl(idx)) > 0;
    al(idx(tmp_idx)) = am(tmp_idx);
    tmp_idx = rgbm .* (rgbu(idx)) > 0;
    au(idx(tmp_idx)) = am(tmp_idx);
    d = max(sum(au - al, 2));
end

lab = a .* lab + (1 - a) .* lab_E;
rgb_lin = colorspace.lab2xyz(lab) * m;
end
