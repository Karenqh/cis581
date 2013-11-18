function img_mosaic = mymosaic_new(img_input)

% Frequently used constants
nr = size(img_input{1},1);
nc = size(img_input{1},2);
[src_cols src_rows] = meshgrid(1:nc, 1:nr);

% For corner detection
sigma = 2;
max_pts = 100; % TUNE THIS!!!!!!!!!!!!!!

% For RANSAC
ransac_thres = 0.2;  %0.5


% Initialization
y = {[]}; x = {[]};
p = {[]}; m = {[]};
H = {[]};

mosaic_pieces = {[]};

for cnt = 1:numel(img_input)
    % RGB to GRAY
    img_gray = rgb2gray(img_input{cnt});
    % Harris corner detection
    cimg = harris(img_gray, sigma);
    % Adaptive non-maxima suppression
    [y{cnt} x{cnt} ~] = anms(cimg, max_pts);
    % Feature descripter
    p{cnt} = feat_desc(img_gray, y{cnt}, x{cnt});
    
    
    if cnt==1
        % For Stitching: set up canvas
        mosaic_pieces{cnt} = uint8(zeros(nr,nc,3));
        mosaic_pieces{cnt} = img_input{cnt};
        H_pre = eye(3);
        
        % Update canvas dimension
        size_x = nc;
        size_y = nr;
        
        % Offset of mosaic piece
        ox(cnt) = 0;

    elseif cnt>1
        % Feature Matching
        m{cnt-1} = feat_match(p{cnt-1},p{cnt});
        good1 = find(m{cnt-1}~=-1);
        good2 = m{cnt-1}(good1);

        y1s = y{cnt-1}(good1);  x1s = x{cnt-1}(good1);
        y2s = y{cnt}(good2);  x2s = x{cnt}(good2);
        
        % RANSAC
        [H{cnt-1},~] = ransac_est_homography(y1s, x1s, y2s, x2s, ransac_thres);
        
        H_now = H_pre*H{cnt-1};
        H_pre = H_now;
        
        % Stitch
        % USE INVERSE WARPING TO AVOID HOLES
        
%         % DEGUGGING using MATLAB function
%         T = maketform('projective', H_now');
%         [h w d] = size(img_input{cnt});
%         img_new = imtransform(img_input{cnt}, T, 'XData', [1 w], 'YData', [1 h]);

        
        % First four corners (FORWARD)
        [corner_xs corner_ys] = apply_homography(H_now,[1;1;nc;nc],[1;nr;nr;1]);
        
        corner_xs = round(corner_xs);
        corner_ys = round(corner_ys);
        
        new_img_nc = max(corner_xs) - min(corner_xs);
        new_img_nr = max(corner_ys) - min(corner_ys);
        mosaic_pieces{cnt} = uint8(zeros(new_img_nr,new_img_nc,3));
        
        % Update final canvas dimension
        size_x = min(corner_xs) + new_img_nc; 
        if new_img_nr > size_y
            size_y = new_img_nr;
        end
        % Offset of mosaic piece
        ox(cnt) = ox(1) + min(corner_xs);

        [tar_cols tar_rows] = meshgrid(1:new_img_nc, 1:new_img_nr);
        tar_cols_list = tar_cols(:);
        tar_rows_list = tar_rows(:);

        [src_x src_y] = apply_homography(inv(H_now), tar_cols(:), tar_rows(:));
        % Filter out points outside boundaries
        leaveout = (src_x<1 | src_x>nc | src_y<1 | src_y>nr);
        src_x(leaveout) = [];
        src_y(leaveout) = [];
        tar_cols_list(leaveout) = [];
        tar_rows_list(leaveout) = [];
        
        ind_r = sub2ind(size(mosaic_pieces{cnt}), ...
            tar_rows_list, tar_cols_list, ones(length(tar_rows_list),1));
        ind_g = sub2ind(size(mosaic_pieces{cnt}), ...
            tar_rows_list, tar_cols_list, 2*ones(length(tar_rows_list),1));
        ind_b = sub2ind(size(mosaic_pieces{cnt}), ...
            tar_rows_list, tar_cols_list, 3*ones(length(tar_rows_list),1));

        % Deal with offsets
        src_x = src_x + min(corner_xs);
        src_y = src_y + min(corner_ys);
        % Interpolation
        vr = interp2(src_cols, src_rows, double(img_input{cnt}(:,:,1)), src_x, src_y);
        vg = interp2(src_cols, src_rows, double(img_input{cnt}(:,:,2)), src_x, src_y);
        vb = interp2(src_cols, src_rows, double(img_input{cnt}(:,:,3)), src_x, src_y);
        
        mosaic_pieces{cnt}(ind_r) = uint8(vr);
        mosaic_pieces{cnt}(ind_g) = uint8(vg);
        mosaic_pieces{cnt}(ind_b) = uint8(vb);
        
        
%         new_x = round(new_x) + ox;
%         new_y = round(new_y) + oy;
% 
%         ind_r = sub2ind(size(img_mosaic), new_y, new_x, ones(length(new_x),1));
%         ind_g = sub2ind(size(img_mosaic), new_y, new_x, 2*ones(length(new_x),1));
%         ind_b = sub2ind(size(img_mosaic), new_y, new_x, 3*ones(length(new_x),1));
% 
%         tmp_im_r = img_input{cnt}(:,:,1);
%         tmp_im_g = img_input{cnt}(:,:,2);
%         tmp_im_b = img_input{cnt}(:,:,3);
% 
%         img_mosaic(ind_r) = tmp_im_r(:);
%         img_mosaic(ind_g) = tmp_im_g(:);
%         img_mosaic(ind_b) = tmp_im_b(:);

    end
end

% Stitching
img_mosaic = uint8(zeros(size_y,size_x,3));
oy = round(size_y/2-size(mosaic_pieces{1},1)/2);

for frame = 1:numel(mosaic_pieces)
    idx = numel(mosaic_pieces)-frame+1;
    

    img_mosaic(oy+1:oy+size(mosaic_pieces{idx},1),...
        ox(idx)+1:ox(idx)+size(mosaic_pieces{idx},2), :) = mosaic_pieces{idx};
end

