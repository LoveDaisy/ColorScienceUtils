function [x, fval] = solve_equation_binary(fun, yq, x0, x1, varargin)
% Description
%   Solve an equation by binary searching.
% SYNTAX
%   x = solve_equation_binary(fun, yq, x0, x1);
%   x = solve_equation_binary(..., Name, Value...);
%   [x, fval] = solve_equation_binary(...);
% INPUT
%   fun:            A function handle. Takes x (may be vector) and returns y (a scalar).
%                   It has the form y = fun(x, idx), where x maybe n*d, and y meybe n*1.
%   yq:             n*1 vector, each row represents a sample point.
%   x0:             n*d matrix, each row represents a sample point. Lower bound for x.
%   x1:             n*d matrix, each row represents a sample point. Higher bound for x.
% PARAMETER
%   'XTol':         A scalar. If max(norm(x0 - x1)) < XTol, then stop searching.
%   'MaxFunEvals':  An integer. Maximumn counts for function evaluation during solving.
% OUTPUT
%   x:              n*d matrix, each row represents a sample point. The solution for equation.
%                   If it cannot find a solution between [x0, x1], then x will be nan;
%   fval:           n*1 matrix, each row represents a sample point.

num = length(yq);
dim = size(x0, 2);
p = inputParser;
p.addRequired('fun', @(x) validateattributes(x, {'function_handle'}, {'scalar'}));
p.addRequired('yq', @(x) validateattributes(x, {'numeric'}, {'column'}));
p.addRequired('x0', @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', num, 'ncols', dim}));
p.addRequired('x1', @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', num, 'ncols', dim}));
p.addParameter('XTol', 1e-4, @(x) validateattributes(x, {'numeric'}, {'scalar'}));
p.addParameter('MaxFunEvals', 100, @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer'}));
p.parse(fun, yq, x0, x1, varargin{:});

y0 = fun(x0, true(num, 1));
y1 = fun(x1, true(num, 1));
cnt = 2;
valid_idx = (y0 - yq) .* (y1 - yq) < 0;
x0(~valid_idx, :) = nan;
x1(~valid_idx, :) = nan;

idx = find(valid_idx);
while nanmax(sqrt(sum((x0 - x1).^2, 2))) > p.Results.XTol && cnt < p.Results.MaxFunEvals
    xm = (x0 + x1) / 2;
    ym = fun(xm, idx);
    cnt = cnt + 1;
    
    tmp_idx = (ym - yq(idx)) .* (y0(idx) - yq(idx)) >= 0;
    x0(idx(tmp_idx), :) = xm(idx(tmp_idx), :);
    x1(idx(~tmp_idx), :) = xm(idx(~tmp_idx), :);
end
x = (x1 + x0) / 2;
fval = fun(x, true(num, 1));
end