function img_mosaic = mymosaic(img_input)
% Preprocess:  2nd pic as the reference
im1 = rgb2gray(img_input{2});  % Target
im2 = rgb2gray(img_input{1});  % Source

%% Corner detection using Harris detector
sigma = 2;
cimg1 = harris(im1, sigma);
cimg2 = harris(im2, sigma);

% Avoid the 4 image corners
cimg1(1,1) = 0;
cimg1(end,end) = 0;
cimg2(1,1) = 0;
cimg2(end,end) = 0;

%% Adaptive Non-maxima Supprestion
max_pts = 80; % TUNE THIS!!!!!!!!!!!!!!

[y1 x1 ~] = anms(cimg1, max_pts);
[y2 x2 ~] = anms(cimg2, max_pts);

disp('CORNER DETECTION DONE')

%% Feature descripter
p1 = feat_desc(im1, y1, x1);
p2 = feat_desc(im2, y2, x2);

%% Feature Matching
m = feat_match(p1,p2);

good1 = find(m~=-1);
good2 = m(good1);

y1s = y1(good1);  x1s = x1(good1);
y2s = y2(good2);  x2s = x2(good2);

disp('FEATURE MATCHING DONE')

%% RANSAC
thresh = 0.5;
[H,~] = ransac_est_homography(y1s, x1s, y2s, x2s, thresh);

disp('RANSAC DONE')

%% Stitch
size_x = 1600;  size_y = 1600;
img_mosaic = uint8(zeros(size_y,size_x,3));
[cols rows] = meshgrid(1:size_x, 1:size_y);
ox = 700; oy = 700;

% Place the reference frame
nr = size(im1,1);  nc = size(im1,2);
img_mosaic((ox+1):(nr+ox), (oy+1):(nc+oy), :) = img_input{2};

% Placed the transformed other frames
[src_cols src_rows] = meshgrid(1:size(im1,2), 1:size(im1,1));
[src_new_x src_new_y] = apply_homography(H, src_cols(:), src_rows(:));

%%%%%%% INTERPOLATE %%%%%%%
src_new_x = round(src_new_x) + ox;
src_new_y = round(src_new_y) + oy;

src_ind_r = sub2ind(size(img_mosaic), src_new_y, src_new_x, ones(numel(im1),1));
src_ind_g = sub2ind(size(img_mosaic), src_new_y, src_new_x, 2*ones(numel(im1),1));
src_ind_b = sub2ind(size(img_mosaic), src_new_y, src_new_x, 3*ones(numel(im1),1));

tmp_im_r = img_input{1}(:,:,1);
tmp_im_g = img_input{1}(:,:,2);
tmp_im_b = img_input{1}(:,:,3);

img_mosaic(src_ind_r) = tmp_im_r(:);
img_mosaic(src_ind_g) = tmp_im_g(:);
img_mosaic(src_ind_b) = tmp_im_b(:);




