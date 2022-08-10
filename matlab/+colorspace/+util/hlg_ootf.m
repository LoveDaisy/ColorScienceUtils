function o = hlg_ootf(o)
% DESCRIPTION
%   It maps relative scene linear light to display linear light.
%   See [HLG](https://en.wikipedia.org/wiki/Hybrid_log%E2%80%93gamma) for detail.
% SYNTAX
%   o = hlg_ootf(o)
% INPUT
%   o:        n*3 array. Input scene linear light signal RGB. Range in [0, 1].
% OUTPUT
%   o:        The same shape of input o. Display linear light.

p = inputParser;
p.addRequired('rgb', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 3}));
p.parse(o);

alpha = 1;
gamma = 1.2;
y_coef = [0.2627, 0.6780, 0.0593];

ys = o * y_coef';
ys = ys .^ (gamma - 1);

o = o .* (alpha * ys);
end