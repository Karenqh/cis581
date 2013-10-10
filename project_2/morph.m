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
inter_shape = im1_pts*(1-warp_frac) + im2_pts*warp_frac;

dt_tmp = DelaunayTri(inter_shape);

% Localization
idx = pointLocation(dt_tmp, J, I);

dt = dt_tmp.Triangulation;
dt_size = size(dt,1);

% Compute the barycentric coordinate
tmp_im1 = uint8( zeros(size(im1)) );
tmp_im2 = uint8( zeros(size(im1)) );


for tri_i = 1:dt_size
    % Compute the vertice of simplex in Intermediate image
    pt1 = inter_shape(dt(tri_i,1), :);
    pt2 = inter_shape(dt(tri_i,2), :);
    pt3 = inter_shape(dt(tri_i,3), :);
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
    
    % Convert to row/col and Round
    src_pixel = floor(src_pixel);
    xss = src_pixel(1,:);
    yss = src_pixel(2,:);
    xss(xss<=0) = 1;    xss(xss>nc) = nc;
    yss(yss<=0) = 1;    yss(yss>nr) = nr;
    src_pixel(1,:) = xss;
    src_pixel(2,:) = yss;
    
    % PASTE THE IMAGE FROM SRC TO INTERMEDIATE TARGETS
    src_ind = sub2ind([nr nc], src_pixel(2,:), src_pixel(1,:));
    % rgb channels
    tmp_im1(inter_ind) = im1(src_ind);
    tmp_im1(inter_ind+nr*nc) = im1(src_ind+nr*nc);
    tmp_im1(inter_ind+2*nr*nc) = im1(src_ind+2*nr*nc);
    
    
    %%% Process pixels from TARGET image
    pt1 = im2_pts(dt(tri_i,1), :);
    pt2 = im2_pts(dt(tri_i,2), :);
    pt3 = im2_pts(dt(tri_i,3), :);
    tar_tri_verts = [pt1; pt2; pt3];
    tar_pixel = [tar_tri_verts'; 1 1 1] * bar_coor;  % 3-by-N
    
    % Convert to row/col and Round
    tar_pixel = floor(tar_pixel);
    xss = tar_pixel(1,:);
    yss = tar_pixel(2,:);
    xss(xss<=0) = 1;    xss(xss>nc) = nc;
    yss(yss<=0) = 1;    yss(yss>nr) = nr;
    tar_pixel(1,:) = xss;
    tar_pixel(2,:) = yss;
    
    % PASTE THE IMAGE FROM SRC TO INTERMEDIATE TARGETS
    tar_ind = sub2ind([nr nc], tar_pixel(2,:), tar_pixel(1,:));
    % rgb channels
    tmp_im2(inter_ind) = im2(tar_ind);
    tmp_im2(inter_ind+nr*nc) = im2(tar_ind+nr*nc);
    tmp_im2(inter_ind+2*nr*nc) = im2(tar_ind+2*nr*nc);
    
end

% CROSS DISSOLVE
morphed_im = tmp_im1*(1-dissolve_frac) + tmp_im2*dissolve_frac;

