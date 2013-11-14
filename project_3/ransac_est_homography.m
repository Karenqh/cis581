function [H,inlier_ind] = ransac_est_homography(y1, x1, y2, x2, thresh)

n_points = length(y1);


maxIter = factorial(n_points)/factorial(n_points-4)/24; %???
min_inliers = round(0.2*n_points);

inlier_ind = [];

iter = 0;
while iter < maxIter
    iter = iter + 1;
    % Randomly sample 4 points
    rnd_idx = randperm(n_points, 4)';
    
    des_y = y1(rnd_idx);
    des_x = x1(rnd_idx);
    src_y = y2(rnd_idx);
    src_x = x2(rnd_idx);

    % Compute homography from samples
    tmpH = est_homography(des_y, des_x, src_y, src_x);

    % Apply homography to the remaining points
%     other_y1 = y1; other_x1 = x1; other_y2 = y2; other_x2 = x2;
%     other_y1(rnd_idx) = [];
%     other_x1(rnd_idx) = [];
%     other_y2(rnd_idx) = [];
%     other_x2(rnd_idx) = [];
    [est_y1 est_x1] = apply_homography(tmpH, y2, x2);
    
    % Vote for this homography
    dists = sqrt((est_y1-y1).^2 + (est_x1-x1).^2);
    
    % If too few inliers then discard this candidate
    if sum(dists<thresh)<min_inliers
        continue;
    % If better than the current best estimate then keep it
    elseif sum(dists<thresh)>size(inlier_ind,1)
%         best_H = tmpH;
        inlier_ind = find(dists<thresh);
        length(inlier_ind)
    end
            
end

% Refine the transformation
H = est_homography(y1(inlier_ind), x1(inlier_ind), y2(inlier_ind), x2(inlier_ind));


