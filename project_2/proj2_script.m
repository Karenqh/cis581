%% CIS 581 PROJECT 2 SCRIPT %%

% Select control points
close all;
clear; clc;
load('cpstruct')
img1 = imread('qiner_ready.jpg');
img2 = imread('hit_girl_ready.jpg');
 cpselect(img1,img2, cpstruct2);

%% Generate Triangluations
load('source')
load('target')

% % First generate the average shape
mid_shape = (source_points + target_points)/2;

dt2 = DelaunayTri(source_points, [24 34]); %!!!!!!!

%
% warp_frac = 1;
% dissolve_frac = 1; 
% 
%     output = morph3(img1, img2, source_points, target_points,...
%         dt2, warp_frac, dissolve_frac);


n_frame = 60;

frames = cell(n_frame, 1);
tic;
for cnt = 1:n_frame
    warp_frac = 1/(n_frame-1)*(cnt-1)
%     dissolve_frac = 0;
    dissolve_frac = warp_frac;

    frames{cnt} = morph3(img1, img2, source_points, target_points,...
        dt2, warp_frac, dissolve_frac);
end
toc;

%%
figure(5);
for cnt = 1:n_frame
    imshow(frames{cnt})
    pause(0.1)
    drawnow;
end



%%

DT = dt2;
DT.X = mid_shape;

% % Draw the triangulars
% dt1 = DelaunayTri(source_points);
dt1 = dt2;
dt1.X = source_points;
figure(1)
imshow(img1)
hold on;

% dt1 = DT;
% dt1.X = source_points;
triplot(dt1)
triplot(DT, 'g');
hold off;

figure(2)
imshow(img2); hold on;
% dt2 = DT;
% dt2.X = target_points;
triplot(dt2)
triplot(DT, 'g')
hold off;