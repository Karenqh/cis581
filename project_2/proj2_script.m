%% CIS 581 PROJECT 2 SCRIPT %%

% Select control points
close all;
clear; clc;
% img = imread('qiner_ready.jpg');
% img_croped = imcrop(img);
% %%
% img2 = imresize(img_croped, [400 400]);
% imwrite(img2, 'qiner_new.jpg', 'jpeg')
% load('cpstruct')
load('input')
load('base')
img1 = imread('qiner_ready.jpg');
img2 = imread('hit_girl_ready.jpg');
%  cpselect(img1,img2, input_points, base_points);

%% Generate Triangluations
% load('source')
% load('target')

load('input')
load('base')

% % First generate the average shape
% mid_shape = (source_points + target_points)/2;

dt2 = DelaunayTri(input_points, [24 34]); %!!!!!!!

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
    dissolve_frac = warp_frac;

    frames{cnt} = morph(img1, img2, input_points, base_points,...
        dt2, warp_frac, dissolve_frac);
end
toc;

%%
h = figure(5); clf;
video = VideoWriter('tps.avi'); 
video.FrameRate = 10;
open(video); 
n_frame = 60;

for cnt = 1:n_frame
%     imshow(frames{cnt})
%     pause(0.1)
%     drawnow;
        
  image(frames{cnt}); 
  axis image; 
  axis off; 
  F = getframe(gcf); 
  writeVideo(video,F); 
    

end
close(video);



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

%%   %%%%%%%%%%%%%%  THIN PLATE SPLINE %%%%%%%%%%%%
close all;
clear; clc;

im1 = imread('qiner_ready.jpg');
im2 = imread('hit_girl_ready.jpg');

load('input')
load('base')

inter_pts = (input_points + base_points)/2;

n_frame = 60;
frames = cell(n_frame,1);
for cnt = 1:n_frame
    warp_frac = 1/(n_frame-1)*(cnt-1)
    dissolve_frac = warp_frac;
    
    inter_pts = input_points*(1-warp_frac) + base_points*warp_frac;

    % For source imaage
    [a1_x,ax_x,ay_x,w_x] = est_tps(inter_pts, input_points(:,1));
    [a1_y,ax_y,ay_y,w_y] = est_tps(inter_pts, input_points(:,2));
    
    morphed_im1 = morph_tps(im1, a1_x, ax_x, ay_x, w_x,...
        a1_y, ax_y, ay_y, w_y, inter_pts, size(im1));

    % For target imaage
    [a1_x,ax_x,ay_x,w_x] = est_tps(inter_pts, base_points(:,1));
    [a1_y,ax_y,ay_y,w_y] = est_tps(inter_pts, base_points(:,2));
    
    morphed_im2 = morph_tps(im2, a1_x, ax_x, ay_x, w_x,...
        a1_y, ax_y, ay_y, w_y, inter_pts, size(im2));
    
    frames{cnt} = morphed_im1*(1-dissolve_frac)+morphed_im2*dissolve_frac;

end



