function lab = rgb2lab(rgb, varargin)
% DESCRIPTION
%   Convert RGB color to Lab data.
% SYNTAX
%   lab = rgb2xyz(rgb);
%   lab = rgb2xyz(rgb, cs_name);
%   lab = rgb2xyz(rgb, param);
% INPUT
%   rgb:            n*3 matrix, each row represents a color.
%   cs_name:        A string for colorspace name. Default is 'sRGB'.
%                   See internal.rgb_name_validator for detail.
%   param:          A struct returned from colorspace.get_param.
% OUTPUT
%   lab:            n*3 matrix for Lab data. L ranges between [0, 1].

xyz = colorspace.rgb2xyz(rgb, varargin{:});
lab = colorspace.xyz2lab(xyz);
end