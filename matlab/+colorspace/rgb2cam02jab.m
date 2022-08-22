function cam02jab = rgb2cam02jab(rgb, varargin)
% DESCRIPTION
%   It converts RGB data to CAM02 Jab data.
% SYNTAX
%   cam02jab = rgb2cam02jab(rgb);
%   cam02jab = rgb2cam02jab(rgb, cs_name);
%   cam02jab = rgb2cam02jab(rgb, cs_param);
%   cam02jab = rgb2cam02jab(rgb, __, Name, Value...);
% INPUT
%   rgb:            n*3 array or m*n*3 image
%   cs_name:        A string specifying RGB colorspace. Default is 'sRGB'.
%   cs_param:       A struct returned from colorspace.get_param()
% OPTIONS
%   See colorspace.xyz2cam02jab()

if ~isempty(varargin) && colorutil.cs_param_validator(varargin{1})
    xyz = colorspace.rgb2xyz(rgb, varargin{1});
    cam02jab = colorspace.xyz2cam02jab(xyz, varargin{2:end});
else
    xyz = colorspace.rgb2xyz(rgb);
    cam02jab = colorspace.xyz2cam02jab(xyz, varargin{:});
end
end
