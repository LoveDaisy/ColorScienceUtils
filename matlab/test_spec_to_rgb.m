clear; close all; clc;

wl = (400:700)';
spec = [wl, ones(size(wl))];

rgb = spec_to_rgb(spec, 'Mixed', false);