function cam02jab = xyz2cam02jab(xyz, varargin)
% DESCRIPTION
%   It converts CIE XYZ data to CAM02-UCS Jab.
% SYNTAX
%   cam02jab = xyz2cam02jab(xyz);
%   cam02jab = xyz2cam02jab(xyz, Name, Value...);
% INPUT
%   xyz:                    n*3 array or m*n*3 image.
% OPTIONS
%   'ViewingCondition':     'average', 'dim', 'dark'. Default is 'average'.
%   'ReferenceIlluminant':  A string for reference illuminant white point. Default is 'D65'.
%   'TestIlluminant':       A string for test illuminant white point. Default is 'D65'.
%   'RefWhiteAbsLum':       A scalar. Absolute luminance of reference white in cd/m^2. Noted as L_W.
%   'CATDegree':            A scalar. Degree of color adaptation. Between in [0.65, 1] in
%                           practice. Default is calculated from L_A using intermediate formula.

p = inputParser;
p.addRequired('xyz', @colorutil.image_shape_validator);
p.addParameter('ViewingCondition', 'average', @(x) strcmpi(x, 'average') || strcmpi(x, 'dim') || strcmpi(x, 'dark'));
p.addParameter('ReferenceIlluminant', 'D65', @ischar);
p.addParameter('TestIlluminant', 'D65', @ischar);
p.addParameter('RefWhiteAbsLum', 100, @(x) isnumeric(x) && isscalar(x));
p.addParameter('CATDegree', [], @(x) isscalar(x) && isnumeric(x) && x >= 0 && x <= 1);
p.parse(xyz, varargin{:});

input_size = size(xyz);
xyz = reshape(xyz, [], 3);

[F, c, ~] = get_viewing_condition_param(p.Results.ViewingCondition);
n = 1/5;    % Yb / Yw

w_ref = colorspace.get_white_point(p.Results.ReferenceIlluminant) * p.Results.RefWhiteAbsLum;
w = colorspace.get_white_point(p.Results.TestIlluminant) * 100;
L_A = p.Results.RefWhiteAbsLum * n;     % Average gray. Unknown background luminance level.
M_CAT02 = [0.7328, 0.4296, -0.1624;
    -0.7036, 1.6975, 0.0061;
    0.0030, 0.0136, 0.9834];            % LMS = XYZ * M_CAT02
lms = xyz * M_CAT02';
lms_wr = w_ref * M_CAT02';
lms_w = w * M_CAT02';

% CAT
if isempty(p.Results.CATDegree)
    D = F * (1 - exp(-(L_A + 42) / 92) / 3.6);
else
    D = p.Results.CATDegree;
end
lms_c = (w(2) / w_ref(2) * lms_wr ./ lms_w * D + 1 - D) .* lms;
lms_c_w = (w(2) / w_ref(2) * lms_wr ./ lms_w * D + 1 - D) .* lms_w;

% Post-adaptation
M_H = [0.38971, 0.68898, -0.07868;
    -0.22981, 1.18340, 0.04641;
    0, 0, 1];
M = M_H / M_CAT02;
lms_prim = lms_c * M';
lms_prim_w = lms_c_w * M';

k = 1 / (5 * L_A + 1);
F_L = 0.2 * k^4 * (5 * L_A) + 0.1 * (1 - k^4)^2 * nthroot(5 * L_A, 3);
lms_a_prim = max(lms_prim * F_L / 100, 0).^0.42;
lms_a_prim = 400 * lms_a_prim ./ (27.13 + lms_a_prim) + 0.1;
lms_a_prim_w = (lms_prim_w * F_L / 100).^0.42;
lms_a_prim_w = 400 * lms_a_prim_w ./ (27.13 + lms_a_prim_w) + 0.1;

% Apperance model
ab = lms_a_prim * [1, 1/9; -12/11, 1/9; 1/11, -2/9];
Nbb = 0.725 * n ^ -0.2;
A = (lms_a_prim * [2; 1; 1/20] - 0.305) * Nbb;
A_w = (lms_a_prim_w * [2; 1; 1/20] - 0.305) * Nbb;
J = 100 * (A ./ A_w) .^ (c * (1.48 + sqrt(n)));
cam02jab = reshape([J, ab], input_size);
end


function [F, c, Nc] = get_viewing_condition_param(condition)
if strcmpi(condition, 'average')
    F = 1.0;
    c = 0.69;
    Nc = 1.0;
elseif strcmpi(condition, 'dim')
    F = 0.9;
    c = 0.59;
    Nc = 0.9;
elseif strcmpi(condition, 'dark')
    F = 0.8;
    c = 0.525;
    Nc = 0.8;
end
end
