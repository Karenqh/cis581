function img_mosaic = mymosaic_new(img_input)

% Frequently used constants
nr = size(img_input{1},1);
nc = size(img_input{1},2);
[src_cols src_rows] = meshgrid(1:nc, 1:nr);

% For corner detection
sigma = 2;
max_pts = 100; % TUNE THIS!!!!!!!!!!!!!!

% For RANSAC
ransac_thres = 0.5;

% For Stitching: set up canvas
size_x = 1200;  size_y = 1200;
img_mosaic = uint8(zeros(size_y,size_x,3));
[cols rows] = meshgrid(1:size_x, 1:size_y);
ox = 1; oy = 400;

% Initialization
img_gray = {[]};
y = {[]}; x = {[]};
p = {[]}; m = {[]};
H = {[]};

for cnt = 1:numel(img_input)
    % RGB to GRAY
    img_gray{cnt} = rgb2gray(img_input{cnt});
    % Harris corner detection
    cimg = harris(img_gray{cnt}, sigma);
    % Adaptive non-maxima suppression
    [y{cnt} x{cnt} ~] = anms(cimg, max_pts);
    % Feature descripter
    p{cnt} = feat_desc(img_gray{cnt}, y{cnt}, x{cnt});
    
    
    if cnt==1
        img_mosaic((oy+1):(nr+oy), (ox+1):(nc+ox), :) = img_input{cnt};
        H_pre = eye(3);
    elseif cnt>1
        % Feature Matching
        m{cnt-1} = feat_match(p{cnt-1},p{cnt});
        good1 = find(m{cnt-1}~=-1);
        good2 = m{cnt-1}(good1);

        y1s = y{cnt-1}(good1);  x1s = x{cnt-1}(good1);
        y2s = y{cnt}(good2);  x2s = x{cnt}(good2);
        
        % RANSAC
        [H{cnt-1},~] = ransac_est_homography(y1s, x1s, y2s, x2s, ransac_thres);

        % Stitch
        H_now = H_pre*H{cnt-1};
        H_pre = H_now;
        [src_new_x src_new_y] = apply_homography(H_now, src_cols(:), src_rows(:));

        % Placed the transformed other frames
        src_new_x = round(src_new_x) + ox;
        src_new_y = round(src_new_y) + oy;

        src_ind_r = sub2ind(size(img_mosaic), src_new_y, src_new_x, ones(length(src_new_x),1));
        src_ind_g = sub2ind(size(img_mosaic), src_new_y, src_new_x, 2*ones(length(src_new_x),1));
        src_ind_b = sub2ind(size(img_mosaic), src_new_y, src_new_x, 3*ones(length(src_new_x),1));

        tmp_im_r = img_input{cnt}(:,:,1);
        tmp_im_g = img_input{cnt}(:,:,2);
        tmp_im_b = img_input{cnt}(:,:,3);

        img_mosaic(src_ind_r) = tmp_im_r(:);
        img_mosaic(src_ind_g) = tmp_im_g(:);
        img_mosaic(src_ind_b) = tmp_im_b(:);

    end
end




