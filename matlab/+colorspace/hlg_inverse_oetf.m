function o = hlg_inverse_oetf(e)
% DESCRIPTION
%   It is the inverse of hlg_oetf.
%   See [HLG](https://en.wikipedia.org/wiki/Hybrid_log%E2%80%93gamma) for detail.
% SYNTAX
%   o = hlg_inverse_oetf(e)
% INPUT
%   e:          Any shape array. Non linear electronic signal.
% OUTPUT
%   o:          The same shape of input e.

a = 0.17883277;
b = 1 - 4 * a;
c = 0.5 - a * log(4 * a);

lower_idx = e < 0.5;
o = e;
o(lower_idx) = e(lower_idx).^2 / 3;
o(~lower_idx) = (exp((e(~lower_idx) - c) / a) + b) / 12;
end