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
tol = 1e-8;

lab_E = [lab(:, 1), zeros(num, 2)];
rgb_E = colorspace.lab2xyz(lab_E) * m;

% Binary search for a0
al = zeros(num, 1);
au = ones(num, 1);
idx = min(rgb_lin, [], 2) >= -tol | max(rgb_E, [], 2) <= tol;
al(idx) = au(idx);
while max(au - al) > 1e-4
    rgbl = colorspace.lab2xyz(al .* lab + (1 - al) .* lab_E) * m;
    rgbu = colorspace.lab2xyz(au .* lab + (1 - au) .* lab_E) * m;
    minl = min(rgbl, [], 2);
    minu = min(rgbu, [], 2);
    idx = find(minl .* minu <= 0);
    am = (al(idx) + au(idx)) / 2;
    rgbm = colorspace.lab2xyz(am .* lab(idx, :) + (1 - am) .* lab_E(idx, :)) * m;
    minm = min(rgbm, [], 2);
    
    tmp_idx = minm .* minl(idx) >= 0;
    al(idx(tmp_idx)) = am(tmp_idx);
    au(idx(~tmp_idx)) = am(~tmp_idx);
end
a0 = (al + au) / 2;

% Binary search for a1
al = zeros(num, 1);
au = ones(num, 1);
idx = max(rgb_lin, [], 2) <= 1 + tol | min(rgb_E, [], 2) >= 1 - tol;
al(idx) = au(idx);
while max(au - al) > 1e-4
    rgbl = colorspace.lab2xyz(al .* lab + (1 - al) .* lab_E) * m;
    rgbu = colorspace.lab2xyz(au .* lab + (1 - au) .* lab_E) * m;
    maxl = max(rgbl, [], 2);
    maxu = max(rgbu, [], 2);
    idx = find((maxl - 1) .* (maxu - 1) <= 0);
    am = (al(idx) + au(idx)) / 2;
    rgbm = colorspace.lab2xyz(am .* lab(idx, :) + (1 - am) .* lab_E(idx, :)) * m;
    maxm = max(rgbm, [], 2);
    
    tmp_idx = (maxm - 1) .* (maxl(idx) - 1) >= 0;
    al(idx(tmp_idx)) = am(tmp_idx);
    au(idx(~tmp_idx)) = am(~tmp_idx);
end
a1 = (al + au) / 2;
a = min(a0, a1);

lab = a .* lab + (1 - a) .* lab_E;
lab(lab(:, 1) >= 1, 2:3) = 0;
rgb_lin = colorspace.lab2xyz(lab) * m;
end


function rgb_lin = greying_ictcp(rgb_lin, param)
% Greying in Lab space
m = colorspace.xyz_rgb_mat(param);
tol = 1e-8;
scale = 1;
num = size(rgb_lin, 1);
ictcp = colorspace.xyz2ictcp(rgb_lin / m * scale);

ictcp_E = [ictcp(:, 1), zeros(num, 2)];
rgb_E = colorspace.ictcp2xyz(ictcp_E) * m / scale;
minE = min(rgb_E, [], 2);
maxE = max(rgb_E, [], 2);

% Binary search for a0
% FIXME!!! rgb -> ictcp nonlinear near blue hue.
al = zeros(num, 1);
au = ones(num, 1);
idx = sum(rgb_lin .* rgb_E >= 0, 2) == 3;
al(idx) = au(idx);
while max(au - al) > 1e-4
    rgbl = colorspace.ictcp2xyz(al .* ictcp + (1 - al) .* ictcp_E) * m / scale;
    rgbu = colorspace.ictcp2xyz(au .* ictcp + (1 - au) .* ictcp_E) * m / scale;
    minl = min(rgbl, [], 2);
    minu = min(rgbu, [], 2);
    idx = find(minl .* minu <= 0);
    am = (al(idx) + au(idx)) / 2;
    rgbm = colorspace.ictcp2xyz(am .* ictcp(idx, :) + (1 - am) .* ictcp_E(idx, :)) * m / scale;
    minm = min(rgbm, [], 2);
    
    tmp_idx = minm .* minE(idx) < 0;
    au(idx(tmp_idx)) = am(tmp_idx);
    if any(tmp_idx)
        continue;
    end
    
    tmp_idx = minm .* minl(idx) >= 0;
    al(idx(tmp_idx)) = am(tmp_idx);
    au(idx(~tmp_idx)) = am(~tmp_idx);
end
a0 = (al + au) / 2;

% Binary search for a1
al = zeros(num, 1);
au = ones(num, 1);
idx = max(rgb_lin, [], 2) <= 1 + tol | max(rgb_E, [], 2) >= 1 - tol;
al(idx) = au(idx);
while max(au - al) > 1e-4
    rgbl = colorspace.ictcp2xyz(al .* ictcp + (1 - al) .* ictcp_E) * m / scale;
    rgbu = colorspace.ictcp2xyz(au .* ictcp + (1 - au) .* ictcp_E) * m / scale;
    maxl = max(rgbl, [], 2);
    maxu = max(rgbu, [], 2);
    idx = find((maxl - 1) .* (maxu - 1) <= 0);
    am = (al(idx) + au(idx)) / 2;
    rgbm = colorspace.ictcp2xyz(am .* ictcp(idx, :) + (1 - am) .* ictcp_E(idx, :)) * m / scale;
    maxm = max(rgbm, [], 2);
    
    tmp_idx = maxm .* maxE(idx) < 0;
    au(idx(tmp_idx)) = am(tmp_idx);
    if any(tmp_idx)
        continue;
    end
    
    tmp_idx = (maxm - 1) .* (maxl(idx) - 1) >= 0;
    al(idx(tmp_idx)) = am(tmp_idx);
    au(idx(~tmp_idx)) = am(~tmp_idx);
end
a1 = (al + au) / 2;
a = min(a0, a1);

ictcp = a .* ictcp + (1 - a) .* ictcp_E;
ictcp(ictcp(:, 1) >= internal.pq_inverse_eotf(scale), 2:3) = 0;  % FIXME
rgb_lin = colorspace.ictcp2xyz(ictcp) * m / scale;
end
