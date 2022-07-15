clear; close all; clc;

wl = (400:5:700)';
spec = [wl, black_body_radiance(wl, 6500)];

y_ev_store = -4:.2:3;

rgb_img = zeros(length(y_ev_store), length(wl), 3);
img_size = [length(y_ev_store), length(wl)];
pix_num = prod(img_size);

method = 'minitp';
for i = 1:length(y_ev_store)
% for i = 65
    rgb = spec_to_rgb(spec, 'ColorSpace', 'srgb', 'Mixed', false, 'Y', 2^y_ev_store(i), ...
        'Clamping', method);
    rgb_img(i, :, :) = reshape(rgb, [1, length(wl), 3]);
    fprintf('image line #%d/%d done!\n', i, length(y_ev_store));
% end

%%
% yi = 65;
yi = i;

fig1 = figure(1); clf;
set(gcf, 'Position', [200, 20, 1000, 540]);
subplot('Position', [.06, .36, .88, .6]);
imagesc(wl, y_ev_store, rgb_img);
hold on;
plot([min(wl), max(wl)], [1, 1] * y_ev_store(yi), ':', 'Color', [1, 1, 1], 'LineWidth', 2);
axis xy;
set(gca, 'FontSize', 13, 'xtick', []);
ylabel('Relative intensity (EV)', 'FontSize', 16);

subplot('Position', [.06, .1, .88, .2]);
imagesc(wl, y_ev_store(yi), rgb_img(yi, :, :));
axis xy;
xlabel('Wavelength (nm)', 'FontSize', 16);
set(gca, 'FontSize', 13, 'ytick', []);

% figure(2); clf;
% set(gcf, 'Position', [200, 200, 1000, 540]);
% set(gca, 'Position', [0.06, 0.12, 0.88, 0.8]);
% plot(wl, reshape(rgb_img(yi, :, :), [], 3));
% set(gca, 'FontSize', 13, 'ylim', [0, 1]);
% xlabel('Wavelength (nm)', 'FontSize', 16);
% title('RGB components', 'FontSize', 18);

end

% saveas(fig1, sprintf('img/spectra_%s.png', method));