function morphed_im = morph_tsp(im_src, a1_x, ax_x, ay_x, w_x,...
    a1_y, ax_y, ay_y, w_y, ctr_pts, sz)

% f_x = a1_x + ax_x*x + ay_x*y + sum(U_distance)
% f_y = a1_y + ax_y*x + ay_y*y + sum(U_distance)

% Some frequently used constants
nr = size(im_src, 1);
nc = size(im_src, 2);
inds = 1:(nr*nc);
% Generate coordinates
[I J] = ind2sub([nr, nc], inds');

% Compute the weighting part for all query points
x_W = zeros(length(inds), 1);
y_W = zeros(length(inds), 1);
for i = 1:size(ctr_pts,1)
    dxs = J - ctr_pts(i, 1);
    dys = I - ctr_pts(i, 2);
    dist_square = dxs.^2 + dys.^2;
    % Deal with possible NaN
    inc = dist_square .* log(dist_square);
    inc(isnan(inc)) = 0;
    
    x_W = x_W + inc*w_x(i);
    y_W = y_W + inc*w_y(i);
    
    % Affine part
    
end

% Compute pos of corresponding pixels in source image
xs = a1_x + [J I]*[ax_x; ay_x] + x_W;
ys = a1_y + [J I]*[ax_y; ay_y] + y_W;

% Round the pixels' positions
xs = round(xs);
ys = round(ys);
xs(xs<=0) = 1;  xs(xs>nc) = nc;
ys(ys<=0) = 1;  ys(ys>nr) = nr;

src_inds = sub2ind([nr nc], xs, ys);

% Paste pixel values
morphed_im = uint8(zeros(sz));
morphed_im(inds) = im_src(src_inds);
morphed_im(inds+nr*nc) = im_src(src_inds+nr*nc);
morphed_im(inds+2*nr*nc) = im_src(src_inds+2*nr*nc);
