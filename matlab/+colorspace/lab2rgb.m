function rgb = lab2rgb(lab, varargin)
% DESCRIPTION
%   Convert Lab data to RGB color space.
% SYNTAX
%   rgb = lab2rgb(lab);
%   rgb = lab2rgb(lab, cs_name);
%   rgb = lab2rgb(lab, param);
% INPUT
%   lab:            n*3 matrix, each row represents a Lab data. L ranges between [0, 1].
%   cs_name:        A string for colorspace name. Default is 'sRGB'.
%                   See internal.cs_name_validator for detail.
%   param:          A struct returned from colorspace.get_param.
% OUTPUT
%   rgb:            n*3 matrix for RGB data.

xyz = colorspace.lab2xyz(lab);
rgb = colorspace.xyz2rgb(xyz, varargin{:});
end