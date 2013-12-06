function [g_weight] = feature_descriptor(im, KeyPoints)
nr = size(im,1);
nc = size(im,2);
[cols rows] = meshgrid(1:nc, 1:nr);
w_size = 16;  %???????? EVEN num

% Generate gaussian weighting function
g_sigma = w_size/2;
g_weight = fspecial('gaussian', [w_size w_size], g_sigma);

tic;
Descriptors = {[]};
for cnt = 1:numel(KeyPoints)
    % Image blurring: gaussian filter level depending on scale
    scale = KeyPoints{cnt}.scale;
    h = fspecial('gaussian', [5 5], scale*1.5);  % TUNE
    im = imfilter(im, h, 'symmetric', 'same');

    % Compute gradients of input image
    gx = [diff(im,1,2), zeros(nr,1)];
    gy = [diff(im,1,1); zeros(1,nc)];
    [g_dir, g_mag] = cart2pol(gx, gy);


    % Sample around keypoints 
    keys_xy = KeyPoints{cnt}.location;
    [mask_xs mask_ys] = meshgrid(-w_size/2:(w_size/2-1), -w_size/2:(w_size/2-1));

    %%%%%%%%%%%%%%%% STUPID FOR LOOP
    Descriptors{cnt} = [];
    for k = 1:size(keys_xy,1)
        % Rotate for orientation invariance
        key_ori = KeyPoints{cnt}.orientation(k);
        %%%%%%%%%%%  CHECK THE CORRECTNESS OF ROTATION MATRIX %%%%%%%%%%
        rot = [cos(key_ori), -sin(key_ori); sin(key_ori), cos(key_ori)];
        neighbors = (rot*[mask_xs(:)'; mask_ys(:)'])';  % n-by-2
        % Add to the location of the key point
        neighbor_xs = neighbors(:,1) + keys_xy(k,1);  % 16-by-1
        neighbor_ys = neighbors(:,2) + keys_xy(k,2);
        % Boundary check
        if sum(neighbor_xs<1 | neighbor_ys<1 | neighbor_xs>nc | neighbor_ys>nr) >0
            % discard this keypoint
            KeyPoints{cnt}.location(k,:) = [];
            KeyPoints{cnt}.orientation(k) = [];
            continue;
        end
        
        % interpolation
        mags = interp2(cols, rows, g_mag, neighbor_xs, neighbor_ys);
        dirs = interp2(cols, rows, g_dir, neighbor_xs, neighbor_ys);

        % Weight the mag with gaussian
        mags = reshape(mags,[16 16]).*g_weight;
        % Subtract key ori for orientation invariance
        dirs = reshape(dirs,[16 16]) - key_ori;
                
        % STUPID LOOP: rearrange descriptor
        patch_dir = [];
        patch_mag = [];
        for i=1:4:13
            for j=1:4:13
                subpatch_dir = dirs(i:i+3, j:j+3);
                patch_dir = cat(2, patch_dir, subpatch_dir(:));
                
                subpatch_mag = mags(i:i+3, j:j+3);
                patch_mag = cat(2, patch_mag, subpatch_mag(:));
            end
        end
        
        bin_unit = pi/4;

        % 8-by-16
        hist_ori = zeros(8,16);
        % 16x16, each COLOMN is a sub-window among 4x4 windows
        hist_prep = floor(patch_dir/bin_unit); 

        for h=-4:4
            mag_tmp = patch_mag;
            mag_tmp(hist_prep~=h) = 0;
            % Store the values for this bin
            % TRILINIEAR INTERPOLATION
            if h==4
                interp_weight = 1- abs(patch_dir-pi*7/8)/bin_unit;
                hist_ori(h+4,:) = sum(mag_tmp.*interp_weight);
            else
                bin_centers = (hist_prep+1/2)*bin_unit;
                interp_weight = 1-abs(patch_dir-bin_centers)/bin_unit;
                hist_ori(h+5,:) = sum(mat_tmp.*interp_weight);
            end
        end
        
        % Reshape into vector and Normalization
        descriptor = hist_ori(:)/max(hist_ori(:));
        % Illumination invariance by CLAMP on gradients
        descriptor(descriptor>0.2) = 0.2;
        Descriptors{cnt}(:,k) = descriptor;

    end
    
end
toc;

debugging = false;