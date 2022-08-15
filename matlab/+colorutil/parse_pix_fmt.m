function [size_factor, precision] = parse_pix_fmt(pix_fmt)
size_factor = [1, 1; 0.5, 0.5; 0.5, 0.5];
precision = 'uint8';

tk = regexpi(pix_fmt, 'yuv(4\d{2})p(.*)', 'tokens');
str = tk{1}{1};
if strcmpi(str, '420')
    size_factor = [1, 1; 0.5, 0.5; 0.5, 0.5];
elseif strcmpi(str, '422')
    size_factor = [1, 1; 0.5, 1; 0.5, 1];
elseif strcmpi(str, '444')
    size_factor = [1, 1; 1, 1; 1, 1];
end

str = tk{1}{2};
if isempty(str)
    return;
end
tk = regexpi(str, '(\d{1,2})(.*)', 'tokens');
if isempty(tk)
    return;
end
if ~isempty(tk{1}{2}) && ~strcmpi(tk{1}{2}, 'le')
    warning('Endiance %s not support! Use native LE!', tk{1}{2});
end
precision = sprintf('uint%d', ceil(str2double(tk{1}{1}) / 8) * 8);
end