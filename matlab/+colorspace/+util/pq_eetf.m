function e = pq_eetf(e, varargin)
% DESCRIPTION
%   It applies the EETF for PQ, defined in BT. 2390.
% SYNTAX
%   e = pq_eetf(e)
%   e = pq_eetf(e, target_Lbw)
% INPUT
%   e:                Any shape array. The input (scene or original display) PQ signal.
%   target_Lbw:       2*1 vector. The target display Lb (Lmin) and Lw (Lmax).
% OUTPUT
%   e:                The same shape to input e.

p = inputParser;
p.addRequired('e', @isnumeric);
p.addOptional('targetLbw', [0.01, 1000], @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 2}));
p.parse(e, varargin{:});

master_Lbw = [0, 10000];
target_Lbw = p.Results.targetLbw;

f = @colorspace.util.pq_inverse_eotf;
e1 = (e - f(master_Lbw(1))) ./ (f(master_Lbw(2)) - f(master_Lbw(1)));
lum_min = (f(target_Lbw(1)) - f(master_Lbw(1))) / (f(master_Lbw(2)) - f(master_Lbw(1)));
lum_max = (f(target_Lbw(2)) - f(master_Lbw(1))) / (f(master_Lbw(2)) - f(master_Lbw(1)));

ks = 1.5 * lum_max - 0.5;
b = lum_min;

e2_idx = e1 < ks;
e2 = e1;
e2(~e2_idx) = pfunc(e1(~e2_idx), ks, lum_max);
e3 = e2 + b * (1 - e2).^4;
e = e3 * (f(master_Lbw(2)) - f(master_Lbw(1))) + f(master_Lbw(1));
end


function y = pfunc(x, ks, lum_max)
t = @(x) (x - ks) / (1 - ks);
y = (2 * t(x).^3 - 3 * t(x).^2 + 1) * ks + (t(x).^3 - 2 * t(x).^2 + t(x)) * (1 - ks) + (-2 * t(x).^3 + 3 * t(x).^2) * lum_max;
end