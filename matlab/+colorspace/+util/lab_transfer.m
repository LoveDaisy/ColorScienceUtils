function y = lab_transfer(x)
% DESCRIPTION
%   Transfer function used for XYZ -> Lab conversion

delta = 6 / 29;
idx = x < delta^3;

y = x;
y(idx) = x(idx) / 3 / delta^2 + 4 / 29;
y(~idx) = nthroot(x(~idx), 3);
end