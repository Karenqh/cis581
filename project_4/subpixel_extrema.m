function [xs ys] = subpixel_extrema(cur_layer, lower_layer, upper_layer, ex_inds)
fx = [-1 1];
fy = [-1;1];
% Approximate Hessian using difference between nerighbors

% 1st derivative
dx1 = imfilter(cur_layer, fx, 'symmetric', 'same');
dy1 = imfilter(cur_layer, fy, 'symmetric', 'same');
%   ??????
da11 = cur_layer- lower_layer;
da12 = upper_layer - cur_layer;

% 2nd derivative
dx2 = imfilter(dx1, fx, 'symmetric', 'same');
dxy = imfilter(dx1, fy, 'symmetric', 'same');
%%%%%%%%%%%
dupx= imfilter(upper_layer, fx, 'symmetric', 'same');
dxa = dupx - dx1;  %%%%%%%%%%%

dy2 = imfilter(dy1, fy, 'symmetric', 'same');
dyx = imfilter(dy1, fx, 'symmetric', 'same');
dupy= imfilter(upper_layer, fy, 'symmetric', 'same');
dya = dupy - dy1;  %%%%%%%%%%%

da2 = da12 - da11;
dax = imfilter(da11, fx, 'symmetric', 'same');
day = imfilter(da11, fy, 'symmetric', 'same');

% Extract coarse extrema
GRADIENT = double([dx1(ex_inds)'; dy1(ex_inds)'; da11(ex_inds)']);
HESSIAN = [dx2(ex_inds)'; dyx(ex_inds)'; dax(ex_inds)';...
           dxy(ex_inds)'; dy2(ex_inds)'; day(ex_inds)';...
           dxa(ex_inds)'; dya(ex_inds)'; da2(ex_inds)'];
HESSIAN = double(reshape(HESSIAN, [3,3,length(ex_inds)]));

%%%%%%%%% SOMETHING WRONG! SINGULARITY EVERYWHERE %%%%



% locate refined kepoints
%%%%% VECTORIZATION !!!! %%%%%%%
key_pts = zeros(3, length(ex_inds));
for cnt = 1:length(ex_inds)
    key_pts(:,cnt) = HESSIAN(:,:,cnt) \ GRADIENT(:,cnt);
end
