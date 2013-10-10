function [a1,ax,ay,w] = est_tps(pts, target_value)

% Compute DISTANCE matrix
dxs = bsxfun(@minus, pts(:,1), pts(:,1)');
dys = bsxfun(@minus, pts(:,2), pts(:,2)');
dist_square = dxs.^2 + dys.^2;
K = dist_square .* log(dist_square);
% Deal with the NaN
K(isnan(K)) = 0;

% pts is n-by-2
P = [pts, ones(size(pts,1),1)];

lambda = 0.2; %%%%%%???????
bigguy = [K, P; transpose(P), zeros(3)] + lambda*eye( size(pts,1)+3 );

output = bigguy \ [target_value; zeros(3,1)];

ax = output(end-2);
ay = output(end-1);
a1 = output(end);

w = output(1:end-3);


