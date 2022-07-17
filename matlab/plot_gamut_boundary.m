clear; close all; clc;

end_points = [0, 0, 0, 0, 0, 1;
    0, 0, 0, 0, 1, 0;
    0, 0, 0, 1, 0, 0;
    0, 0, 1, 0, 1, 0;
    0, 0, 1, 1, 0, 0;
    0, 1, 0, 0, 0, 1;
    0, 1, 0, 1, 0, 0;
    1, 0, 0, 0, 0, 1;
    1, 0, 0, 0, 1, 0;
    0, 1, 1, 1, 0, 0;
    1, 0, 1, 0, 1, 0;
    1, 1, 0, 0, 0, 1];

figure(1); clf;
hold on;
for i = 1:size(end_points, 1)
    rgb = (0:.01:1)' * end_points(i, 4:6) + end_points(i, 1:3);
    lab = colorspace.rgb2lab(rgb, 'sRGB');
    plot3(lab(:, 2), lab(:, 3), lab(:, 1), 'k');
end
rgb = [end_points(:, 1:3) + end_points(:, 4:6); end_points(:, 4:6); 0, 0, 0];
rgb = unique(rgb, 'rows');
lab = colorspace.rgb2lab(rgb, 'sRGB');
scatter3(lab(:, 2), lab(:, 3), lab(:, 1), 60, rgb, 'MarkerFaceColor', 'flat');
axis equal;
set(gca, 'color', [1, 1, 1] * 0.5);