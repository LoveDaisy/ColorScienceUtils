function rgb = spec_to_rgb(spec, varargin)
% INPUT
%   spec:             n*2 matrix. It records (wavelength, power density) pair.
%                     Wavelength is in nm.
% PARAMETER
%   'ColorSpace':     One of 'sRGB', 'AdobeRGB'. Default is 'sRGB'.
%   'Mixed':          Whether to recognize input spectrum as single color. Default is true.
%                     If set to false, each row in spec will result a color, representing
%                     a pure spectral color.
%   'Y':              Expected output luminance (Y component). Default is 1.0.
%                     If 'Mixed' is set to false, then 'Y' is the max lumincance.
% OUTPUT
%   rgb:              1*3 or n*3. RGB color matrix. If parameter 'Mixed' is set to true, rgb
%                     is of size 1*3, and if 'Mixed' is set to false, rgb is of size n*3.

p = inputParser;
p.addRequired('spec', @(x) validateattributes(x, {'numeric'}, {'2d', 'ncols', 2}));
p.addParameter('ColorSpace', 'sRGB', @internal.colorspace_validator);
p.addParameter('Mixed', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
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
mat = xyz2rgb_mat(p.Results.ColorSpace);
lin_rgb = xyz * mat;
rgb = rgb_gamma(lin_rgb, 'ColorSpace', p.Results.ColorSpace, 'Method', 'l2n');
end
