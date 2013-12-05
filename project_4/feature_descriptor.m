function feature_descriptor(im, KeyPoints)

nr = size(im,1);
nc = size(im,2);
w_size = 32;  %????????

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
    


    % Orientation invariance: rotate relative to keypoint orientation


%
end