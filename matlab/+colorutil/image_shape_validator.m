function res = image_shape_validator(x)
% DESCRIPTION
%   It checkes the shape of input x, and make sure it is either n*3 array, or m*n*3 array.
% SYNTAX
%   res = image_shape_validator(x);
% INPUT
%   x:          Input to be checked.
% OUTPUT
%   res:        true | false
res = isnumeric(x) && ((length(size(x)) == 2 && size(x, 2) == 3) || ...
    length(size(x)) == 3 && size(x, 3) == 3);
end