clear; close all; clc;

%% Plot RGB gamut boundary in Lab space
figure(1); clf;
colorvis.show_gamut('AdobeRGB', 'Lab', 'Fill', true);


%% Plot RGB gamut boundary in ICtcp space
figure(2); clf;
colorvis.show_gamut('AdobeRGB', 'ICtCp', 'Fill', true);
