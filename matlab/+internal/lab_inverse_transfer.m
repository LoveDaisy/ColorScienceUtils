function y = lab_inverse_transfer(x)
% DESCRIPTION
%   Transfer function used for Lab -> XYZ conversion

delta = 6 / 29;
idx = x < delta;

y = x;
y(idx) = (x(idx) - 4 / 29) * 3 * delta^2;
y(~idx) = x(~idx) .^ 3;
end