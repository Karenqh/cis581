function img = morph_tps_wrapper(im1,im2,source_points,target_points,...
                                    warp_frac,dissolve_frac)

% Take into as arguments two images

inter_pts = source_points*(1-warp_frac) + target_points*warp_frac;

% For source imaage
[a1_x,ax_x,ay_x,w_x] = est_tps(inter_pts, source_points(:,1));
[a1_y,ax_y,ay_y,w_y] = est_tps(inter_pts, source_points(:,2));

morphed_im1 = morph_tps(im1, a1_x, ax_x, ay_x, w_x,...
    a1_y, ax_y, ay_y, w_y, inter_pts, size(im1));

% For target imaage
[a1_x,ax_x,ay_x,w_x] = est_tps(inter_pts, target_points(:,1));
[a1_y,ax_y,ay_y,w_y] = est_tps(inter_pts, target_points(:,2));

morphed_im2 = morph_tps(im2, a1_x, ax_x, ay_x, w_x,...
    a1_y, ax_y, ay_y, w_y, inter_pts, size(im2));

img = morphed_im1*(1-dissolve_frac)+morphed_im2*dissolve_frac;

