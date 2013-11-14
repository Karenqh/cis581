function morphed_im = morph_tps(im_src, a1_x, ax_x, ay_x, w_x,...
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
        
end

% Compute pos of corresponding pixels in source image
xs = a1_x + [J I]*[ax_x; ay_x] + x_W;
ys = a1_y + [J I]*[ax_y; ay_y] + y_W;

% Round the pixels' positions
xs = floor(xs);
ys = floor(ys);
xs(xs<=0) = 1;  xs(xs>nc) = nc;
ys(ys<=0) = 1;  ys(ys>nr) = nr;

xs_plus = xs + 1;  xs_plus(xs_plus>nc) = nc;
ys_plus = ys + 1;  ys_plus(ys_plus>nr) = nr;

src_inds_1 = sub2ind([nr nc], ys, xs);
src_inds_2 = sub2ind([nr nc], ys, xs_plus);
src_inds_3 = sub2ind([nr nc], ys_plus, xs);
src_inds_4 = sub2ind([nr nc], ys_plus, xs_plus);

% Paste pixel values
if numel(sz) == 2
    sz = [sz, 3];
end
% morphed_im = uint8(zeros(sz));
morphed_im_1 = uint8(zeros(sz));
morphed_im_2 = uint8(zeros(sz));
morphed_im_3 = uint8(zeros(sz));
morphed_im_4 = uint8(zeros(sz));

morphed_im_1(inds) = im_src(src_inds_1);
morphed_im_1(inds+nr*nc) = im_src(src_inds_1+nr*nc);
morphed_im_1(inds+2*nr*nc) = im_src(src_inds_1+2*nr*nc);

morphed_im_2(inds) = im_src(src_inds_2);
morphed_im_2(inds+nr*nc) = im_src(src_inds_2+nr*nc);
morphed_im_2(inds+2*nr*nc) = im_src(src_inds_2+2*nr*nc);

morphed_im_3(inds) = im_src(src_inds_3);
morphed_im_3(inds+nr*nc) = im_src(src_inds_3+nr*nc);
morphed_im_3(inds+2*nr*nc) = im_src(src_inds_3+2*nr*nc);

morphed_im_4(inds) = im_src(src_inds_4);
morphed_im_4(inds+nr*nc) = im_src(src_inds_4+nr*nc);
morphed_im_4(inds+2*nr*nc) = im_src(src_inds_4+2*nr*nc);

morphed_im = 0.25*morphed_im_1+0.25*morphed_im_2+0.25*morphed_im_3+0.25*morphed_im_4;