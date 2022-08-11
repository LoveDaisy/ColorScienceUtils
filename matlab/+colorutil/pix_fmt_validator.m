function res = pix_fmt_validator(pix_fmt)
% DESCRIPTION
%   It checks whether pix_fmt is a valid pixel format.
% SYNTAX
%   res = pix_fmt_validator(pix_fmt)
% INPUT
%   pix_fmt:        A string for pixel format, e.g. 'yuv420p10le'
% OUTPUT
%   res:            true | false

res = false;
tk = regexpi(pix_fmt, 'yuv(4\d{2})p(.*)', 'tokens');
if isempty(tk)
    return;
end

res = true;
str2 = tk{1}{2};
if isempty(str2)
    return;
end

tk = regexpi(str2, '(\d{2})[a-z]{2}', 'tokens');
if isempty(tk)
    res = false;
    return;
end
end