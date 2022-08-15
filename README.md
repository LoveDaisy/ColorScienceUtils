# Color Science Utilities

A toolkit for color science. The first codes are in MATLAB, which is just my personal choice.
I will try python later.

## Quick start

Just add subfolder `matlab` to your MATLAB path, and then you can use all the tools.

### Color space conversion

I have implemented many conversions in `+colorspace` package. They are easy to use:

```matlab
% Read image. Assume it is an DisplayP3 image shot by a smart phone.
img = imread('DisplayP3_image.jpg');  

% Now convert it to sRGB gamut.
img_new = colorspace.rgb2rgb('DisplayP3', 'sRGB');

% And now it can be displayed safely on web, or just via imshow();
figure;
imshow(img_new);
```

And also I have implemented some conversions for HDR video. For example if you want to check YUV rawdata of an HDR video,

```matlab
% Read YUV rawdata. Here it is yuv420p10le pixel format.
% So component y, u, and v are all of uint16 class.
[y, u, v] = colorutil.read_yuv_rawdata('yuv420p10le_rawdata.yuv');

% Convert to float type and normalize to [0, 1].
[yfp, ufp, vfp] = colorutil.ycbcr_int2double(y, u, v, 10, 'tv');

% Merge into a 3-channel image.
yuv = colorutil.merge_ycbcr_channel(yfp, ufp, vfp);

% Display y component.
figure;
imshow(yfp);

% Or display them all.
figure;
colorvis.plot_yuv(yfp, ufp, vfp);
```

Result of `plot_yuv()`:
![plot_yuv](matlab/img/plot_yuv.png)

### Gamut visualization

Here are also several visualization tools for color gamut.

```matlab
% Show chromaticity diagram boundary.
colorvis.plot_chromaticity_diagram();
```
![chm_boundary](matlab/img/chromaticity_boundary.png)

```matlab
% Fill chromaticity diagram
colorvis.plot_chromaticity_diagram('Fill', true, 'Background', [1, 1, 1]);
```
![fill_chm](matlab/img/chromaticity_fill.png)

And also you can plot 2D and 3D density map for color distribution. Say if we have this image:
![scene_image](matlab/img/scene_img.jpg)

```matlab
% Plot 2D density map
xyz = colorspace.rgb2xyz(rgb_image, 'sRGB');
colorvis.plot_chromaticity_diagram('HistData', xyz);
```
![xy_hist](matlab/img/xy_hist.png)

```matlab
% Plot 3D density map (here I call it bubble plot).
% Default shown in Lab space.
colorvis.plot_gamut_bubble_hist(rgb_image, 'sRGB');
```
![lab_bubble](matlab/img/Lab_bubble.png)

```matlab
% Or display in xyY space, and use log scale for luminance axis.
colorvis.plot_gamut_bubble_hist(rgb_image, 'sRGB', 'xyY', 'ZScale', 'log');
```
![xyy_bubble](matlab/img/xyY_bubble.png)

## TODO
- [ ] Add more test cases
- [ ] Add python codes