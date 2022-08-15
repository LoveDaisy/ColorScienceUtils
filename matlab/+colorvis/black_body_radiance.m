function spd = black_body_radiance(wl, t)
h = 6.62607015e-34;
kB = 1.380649e-23;
c = 299792458;

wl = wl * 1e-9;  % nm to meter
spd = 2 * h * c^2 ./ wl.^5 ./ (exp(h * c ./ (wl * kB * t)) - 1);
end