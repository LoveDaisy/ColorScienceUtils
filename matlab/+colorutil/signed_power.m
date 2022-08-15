function y = signed_power(x, p)
% DESCRIPTION
%   It calculates a signed-power as y = sign(x) * |x|^p.
y = sign(x) .* abs(x) .^ p;
end