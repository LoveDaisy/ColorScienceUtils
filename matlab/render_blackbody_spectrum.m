clear; close all; clc;

blackbody_temperature = 6500;
wl = (400:1:700)';
spec = [wl, black_body_radiance(wl, blackbody_temperature)];

ev_store = -4:.01:3;
ev_num = length(ev_store);
img_spec_data = [repmat(wl, [ev_num, 1]), kron(2.^ev_store', spec(:,2))];

method = 'greyingictcp';
rgb = spec_to_rgb(img_spec_data, ...
    'ColorSpace', 'srgb', 'Mixed', false, ...
    'Y', 2^max(ev_store), 'Clamping', method);
rgb_img = reshape(rgb, [length(wl), ev_num, 3]);
rgb_img = permute(rgb_img, [2, 1, 3]);

%%
yi = 301;

fig1 = figure(1); clf;
set(gcf, 'Position', [200, 20, 1000, 540]);
subplot('Position', [.06, .36, .88, .6]);
imagesc(wl, ev_store, rgb_img);
hold on;
plot([min(wl), max(wl)], [1, 1] * ev_store(yi), ':', 'Color', [1, 1, 1], 'LineWidth', 2);
axis xy;
set(gca, 'FontSize', 13, 'xtick', []);
ylabel('Relative intensity (EV)', 'FontSize', 16);

subplot('Position', [.06, .1, .88, .2]);
imagesc(wl, ev_store(yi), rgb_img(yi, :, :));
axis xy;
xlabel('Wavelength (nm)', 'FontSize', 16);
set(gca, 'FontSize', 13, 'ytick', []);

figure(2); clf;
set(gcf, 'Position', [200, 200, 1000, 540]);
set(gca, 'Position', [0.06, 0.12, 0.88, 0.8]);
hold on;
plot(wl, reshape(rgb_img(yi, :, 1), [], 1), 'linewidth', 2, 'color', 'r');
plot(wl, reshape(rgb_img(yi, :, 2), [], 1), 'linewidth', 2, 'color', 'g');
plot(wl, reshape(rgb_img(yi, :, 3), [], 1), 'linewidth', 2, 'color', 'b');
box on;
set(gca, 'FontSize', 13, 'ylim', [0, 1]);
xlabel('Wavelength (nm)', 'FontSize', 16);
title('RGB components', 'FontSize', 18);

% saveas(fig1, sprintf('img/spectra_%s.png', method));