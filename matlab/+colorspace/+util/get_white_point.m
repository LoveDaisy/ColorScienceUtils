function w = get_white_point(name)
if strcmpi(name, 'D65')
    w = [0.95047, 1.00000, 1.08883];
else
    warning('Cannot recognize white point name %s! Use D65 as default!', name);
    w = [0.95047, 1.00000, 1.08883];
end
end