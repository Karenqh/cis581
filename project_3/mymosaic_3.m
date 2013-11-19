function img_mosaic = mymosaic_3(img_input)

% Frequently used constants
nr = size(img_input{1},1);
nc = size(img_input{1},2);
[src_cols src_rows] = meshgrid(1:nc, 1:nr);

% For corner detection
sigma = 2;
max_pts = 100; % TUNE THIS!!!!!!!!!!!!!!

% For RANSAC
ransac_thres = 0.5;  %0.5


% Initialization
y = {[]}; x = {[]};
p = {[]}; m = {[]};
H = {[]};

vr = {[]};  vg = {[]};  vb = {[]};
tar_xs = {[]};  tar_ys = {[]};

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
        % Update canvas dimension
        size_x = nc;
        size_y = nr;

        % Offset of mosaic piece
        ox = 0;
        oy = 0;
    
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
        
        % Update canvas dimensions
        size_x = min(corner_xs) + new_img_nc;
        if new_img_nr>size_y
            size_y = new_img_nr;
            oy = max(0,-1*min(corner_ys));
        end
                
        [tar_cols tar_rows] = ...
            meshgrid(min(corner_xs)+1:min(corner_xs)+new_img_nc, ...
                min(corner_ys)+1:min(corner_ys)+new_img_nr);
        tar_cols_list = tar_cols(:);
        tar_rows_list = tar_rows(:);

        [src_x src_y] = apply_homography(inv(H_now), tar_cols(:), tar_rows(:));
        % Filter out points outside boundaries
        leaveout = (src_x<1 | src_x>nc | src_y<1 | src_y>nr);
        src_x(leaveout) = [];
        src_y(leaveout) = [];
        tar_cols_list(leaveout) = [];
        tar_rows_list(leaveout) = [];
        
        % Get the RGB values from source pixels
        % Interpolation
        vr{cnt} = interp2(src_cols, src_rows, double(img_input{cnt}(:,:,1)), src_x, src_y);
        vg{cnt} = interp2(src_cols, src_rows, double(img_input{cnt}(:,:,2)), src_x, src_y);
        vb{cnt} = interp2(src_cols, src_rows, double(img_input{cnt}(:,:,3)), src_x, src_y);
        
        % Store the subs of source pixels
        tar_xs{cnt} = tar_cols_list;
        tar_ys{cnt} = tar_rows_list;
    end
end

% Stitching
% size_y = size_y + 100;
img_mosaic = uint8(zeros(size_y,size_x,3));
% offset
ox = 0;

% 1st image
img_mosaic(oy+1:oy+nr, ox+1:ox+nc, :) = img_input{1};

for j = 2:numel(img_input)
    ind_r = sub2ind(size(img_mosaic), ...
        tar_ys{j}+oy, tar_xs{j}+ox, ones(length(tar_xs{j}),1));
    ind_g = sub2ind(size(img_mosaic), ...
        tar_ys{j}+oy, tar_xs{j}+ox, 2*ones(length(tar_xs{j}),1));
    ind_b = sub2ind(size(img_mosaic), ...
        tar_ys{j}+oy, tar_xs{j}+ox, 3*ones(length(tar_xs{j}),1));

    img_mosaic(ind_r) = uint8(vr{j});
    img_mosaic(ind_g) = uint8(vg{j});
    img_mosaic(ind_b) = uint8(vb{j});
end
