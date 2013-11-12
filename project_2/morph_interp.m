function morphed_im = morph(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac)

% Some frequently used constants
nr = size(im1, 1);
nc = size(im1, 2);
inds = 1:(nr*nc);

% Generate coordinates
[I J] = ind2sub([nr, nc], inds);
% Convert to column vectors
I = I'; J = J';

% Determine which triangle the pixel is located
% tsearch is removed from 2012b so I use DelnaunayTri instead
inter_pts = im1_pts*(1-warp_frac) + im2_pts*warp_frac;

dt_tmp = DelaunayTri(inter_pts);

% Localization
idx = pointLocation(dt_tmp, J, I);

dt = dt_tmp.Triangulation;
dt_size = size(dt,1);

% Compute the barycentric coordinate
tmp_im1 = uint8( zeros(size(im1)) );
tmp_im1_1 = uint8( zeros(size(im1)) );
tmp_im1_2 = uint8( zeros(size(im1)) );
tmp_im1_3 = uint8( zeros(size(im1)) );
tmp_im1_4 = uint8( zeros(size(im1)) );

tmp_im2 = uint8( zeros(size(im1)) );
tmp_im2_1 = uint8( zeros(size(im1)) );
tmp_im2_2 = uint8( zeros(size(im1)) );
tmp_im2_3 = uint8( zeros(size(im1)) );
tmp_im2_4 = uint8( zeros(size(im1)) );


for tri_i = 1:dt_size
    % Compute the vertice of simplex in Intermediate image
    pt1 = inter_pts(dt(tri_i,1), :);
    pt2 = inter_pts(dt(tri_i,2), :);
    pt3 = inter_pts(dt(tri_i,3), :);
    inter_tri = [[pt1; pt2; pt3]'; 1 1 1];    
    
    % Extract all pixels enclosed by this triangle
    xs = J(idx==tri_i);  % col
    ys = I(idx==tri_i);  % col
    % Convert xy to ij
    inter_ind = sub2ind([nr nc], ys, xs);
    
    % Barycentric coordinates
    bar_coor = inter_tri \ [xs'; ys'; ones(1, length(xs))];
        
    
    %%% Process pixels from SOURCE image
    pt1 = im1_pts(dt(tri_i,1), :);
    pt2 = im1_pts(dt(tri_i,2), :);
    pt3 = im1_pts(dt(tri_i,3), :);
    src_tri_verts = [pt1; pt2; pt3];
    src_pixel = [src_tri_verts'; 1 1 1] * bar_coor;  % 3-by-N
    
    %%%%%%%%%% Bilinear Interpolation
    src_pixel_floor = floor(src_pixel);
    xss = src_pixel_floor(1,:);
    yss = src_pixel_floor(2,:);
    xss(xss<=0) = 1;    xss(xss>nc) = nc;
    yss(yss<=0) = 1;    yss(yss>nr) = nr;
    xss_plus = xss + 1;   xss_plus(xss_plus>nc) = nc;
    yss_plus = yss + 1;   yss_plus(yss_plus>nr) = nr;
    
    src_ind_1 = sub2ind([nr nc], yss, xss);
    src_ind_2 = sub2ind([nr nc], yss, xss_plus);
    src_ind_3 = sub2ind([nr nc], yss_plus, xss);
    src_ind_4 = sub2ind([nr nc], yss_plus, xss_plus);
        
    % PASTE THE IMAGE FROM SRC TO INTERMEDIATE TARGETS
    % rgb channels
    tmp_im1_1(inter_ind) = im1(src_ind_1);
    tmp_im1_1(inter_ind+nr*nc) = im1(src_ind_1+nr*nc);
    tmp_im1_1(inter_ind+2*nr*nc) = im1(src_ind_1+2*nr*nc);
    
    tmp_im1_2(inter_ind) = im1(src_ind_2);
    tmp_im1_2(inter_ind+nr*nc) = im1(src_ind_2+nr*nc);
    tmp_im1_2(inter_ind+2*nr*nc) = im1(src_ind_2+2*nr*nc);

    tmp_im1_3(inter_ind) = im1(src_ind_3);
    tmp_im1_3(inter_ind+nr*nc) = im1(src_ind_3+nr*nc);
    tmp_im1_3(inter_ind+2*nr*nc) = im1(src_ind_3+2*nr*nc);

    
    tmp_im1_4(inter_ind) = im1(src_ind_4);
    tmp_im1_4(inter_ind+nr*nc) = im1(src_ind_4+nr*nc);
    tmp_im1_4(inter_ind+2*nr*nc) = im1(src_ind_4+2*nr*nc);
    
%     tmp_im1 = 0.25*(tmp_im1_1+tmp_im1_2+tmp_im1_3+tmp_im1_4);
    % Avoid over flow (when the sum is over 255 it will clamp)
    tmp_im1 = 0.25*tmp_im1_1 + 0.25*tmp_im1_2 + 0.25*tmp_im1_3 + 0.25*tmp_im1_4;
    
    clear xss yss xss_plus yss_plus
    
    %%% Process pixels from TARGET image
    pt1 = im2_pts(dt(tri_i,1), :);
    pt2 = im2_pts(dt(tri_i,2), :);
    pt3 = im2_pts(dt(tri_i,3), :);
    tar_tri_verts = [pt1; pt2; pt3];
    tar_pixel = [tar_tri_verts'; 1 1 1] * bar_coor;  % 3-by-N
    
    %%%%%%%%%%%%% Bilinear interpolation
    tar_pixel_floor = floor(tar_pixel);
    xss = tar_pixel_floor(1,:);
    yss = tar_pixel_floor(2,:);
    xss(xss<=0) = 1;    xss(xss>nc) = nc;
    yss(yss<=0) = 1;    yss(yss>nr) = nr;
    xss_plus = xss + 1;   xss_plus(xss_plus>nc) = nc;
    yss_plus = yss + 1;   yss_plus(yss_plus>nr) = nr;

    tar_ind_1 = sub2ind([nr nc], yss, xss);
    tar_ind_2 = sub2ind([nr nc], yss, xss_plus);
    tar_ind_3 = sub2ind([nr nc], yss_plus, xss);
    tar_ind_4 = sub2ind([nr nc], yss_plus, xss_plus);
    
    % PASTE THE IMAGE FROM SRC TO INTERMEDIATE TARGETS
    % rgb channels
    tmp_im2_1(inter_ind) = im2(tar_ind_1);
    tmp_im2_1(inter_ind+nr*nc) = im2(tar_ind_1+nr*nc);
    tmp_im2_1(inter_ind+2*nr*nc) = im2(tar_ind_1+2*nr*nc);

    tmp_im2_2(inter_ind) = im2(tar_ind_2);
    tmp_im2_2(inter_ind+nr*nc) = im2(tar_ind_2+nr*nc);
    tmp_im2_2(inter_ind+2*nr*nc) = im2(tar_ind_2+2*nr*nc);

    tmp_im2_3(inter_ind) = im2(tar_ind_3);
    tmp_im2_3(inter_ind+nr*nc) = im2(tar_ind_3+nr*nc);
    tmp_im2_3(inter_ind+2*nr*nc) = im2(tar_ind_3+2*nr*nc);

    tmp_im2_4(inter_ind) = im2(tar_ind_4);
    tmp_im2_4(inter_ind+nr*nc) = im2(tar_ind_4+nr*nc);
    tmp_im2_4(inter_ind+2*nr*nc) = im2(tar_ind_4+2*nr*nc);

    
%     tmp_im2 = 0.25*(tmp_im2_1+tmp_im2_2+tmp_im2_3+tmp_im2_4);
    tmp_im2 = 0.25*tmp_im2_1 + 0.25*tmp_im2_2 + 0.25*tmp_im2_3 + 0.25*tmp_im2_4;

end

% CROSS DISSOLVE
morphed_im = tmp_im1*(1-dissolve_frac) + tmp_im2*dissolve_frac;

