function rgb = luv2rgb(luv, varargin)
% DESCRIPTION
%   It converts CIE Luv data to RGB data.
% SYNTAX
%   rgb = luv2rgb(luv);
%   rgb = luv2rgb(luv, cs_name);
%   rgb = luv2rgb(luv, cs_param);
% INPUT
%   luv:            n*3 array or m*n*3 image.
%   cs_name:        A string for colorspace name. Default is 'sRGB'.
%                   See colorutil.cs_name_validator for detail.
%   cs_param:       A struct returned from colorspace.get_param.
% OUTPUT
%   rgb:            The same shape to input luv.

xyz = colorspace.luv2xyz(luv);
rgb = colorspace.xyz2rgb(xyz, varargin{:});
end