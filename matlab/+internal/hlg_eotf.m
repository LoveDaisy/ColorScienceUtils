function o = hlg_eotf(e)
% DESCRIPTION
%   It converts non linear HLG signal to display light signal.
%   See [HLG](https://en.wikipedia.org/wiki/Hybrid_log%E2%80%93gamma) for detail.
% SYNTAX
%   o = hlg_eotf(e)
% INPUT
%   e:        n*3 array. Non linear HLG signal (RGB).
% OUTPUT
%   o:        n*3 array. Linear display signal (RGB).

p = inputParser;
p.addRequired('rgb', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.parse(e);

Lb = 0;
Lw = 1000;
gamma = 1.2;
beta = sqrt(3 * (Lb / Lw) ^ (1 / gamma));

o = internal.hlg_inverse_oetf(max(0, (1 - beta) * e + beta));
o = internal.hlg_ootf(o);
end