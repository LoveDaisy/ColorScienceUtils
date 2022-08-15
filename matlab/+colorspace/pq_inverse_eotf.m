function e = pq_inverse_eotf(o)
% DESCRIPTION
%   It converts linear optial luminance o to nonlinear electro value e.
% SYNTAX
%   e = pq_inverse_eotf(o)
% INPUT
%   o:          Matrix of any shape. It is in unit of cd/m^2.
% OUTPUT
%   e:          Matrix the same shape of input o. Range between [0, 1]

m1 = 1305 / 8192;
m2 = 2523 / 32;
c2 = 18.8515625;
c3 = 18.6875;
c1 = c3 - c2 + 1;

y = min(max(o / 10000, 0), 1);
yy = y .^ m1;
e = ((c1 + c2 * yy) ./ (1 + c3 * yy)) .^ m2;
end