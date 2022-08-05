function dE = deltaE(color, varargin)
% DESCRIPTION
%   Calculate the color difference delta E.
% INPUT
%   color:          n*3 matrix. Each row represents a color. It can be RGB or XYZ or Lab.
%                   Default is RGB.
% PARAMETER
%   'ColorSpace':   It can be one of valid RGB colorspace. See internal.cs_name_validator
%                   for detail. Or it can also be one of 'XYZ' or 'Lab'. Default is 'sRGB'.
end