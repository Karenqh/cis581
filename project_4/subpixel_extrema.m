function [xs ys sigmas] = subpixel_extrema(cur_layer, lower_layer, upper_layer, ex_inds)

% Approximate Hessian using difference between nerighbors
nr = size(cur_layer,1);
nc = size(cur_layer,2);
% 1st derivative
dx = [diff(cur_layer,1,2), zeros(nr,1)];
dy = [diff(cur_layer,1,1); zeros(1,nc)];
da1 = cur_layer- lower_layer;
da2 = upper_layer - cur_layer;
% 2nd derivative
dxx = [diff(dx,1,2), zeros(nr,1)];
dxy = [diff(dx,1,1); zeros(1,nc)];
%%%%%%%%%%%
dxup= [diff(upper_layer,1,2), zeros(nr,1)];
dxa = dxup - dx;  %%%%%%%%%%%

dyy = [diff(dy,1,1); zeros(1,nc)];
dyx = [diff(dy,1,2), zeros(nr,1)];
dyup= [diff(upper_layer,1,1); zeros(1,nc)];
dya = dyup - dy;  %%%%%%%%%%%

daa = da2 - da1;
dax = [diff(da1,1,2), zeros(nr,1)];
day = [diff(da1,1,1); zeros(1,nc)];

% Extract coarse extrema
GRADIENT = double([dx(ex_inds)'; dy(ex_inds)'; da1(ex_inds)']);
HESSIAN = [dxx(ex_inds)'; dyx(ex_inds)'; dax(ex_inds)';
           dxy(ex_inds)'; dyy(ex_inds)'; day(ex_inds)';
           dxa(ex_inds)'; dya(ex_inds)'; daa(ex_inds)'];
HESSIAN = double(reshape(HESSIAN, [3,3,length(ex_inds)]));


% locate refined kepoints
%%%%% VECTORIZATION !!!! %%%%%%%
key_pts = zeros(3, length(ex_inds));
for cnt = 1:length(ex_inds)
    key_pts(:,cnt) = HESSIAN(:,:,cnt) \ GRADIENT(:,cnt);
end
xs = key_pts(1,:)';
ys = key_pts(2,:)';
sigmas = key_pts(3,:)';

% Rejection on low contrast

% Rejection along edges



