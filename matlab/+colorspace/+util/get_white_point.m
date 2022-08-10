function w = get_white_point(name)
if strcmpi(name, 'D65')
    % CCT = 6504
    w = [0.3127, 0.3290];
elseif strcmpi(name, 'D60')
    % CCT = 6000
    w = [0.32168, 0.33767];
elseif strcmpi(name, 'dci')
    % CCT = 6300
    w = [0.314, 0.351];
elseif strcmpi(name, 'e')
    w = [1/3, 1/3];
else
    warning('Cannot recognize white point name %s! Use D65 as default!', name);
    w = [0.3127, 0.3290];
end
w = [w, 1 - sum(w)] / w(2);
end