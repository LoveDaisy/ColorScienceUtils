function m = xyz_rgb_mat(varargin)
% DESCRIPTION
%   Generate the matrix used when converting XYZ data to RGB data.
% SYNTAX
%   m = xyz_rgb_mat();
%   m = xyz_rgb_mat(cs_name);
%   m = xyz_rgb_mat(param);
% INPUT
%   cs_name:        A string for colorspace name. Default is 'sRGB'.
%                   See internal.cs_name_validator for detail.
%   param:          A struct returned from internal.get_colorspace_param.
% OUTPUT
%   m:              3*3 matrix. rgb_linear = xyz * m, where rgb and xyz
%                   are all n*3 matrix, and each row represents a color.

p = inputParser;
p.addOptional('param', 'sRGB', @internal.cs_validator);
p.parse(varargin{:});

if ischar(p.Results.param)
    param = internal.get_colorspace_param(p.Results.param);
else
    param = p.Results.param;
end

XYZ = [param.rgb(:, 1) ./ param.rgb(:, 2), ones(3, 1), (1 - sum(param.rgb, 2)) ./ param.rgb(:, 2)];
S = param.w / XYZ;
m = inv(diag(S) * XYZ);
end