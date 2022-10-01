function o = hlg_inverse_ootf(o)
% DESCRIPTION
%   It maps display linear light to normalized scene linear light.
%   See [HLG](https://en.wikipedia.org/wiki/Hybrid_log%E2%80%93gamma) for detail.
% SYNTAX
%   o = hlg_inverse_ootf(o)
% INPUT
%   o:        n*3 array, or m*n*3 image. Input display linear light signal RGB. Range in [0, 1].
% OUTPUT
%   o:        The same shape of input o. Scene linear light (normalized).

p = inputParser;
p.addRequired('rgb', @colorutil.image_shape_validator);
p.parse(o);

input_size = size(o);

alpha = 1;
gamma = 1.2;
y_coef = [0.2627, 0.6780, 0.0593];

o = reshape(o, [], 3);
yd = max(o * y_coef', 1e-8);
yd = yd .^ (1 / gamma - 1);

o = o .* (alpha * yd);
o = reshape(o, input_size);
end