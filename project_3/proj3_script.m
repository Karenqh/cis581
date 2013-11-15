%% proj3_script
clc;
clear;
close all;

% Read in image and convert to gray scale
im1 = imread('pics/1.JPG');
im2 = imread('pics/2.JPG');
im3 = imread('pics/3.JPG');

% im1 = imresize(im1, 0.2);
% im2 = imresize(im2, 0.2);
% im3 = imresize(im3, 0.2);
% 
% imwrite(im1, 'pics/1.jpg', 'jpeg');
% imwrite(im2, 'pics/2.jpg', 'jpeg');
% imwrite(im3, 'pics/3.jpg', 'jpeg');
% 
% 
% figure(1); imshow(im1);
% figure(2); imshow(im2);
% figure(3); imshow(im3);


%%
im1 = rgb2gray(im1);
im2 = rgb2gray(im2);

% Corner detection using Harris detector
sigma = 2;
cimg1 = harris(im1, sigma);
cimg2 = harris(im2, sigma);

% Avoid the 4 image corners
cimg1(1,1) = 0;
cimg1(end,end) = 0;
cimg2(1,1) = 0;
cimg2(end,end) = 0;


%%%%%%%% DEBUGGING
% cimg(cimg<50) = 0;
% figure(2);
% imagesc(cimg);


%% Adaptive Non-maxima Supprestion
max_pts = 80; % TUNE THIS!!!!!!!!!!!!!!
tic;
[y1 x1 rmax1] = anms(cimg1, max_pts);
% figure(1); hold on;
% plot(x1, y1, '.g');

[y2 x2 rmax2] = anms(cimg2, max_pts);
% figure(2); hold on;
% plot(x2, y2, '.g');
toc;

%%%%%%%% DEBUGGING
% blank = zeros(size(cimg));
% inds = sub2ind(size(blank), y, x);
% blank(inds) = 1;
% figure(3)
% imagesc(blank);
% colormap(gray);

%% Feature descripter
tic;
p1 = feat_desc(im1, y1, x1);
p2 = feat_desc(im2, y2, x2);
toc;

%% Feature Matching
m = feat_match(p1,p2);

%%%%%%%% DEBUGGING
good1 = find(m~=-1);
good2 = m(good1);

y1s = y1(good1);  x1s = x1(good1);
y2s = y2(good2);  x2s = x2(good2);

% figure(1); hold on;
% plot(x1(good1), y1(good1), '.r');
% 
% figure(2); hold on;
% plot(x2(good2), y2(good2), '.r');


%% RANSAC
thresh = 0.5;
[H,inlier_ind] = ransac_est_homography(y1s, x1s, y2s, x2s, thresh);

%% Panorama
img_input = cell(2,1);
img_input{1} = im1;
img_input{2} = im2;
img_input{3} = im3;


% A wrapper for handling everyting
img_mosaic = mymosaic(img_input);
close all;
image(img_mosaic);


