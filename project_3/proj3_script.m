%% proj3_script
clc;
clear;
close all;

% Read in image and convert to gray scale
im = imread('33066.jpg');
% figure(1); imshow(im);
im = rgb2gray(im);

% Corner detection using Harris detector
sigma = 2;
thres = 50;
cimg = harris(im, sigma);

%%%%%%%% DEBUGGING
% cimg(cimg<50) = 0;
% figure(2);
% imagesc(cimg);


%% Adaptive Non-maxima Supprestion
max_pts = 100; % TUNE THIS!!!!!!!!!!!!!!
tic;
[y x rmax] = anms(cimg, max_pts);
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
p = feat_desc(im, y, x);
toc;
