%% Script for running Q1
I = imread('../project_2/hit_girl4.jpg');

% Call function myImcrop
J = myImcrop(I);


%% Q2 Associative Convolution
clc;
clear;

% Use the specified I as described in handout
i1 = ones(4); i2 = zeros(4,2); i3 = ones(4,2); i4 = zeros(4,2);
i = [i1, i2, i3, i4];
j = zeros(2, 10);
k1 = 0.5*ones(4,3);
k2 = [1 1 1; 0.5 1 1; 0.5 0.5 1;0.5 0.5 0.5];
k3 = ones(4);
k = [k1, k2, k3];

I = [i;j;k];

% figure(1);
% imshow(I);

J1 = myConv2( myConv2(I, gx), gy )
size(J1)

J2 = myConv2(I, G)
size(J2)

% J3 = myConv2( myConv2(I, gy), gx )
% size(J3)

% figure(2);
% imshow(J1);

%% Q3 Image Gradient
dx = [1, -1];
dy = [1; -1];

Jx = myConv2(I, gx);
size(Jx)
Jy = myConv2(I, gy);
size(Jy)


Ix = myConv2( myConv2(Jx, dx, false), gy, false )
size(Ix)
Iy = myConv2( myConv2(Jy, dy, false), gx, false )
size(Iy)

mag = sqrt(Ix.*Ix + Iy.*Iy)

figure(1)
subplot(1,2,1); imshow(I);
subplot(1,2,2); imshow(mag);

%% Q4

I1 = [0 0 0 0 0 1 1 1 1 1];
I2 = [0 0 0 0 0 1 1 0 0 0 0 0];
I3 = [0 0 0 0 0 .5 .5 .5 1 1 1 1 1];

a = 0.4;
gx = [1/4-a/2, 1/4, a, 1/4, 1/4-a/2];
gy = [1/4-a/2; 1/4; a; 1/4; 1/4-a/2];


%% Canny Edge Detection
clc;
clear;
close all;

% % Use the specified I as described in handout
% i1 = ones(4); i2 = zeros(4,2); i3 = ones(4,2); i4 = zeros(4,2);
% i = [i1, i2, i3, i4];
% j = zeros(2, 10);
% k1 = 0.5*ones(4,3);
% k2 = [1 1 1; 0.5 1 1; 0.5 0.5 1;0.5 0.5 0.5];
% k3 = ones(4);
% k = [k1, k2, k3];
% 
% I = [i;j;k];

%%Use other img
% I = imread('23025.jpg');
% I = imread('55067.jpg');
% I = imread('24063.jpg');
I = imread('best.JPG');

E = cannyEdge(I);
