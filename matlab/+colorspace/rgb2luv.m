function luv = rgb2luv(rgb, varargin)
% DESCRIPTION
%   It converts RGB data to CIE Luv data.
% SYNTAX
%   luv = rgb2luv(rgb);
%   luv = rgb2luv(rgb, cs_name);
%   luv = rgb2luv(rgb, cs_param);
% INPUT
%   rgb:            n*3 array or m*n*3 image. See colorutil.image_shape_validator.
%   cs_name:        A string for colorspace name. Default is 'sRGB'.
%                   See colorutil.cs_name_validator for detail.
%   cs_param:       A struct returned from colorspace.get_param.
% OUTPUT
%   luv:            The same shape to input rgb.

xyz = colorspace.rgb2xyz(rgb, varargin{:});
luv = colorspace.xyz2luv(xyz);
end