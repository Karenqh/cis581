function m = feat_match(p1,p2)
% Frequently used constants
sz1 = size(p1, 2);
sz2 = size(p2, 2);

% Create data structure for vectorization
p1_rep = repmat(p1, [sz2 1 1]);
p1_rep = reshape(p1_rep, 64, []);  % 64-by-(n1*n2)
p2_rep = repmat(p2, [1 sz1]);

% Compute SSD between all pairs of corners
% Sum of Squared Difference
ssd_all = sum( (p1_rep - p2_rep).^2 );  % 1-by-(n1*n2)

% Break into pieces to correspond each pixel in 1st image
ssd_all = ( reshape(ssd_all, [], sz1) )';  % n1-by-n2

% Find the 2 Nearest Neighbors
[vals, inds] = sort(ssd_all, 2);

% Ratio of 1st-NN / 2nd-NN
ratio = vals(:,1)./vals(:,2);

% Setup adaptive threshold on ratio
ratio_thres = median(ratio);
adjust_val = 0.05*ratio_thres;
num_pts = round(0.4*sz1);
num_qualified = sum(ratio<=ratio_thres);
while abs(num_qualified-num_pts)>2
    % If too much
    if num_qualified - num_pts > 0
        ratio_thres = ratio_thres - adjust_val;
    % If too few
    elseif num_qualified - num_pts < 0
        ratio_thres = ratio_thres + adjust_val;
    end
    num_qualified = sum(ratio<=ratio_thres);
end

% Get the good matches
m = zeros(sz1, 1);
idx = find(ratio<=ratio_thres);
m(idx) = inds(idx, 1);
m(m==0) = -1;








