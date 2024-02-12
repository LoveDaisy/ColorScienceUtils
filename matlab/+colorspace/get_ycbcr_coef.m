function coef = get_ycbcr_coef(cs_name)
% DESCRIPTION
%   Get a parameter array for transfer characteristics. [a, b, g, k].
% SYNTAX
%   coef = get_ycbcr_coef(cs_name);
% INPUT
%   cs_name:            A string, expected to be a valid colorspace name, such as '709'.
%                       See colorutil.cs_name_validator for detail.
% OUTPUT
%   coef:               5-element array, [y_coef[1:3], cbcr_coef[1:2]]. See colorspace.rgb2ycbcr and
%                       colorspace.ycbcr2rgb for detail.

p = inputParser;
p.addRequired('name', @colorutil.cs_name_validator);
p.parse(cs_name);

if strcmpi(cs_name, 'sRGB') || ...
    strcmpi(cs_name, 'AdobeRGB') || strcmpi(cs_name, 'ARGB')
    y_coef = [1/3, 1/3, 1/3];
    cbcr_coef = [1, 1];
elseif strcmpi(cs_name, '709')
    y_coef = [0.2126, 0.7152, 0.0722];
    cbcr_coef = [1.8556, 1.5748];
elseif strcmpi(cs_name, '601') || strcmpi(cs_name, '601-625') || strcmpi(cs_name, '601_625') || ...
  strcmpi(cs_name, 'bt470bg') || strcmpi(cs_name, '470bg') || ...
  strcmpi(cs_name, '601-525') || strcmpi(cs_name, '601_525') || strcmpi(cs_name, 'smpte170m') || strcmpi(cs_name, '170m')
    y_coef = [0.299, 0.587, 0.114];
    cbcr_coef = [1.772, 1.402];
elseif strcmpi(cs_name, '2020') || ...
    strcmpi(cs_name, 'p3d65') || strcmpi(cs_name, 'd65p3') ||strcmpi(cs_name, 'displayp3') || ...
    strcmpi(cs_name, 'p3dci') || strcmpi(cs_name, 'dci3')
    y_coef = [0.2627, 0.6780, 0.0593];
    cbcr_coef = [1.8814, 1.4746];
else
    warning('Input color space %d cannot recognize! Use default sRGB!', cs_name);
    y_coef = [1/3, 1/3, 1/3];
    cbcr_coef = [1, 1];
end

coef = [y_coef, cbcr_coef];
end