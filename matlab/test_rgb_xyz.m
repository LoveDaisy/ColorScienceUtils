function tests = test_rgb_xyz
tests = functiontests(localfunctions);
end


%% Test functions
function test_name(test_case)
valid_name_list = {'sRGB', 'SRGB', 'srgb', 'SrGb', ...
    'AdobeRGB', 'ARGB', 'ADoBErgb', 'argb'};
invalid_name_list = {'None', 'srss', 'linear'};

for i = 1:length(valid_name_list)
    space = valid_name_list{i};
    test_case.verifyTrue(internal.rgb_name_validator(space));
end
for i = 1:length(invalid_name_list)
    space = invalid_name_list{i};
    test_case.verifyFalse(internal.rgb_name_validator(space));
end
end

function test_rgb2xyz(test_case)
name_list = {'sRGB', 'ARGB'};
tol = 1e-10;

for i = 1:length(name_list)
    space = name_list{i};
    param = colorspace.get_param(space);
    
    rgb = [0, 0, 0;
        1, 0, 0;
        0, 1, 0;
        0, 0, 1;
        1, 1, 1];
    xyz = colorspace.rgb2xyz(rgb, space);
    for ci = 1:3
        test_case.verifyTrue(norm(xyz(1 + ci, 1:2) / sum(xyz(1 + ci, :)) - param.rgb(ci, :)) < tol);
    end
    test_case.verifyTrue(norm(xyz(end, :) - param.w) < tol);
    test_case.verifyTrue(norm(xyz(1, :)) < tol);
end
end

function test_rgb_back(test_case)
name_list = {'sRGB', 'ARGB'};
tol = 1e-10;

for i = 1:length(name_list)
    space = name_list{i};
    rgb = rand(100, 3);
    xyz = colorspace.rgb2xyz(rgb, space);
    rgb1 = colorspace.xyz2rgb(xyz, space);
    
    test_case.verifyTrue(norm(rgb - rgb1) < tol);
end
end
