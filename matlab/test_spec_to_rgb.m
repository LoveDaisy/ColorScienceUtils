clear; close all; clc;

wl = (400:700)';
spec = [wl, black_body_radiance(wl, 6500)];

y_ev_store = -4:.05:3;

rgb_img = zeros(length(y_ev_store), length(wl), 3);
img_size = [length(y_ev_store), length(wl)];
pix_num = prod(img_size);

for i = 1:length(y_ev_store)
% for i = 31
    rgb = spec_to_rgb(spec, 'ColorSpace', 'sRGB', 'Mixed', false, 'Y', 2^y_ev_store(i), ...
        'Clamping', 'minuv');
    rgb_img(i, :, :) = reshape(rgb, [1, length(wl), 3]);
end

%%
figure(1); clf;
set(gcf, 'Position', [200, 20, 1000, 540]);
set(gca, 'Position', [.1, .1, .8, .8]);
imagesc(wl, y_ev_store, rgb_img);
axis xy;
set(gca, 'FontSize', 13);
xlabel('Wavelength (nm)', 'FontSize', 16);
ylabel('Relative intensity (EV)', 'FontSize', 16);
