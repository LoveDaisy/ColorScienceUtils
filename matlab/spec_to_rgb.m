function rgb = spec_to_rgb(spec, varargin)
% INPUT
%   spec:               n*2 matrix. It records (wavelength, power density) pair.
%                       Wavelength is in nm.
% PARAMETER
%   'ColorSpace':     	A string for colorspace. Default is 'sRGB'.
%                       see internal.cs_name_validator for detail.
%   'Mixed':            Whether to recognize input spectrum as single color. Default is true.
%                       If set to false, each row in spec will result a color, representing
%                       a pure spectral color.
%   'Clamping':         A string for RGB clamping method. Default is 'Clip'.
%                       see internal.rgb_clamping_validator for detail.
%   'Y':                Expected output luminance (Y component). Default is 1.0.
%                       If 'Mixed' is set to false, then 'Y' is the max lumincance.
% OUTPUT
%   rgb:                1*3 or n*3. RGB color matrix. If parameter 'Mixed' is set to true, rgb
%                       is of size 1*3, and if 'Mixed' is set to false, rgb is of size n*3.

p = inputParser;
p.addRequired('spec', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 2}));
p.addParameter('ColorSpace', 'sRGB', @internal.cs_name_validator);
p.addParameter('Mixed', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
p.addParameter('Clamping', 'DeSat', @internal.rgb_clamping_validator);
p.addParameter('Y', 1, @(x) validateattributes(x, {'numeric'}, {'scalar'}));
p.parse(spec, varargin{:});

cmf = internal.xyz_cmf();

if p.Results.Mixed
    spd = interp1(spec(:, 1), spec(:, 2), cmf(:, 1), 'linear', 0);
    xyz = bsxfun(@times, cmf(:, 2:end), spd);
    xyz = sum(xyz);
else
    cmf = interp1(cmf(:, 1), cmf(:, 2:end), spec(:, 1), 'linear', 0);
    xyz = bsxfun(@times, cmf, spec(:, 2));
end

xyz = xyz / max(xyz(:, 2)) * p.Results.Y;
rgb = colorspace.xyz_to_rgb(xyz, p.Results.ColorSpace, p.Results.Clamping);
end
