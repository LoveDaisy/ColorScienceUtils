function res = trc_name_validator(name)
% DESCRIPTION
%   It validates input transfer characteristics name.
% INPUT
%   name:           Expected to be a valid transfer characteristics name. It can be colorspace name,
%                   such as 'sRGB' or 'AdobeRGB', or it can be 'lnear'.
% OUTPUT
%   res:            true if input is a valid name, false otherwise.
  
res = colorutil.cs_name_validator(name) || strcmpi(name, 'Linear');
end