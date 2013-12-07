function [key_xs key_ys sigmas] = subpixel_extrema(cur_layer, lower_layer, upper_layer, ex_inds)
global nr nc
nr = size(cur_layer,1);
nc = size(cur_layer,2);

% 1st round
[offset_x, offset_y] = grad_hessian(cur_layer, lower_layer, upper_layer, ex_inds);

% Don't we care about the offset on scale space?

% If offset in spatial space is greater than 0.5, re-locate origins
% and re-solve subpixel extrema
[ex_ys  ex_xs] = ind2sub([nr nc],ex_inds);
% Add the offsets from fitting above
ex_ys = round(ex_ys+offset_y);
ex_xs = round(ex_xs+offset_x);
% Keep good ones
good_idx = logical(abs(offset_x)<=0.5 & abs(offset_y)<=0.5);
key_xs = ex_xs(good_idx);
key_ys = ex_ys(good_idx);

% 2nd round
new_ex_xs = round(ex_xs(~good_idx));
new_ex_ys = round(ex_ys(~good_idx));
bound_check = logical(new_ex_xs<1|new_ex_xs>nc|new_ex_ys<1|new_ex_ys>nr);
new_ex_xs(bound_check) = [];
new_ex_ys(bound_check) = [];
new_ex_inds = sub2ind([nr nc], new_ex_ys, new_ex_xs);

[offset_x, offset_y] = grad_hessian(cur_layer, lower_layer, upper_layer, new_ex_inds);
% ARE WE ASSUMING NO ONE IS EXCEEDING 0.5 NOW ???
key_xs = cat(1, key_xs, new_ex_xs + offset_x);
key_ys = cat(1, key_ys, new_ex_ys + offset_y);


end

function [offset_x, offset_y]=grad_hessian(cur_layer, lower_layer, upper_layer, ex_inds)
% sub-routain for calculating gradient and hessian 
global nr nc

% Approximate Hessian using difference between nerighbors
% The diff way I used is slightly different from what TA has introduced

% 1st derivative
dx = [diff(cur_layer,1,2), zeros(nr,1)];
dy = [diff(cur_layer,1,1); zeros(1,nc)];
da = (upper_layer - lower_layer)/2;
da1 = cur_layer- lower_layer;
da2 = upper_layer - cur_layer;
% 2nd derivative
dxx = [diff(dx,1,2), zeros(nr,1)];
dxy = [diff(dx,1,1); zeros(1,nc)];
dxup= [diff(upper_layer,1,2), zeros(nr,1)];
dxa = dxup - dx;  

dyy = [diff(dy,1,1); zeros(1,nc)];
dyx = [diff(dy,1,2), zeros(nr,1)];
dyup= [diff(upper_layer,1,1); zeros(1,nc)];
dya = dyup - dy; 

daa = da2 - da1;
dax = [diff(da1,1,2), zeros(nr,1)];
day = [diff(da1,1,1); zeros(1,nc)];

% Extract coarse extrema
GRADIENT = double([dx(ex_inds)'; dy(ex_inds)'; da(ex_inds)']);
HESSIAN = [dxx(ex_inds)'; dyx(ex_inds)'; dax(ex_inds)';
           dxy(ex_inds)'; dyy(ex_inds)'; day(ex_inds)';
           dxa(ex_inds)'; dya(ex_inds)'; daa(ex_inds)'];
HESSIAN = double(reshape(HESSIAN, [3,3,length(ex_inds)]));

% locate refined kepoints
%%%%% VECTORIZATION !!!! %%%%%%%
key_pts = zeros(3, length(ex_inds));
for cnt = 1:length(ex_inds)
    key_pts(:,cnt) = -1*HESSIAN(:,:,cnt) \ GRADIENT(:,cnt);
end
offset_x = key_pts(1,:)';
offset_y = key_pts(2,:)';
% sigmas = key_pts(3,:)';

end




