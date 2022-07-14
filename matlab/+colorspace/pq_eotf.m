function o = pq_eotf(e)
% DESCRIPTION
%   It converts nonlinear electro value e to linear optial luminance o.
% SYNTAX
%   o = pq_eotf(e)
% INPUT
%   e:          Matrix of any shape. Range between [0, 1]
% OUTPUT
%   o:          Matrix the same shape of input e. It is in unit of cd/m^2.

m1 = 1305 / 8192;
m2 = 2523 / 32;
c2 = 18.8515625;
c3 = 18.6875;
c1 = c3 - c2 + 1;

e = max(min(e, 1), 0);
ee = e .^ (1 / m2);
o = 10000 * (max(ee - c1, 0) ./ (c2 - c3 * ee)) .^ (1 / m1);
end