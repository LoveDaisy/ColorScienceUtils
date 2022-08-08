function e = hlg_oetf(o)
% DESCRIPTION
%   It converts linear light signal to non-linear electronic signal. Also known as ARIB STD-B67.
%   See [HLG](https://en.wikipedia.org/wiki/Hybrid_log%E2%80%93gamma) for detail.
% SYNTAX
%   e = hlg_oetf(o)
% INPUT
%   o:        Any shape array. Input linear light signal. Range in [0, 1] (as defined in Rec. 2100).
% OUTPUT
%   e:        The same shape of input o. Non linear electronic signal.

a = 0.17883277;
b = 1 - 4 * a;
c = 0.5 - a * log(4 * a);

lower_idx = o < 1/12;
e = o;
e(lower_idx) = sqrt(3 * o(lower_idx));
e(~lower_idx) = a * log(12 * o(~lower_idx) - b) + c;
end