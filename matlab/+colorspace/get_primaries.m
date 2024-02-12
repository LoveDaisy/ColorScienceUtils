function pri = get_primaries(name)
% DESCRIPTION
%   It returns a 3*2 array of RGB primaries for given name.
% SYNTAX
%   pri = get_primaries(name);
% INPUT
%   name:           A string for color gamut name.
% OUTPUT
%   pri:            3*2 array, xy-coordinate for RGB primaries.

if strcmpi(name, 'sRGB')
    pri = [0.6400, 0.3300;
        0.3000, 0.6000;
        0.1500, 0.0600];
elseif strcmpi(name, 'AdobeRGB') || strcmpi(name, 'ARGB')
    pri = [0.6400, 0.3300;
        0.2100, 0.7100;
        0.1500, 0.0600];
elseif strcmpi(name, '709')
    pri = [0.64, 0.33;
        0.3, 0.6;
        0.15, 0.06];
elseif strcmpi(name, '601') || strcmpi(name, '601-625') || strcmpi(name, '601_625') || ...
  strcmpi(name, 'bt470bg')  || strcmpi(name, '470bg')
    pri = [0.64, 0.33;
        0.29, 0.6;
        0.15, 0.06];
elseif strcmpi(name, '601-525') || strcmpi(name, '601_525') || ...
  strcmpi(name, 'smpte170m')  || strcmpi(name, '170m')
    pri = [0.63, 0.34;
        0.31, 0.595;
        0.155, 0.07];
elseif strcmpi(name, '2020')
    pri = [0.708, 0.292;
        0.170, 0.797;
        0.131, 0.046];
elseif strcmpi(name, 'P3') || strcmpi(name, 'P3D65') || strcmpi(name, 'D65P3') || ...
  strcmpi(name, 'DisplayP3') || strcmpi(name, 'DCIP3') || strcmpi(name, 'P3DCI')
    pri = [0.680, 0.320;
        0.265, 0.690;
        0.150, 0.060];
else
    warning('Input color gamut %d cannot recognize! Use default sRGB!', name);
    pri = [0.6400, 0.3300;
        0.3000, 0.6000;
        0.1500, 0.0600];
end
end