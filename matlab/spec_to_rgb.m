function rgb = spec_to_rgb(spec, varargin)
% DESCRIPTION
%   This function converts spectra data into RGB colors.
% SYNTAX
%   rgb = spec_to_rgb(spec);
%   rgb = spec_to_rgb(..., Name, Value...);
% INPUT
%   spec:               n*(m+1) matrix. It records (wavelength, intensity) pair.
%                       Wavelength is in nm.
% PARAMETER
%   'ColorSpace':     	A string for colorspace. Default is 'sRGB'.
%                       see colorutil.cs_name_validator for detail.
%   'Mixed':            Whether to recognize input spectrum as single color. Default is true.
%                       If set to false, each row in spec will result a color, representing
%                       a pure spectral color.
%   'Clamping':         A string for RGB clamping method. Default is 'Clip'.
%                       see colorutil.rgb_compression_validator for detail.
%   'Y':                Expected output luminance (Y component). Default is 1.0.
%                       If 'Mixed' is set to false, then 'Y' is the max lumincance.
% OUTPUT
%   rgb:                1*3 or n*3. RGB color matrix. If parameter 'Mixed' is set to true, rgb
%                       is of size 1*3, and if 'Mixed' is set to false, rgb is of size n*3.

p = inputParser;
p.addRequired('spec', @(x) isnumeric(x) && (length(size(x)) == 2 && size(x, 2) >= 2));
p.addParameter('ColorSpace', 'sRGB', @colorutil.cs_name_validator);
p.addParameter('Mixed', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
p.addParameter('Clamping', 'Clip', @colorutil.rgb_compression_validator);
p.addParameter('Y', 1, @(x) validateattributes(x, {'numeric'}, {'scalar'}));
p.parse(spec, varargin{:});

xyz = spec_to_xyz(spec, 'Mixed', p.Results.Mixed, 'Y', p.Results.Y);
rgb = colorspace.xyz2rgb(xyz, p.Results.ColorSpace, p.Results.Clamping);
end
