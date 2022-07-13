clear; close all; clc;

wl = (400:700)';
spec = [wl, ones(size(wl))];

y_store = 0:0.01:1.2;

rgb_img = zeros(length(y_store), length(wl), 3);

for i = 1:length(y_store)
    rgb = spec_to_rgb(spec, 'Mixed', false, 'Y', y_store(i), 'Clamping', 'DeSat');
    rgb_img(i, :, :) = reshape(rgb, [1, length(wl), 3]);
end

figure(1);
imagesc(wl, y_store, rgb_img);
axis xy;