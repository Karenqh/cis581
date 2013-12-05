function feature_descriptor(input_img, KeyPoints)

nr = size(input_img,1);
nc = size(input_img,2);

% Image blurring: gaussian filter level depending on scale

% Precompute gradients of input image


% 1st derivative
gx = [diff(input_img,1,2), zeros(nr,1)];
gy = [diff(input_img,1,1); zeros(1,nc)];




% Orientation invariance: rotate relative to keypoint orientation


%