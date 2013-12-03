function keypoints_inds = localize_keypoints(cur_dog, extrema_inds)
% Get robust keypoint by rejecting extrema with low contrast
% and extrema along edges

%------ Eliminate low contrast points
contrast_thres = 0.03*max(max(abs(cur_dog)));
extrema_inds = extrema_inds( abs(cur_dog(extrema_inds)) > contrast_thres );

%------ Eliminate points along edges
% Approximate Hessian using difference between nerighbors

%%%%%%% LET'S SEE WHICH IS FASTER
nr = size(cur_dog,1);
nc = size(cur_dog,2);
% 1st derivative
dx = [diff(cur_dog,1,2), zeros(nr,1)];
dy = [diff(cur_dog,1,1); zeros(1,nc)];
% 2nd derivative
dxx = [diff(dx,1,2), zeros(nr,1)];
dxy = [diff(dx,1,1); zeros(1,nc)];

dyx = [diff(dy,1,2), zeros(nr,1)];
dyy = [diff(dy,1,1); zeros(1,nc)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fx = [-1 1];
% fy = [-1;1];
% % 1st derivative
% dx = imfilter(cur_dog, fx, 'symmetric', 'same');
% dy = imfilter(cur_dog, fy, 'symmetric', 'same');
% % 2nd derivative
% dxx = imfilter(dx, fx, 'symmetric', 'same');
% dxy = imfilter(dx, fy, 'symmetric', 'same');
% dyy = imfilter(dy, fy, 'symmetric', 'same');
% dyx = imfilter(dy, fx, 'symmetric', 'same');

% Hessian Matrix
HESSIAN = [dxx(extrema_inds)'; 
           dyx(extrema_inds)'; 
           dxy(extrema_inds)';
           dyy(extrema_inds)'];
       
HESSIAN = reshape(HESSIAN, [2,2,length(extrema_inds)]);

%%%%%%%%%%%% NO FOR LOOP EVER!!!
keypoints_inds = [];
eigen_ratio_thres = 10;
for i=1:length(extrema_inds)
    ratio = trace(HESSIAN(:,:,i))^2 / det(HESSIAN(:,:,i));
    if ratio <= eigen_ratio_thres
        keypoints_inds = cat(1, keypoints_inds, extrema_inds(i));
    end
end