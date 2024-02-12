function xyz = spec_to_xyz(spec, varargin)
% DESCRIPTION
%   This function converts spectra data into XYZ colors.
% SYNTAX
%   xyz = spec_to_rgb(spec);
%   xyz = spec_to_rgb(..., Name, Value...);
% INPUT
%   spec:               n*(m+1) array. It records (wavelength, intensity) pair.
%                       Wavelength is in nm. First column is wavelength, and other columns are
%                       intensity.
% PARAMETER
%   'Mixed':            Whether to recognize input spectrum as single color. Default is true.
%                       If set to false, each row in spec will result m colors, representing
%                       pure spectral colors. If set to true, then there will be m colors in total.
%   'Y':                Expected output luminance (Y component). Default is 1.0.
%                       If 'Mixed' is set to false, then 'Y' is the max lumincance.
% OUTPUT
%   rgb:                m*3 or n*m*3. RGB color matrix. If parameter 'Mixed' is set to true, rgb
%                       is of size m*3, and if 'Mixed' is set to false, rgb is of size n*m*3.

p = inputParser;
p.addRequired('spec', @(x) isnumeric(x) && (length(size(x)) == 2 && size(x, 2) >= 2));
p.addParameter('Mixed', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
p.addParameter('Y', 1, @(x) validateattributes(x, {'numeric'}, {'scalar'}));
p.parse(spec, varargin{:});

cmf = colorspace.xyz_cmf();

if p.Results.Mixed
    spd = interp_spd(spec(:, 1), spec(:, 2:end), cmf(:, 1));
    xyz = bsxfun(@times, reshape(cmf(:, 2:end), [], 1, 3), spd);
    xyz = sum(xyz);
else
    cmf = interp1(cmf(:, 1), cmf(:, 2:end), spec(:, 1), 'linear', 0);
    xyz = bsxfun(@times, reshape(cmf, [], 1, 3), spec(:, 2:end));
end

if p.Results.Y > 0
    xyz = xyz ./ max(xyz(:, :, 2)) * p.Results.Y;
end
xyz = squeeze(xyz);
if isvector(xyz)
    xyz = reshape(xyz, 1, []);
end
end


function spd = interp_spd(spec_lambda, spec_spd, cmf_lambda)
while length(spec_lambda) > length(cmf_lambda) * 5
    spec_spd = imfilter(spec_spd, ones(4, 1) / 4, 'same', 'replicate');
    spec_spd = spec_spd(1:4:end, :);
    spec_lambda = spec_lambda(1:4:end);
end
if length(spec_lambda) > length(cmf_lambda)
    spec_dw = spec_lambda(2) - spec_lambda(1);
    cmf_dw = cmf_lambda(2) - cmf_lambda(1);
    sigma = cmf_dw / spec_dw;
    kernel_size = ceil(sigma / 2) * 2 + 1;
    kernel = ones(kernel_size, 1) / kernel_size;
    spec_spd = imfilter(spec_spd, kernel, 'same', 'replicate');
end
spd = interp1(spec_lambda, spec_spd, cmf_lambda, 'linear', 0);
end
