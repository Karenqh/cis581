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
% figure(1); imshow(im1);
% figure(2); imshow(im2);

im1 = rgb2gray(im1);
im2 = rgb2gray(im2);

% Corner detection using Harris detector
sigma = 2;
thres = 50;
cimg1 = harris(im1, sigma);
cimg2 = harris(im2, sigma);


%%%%%%%% DEBUGGING
% cimg(cimg<50) = 0;
% figure(2);
% imagesc(cimg);


%% Adaptive Non-maxima Supprestion
max_pts = 80; % TUNE THIS!!!!!!!!!!!!!!
tic;
[y1 x1 rmax1] = anms(cimg1, max_pts);
[y2 x2 rmax2] = anms(cimg2, max_pts);
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
p = feat_desc(im1, y, x);
toc;
