function o = hlg_eotf(e)
% DESCRIPTION
%   It converts non linear HLG signal to display light signal.
%   See [HLG](https://en.wikipedia.org/wiki/Hybrid_log%E2%80%93gamma) for detail.
% SYNTAX
%   o = hlg_eotf(e)
% INPUT
%   e:        n*3 array or m*n*3 image. Non linear HLG signal (RGB).
%             Because it invokes colorspace.hlg_ootf, so input must be RGB data.
% OUTPUT
%   o:        The same shape to input e. Linear display signal (RGB).

p = inputParser;
p.addRequired('rgb', @colorutil.image_shape_validator);
p.parse(e);

Lb = 0;
Lw = 1000;
gamma = 1.2;
beta = sqrt(3 * (Lb / Lw) ^ (1 / gamma));

o = colorspace.hlg_inverse_oetf(max(0, (1 - beta) * e + beta));
o = colorspace.hlg_ootf(o);
end