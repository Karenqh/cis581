function img_mosaic = mymosaic(img_input)
% Preprocess:  2nd pic as the reference
im1 = rgb2gray(img_input{2});
im2 = rgb2gray(img_input{1});

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


%% Feature descripter
p1 = feat_desc(im1, y1, x1);
p2 = feat_desc(im2, y2, x2);

%% Feature Matching
m = feat_match(p1,p2);

good1 = find(m~=-1);
good2 = m(good1);

y1s = y1(good1);  x1s = x1(good1);
y2s = y2(good2);  x2s = x2(good2);


%% RANSAC
thresh = 0.5;
[H,~] = ransac_est_homography(y1s, x1s, y2s, x2s, thresh);

%% Stitch
[cols rows] = meshgrid(1:size(im1,2), 1:size(im1,1));
im1_new = H*[rows(:); cols(:); ones(1,numel(cols))];

% warping

