function E = cannyEdge(originalI)

% 0. Smooth
% (a) compute local edge normal orientation,
% (b) seek local maximum in the edge normal orientation,
% (c) continue search in the edge orientation of detected edge point.
global J_mag J_dir linked_edge rows cols nr nc
global global_thres local_maxima visited_idx

%%Preprocess Input image
% Convert to grayscale image
if ndims(originalI)==3
    I = rgb2gray(originalI);
else
    I = originalI;
end

[nr, nc] = size(I);


% 2D Gaussian Filter
% a = 0.3;
% gx = [1/4-a/2, 1/4, a, 1/4, 1/4-a/2];
% gy = [1/4-a/2; 1/4; a; 1/4; 1/4-a/2];
% G = conv2(gx,gy);

G = fspecial('gaussian', [5 5], 8);
[gx, gy] = gradient(G);


% Apply convolution
Jx = myConv2(I, gx);
Jy = myConv2(I, gy);


% Get the edge norm direction
[J_dir, J_mag] = cart2pol(Jx, Jy);

% Determine proper thresholds for local maxima 
max_grad = max(max(J_mag));
tentative_coeff = 0.6;

    function ratio = nEdgePoints(coeff)
        counts = sum(sum(logical(J_mag>coeff*max_grad)));
        ratio = counts/numel(J_mag);
    end

edge_ratio = 0.23;
tmp_ratio = nEdgePoints(tentative_coeff);
% Set a limit on iteration times
iter_max = 5000;
cnt = 0;
while abs(tmp_ratio-edge_ratio)>0.02 && cnt<iter_max
    if tmp_ratio>edge_ratio
        % If there are too many potential edge points
        tentative_coeff = tentative_coeff + 0.02;
    else
        % If there are too few potential edge points
        tentative_coeff = tentative_coeff - 0.02;
    end
    tmp_ratio = nEdgePoints(tentative_coeff);
    
    cnt = cnt + 1;
end

global_thres = tentative_coeff*max_grad

%% Search for local maxima
[cols, rows] = meshgrid(1:size(I,2), 1:size(I,1));

% Get matrices of neighbors 
x1 = cols + cos(J_dir);
y1 = rows + sin(J_dir);
mag1 = interp2(cols, rows, J_mag, x1, y1);

x2 = cols - cos(J_dir);
y2 = rows - sin(J_dir);
mag2 = interp2(cols, rows, J_mag, x2, y2);

local_maxima = find( logical(J_mag>mag1 & J_mag>mag2 & J_mag>global_thres)==1 );

%% Link edges


linked_edge = [];
visited_idx = [];

%%%%%%%%% Simple Edge Linking Function %%%%%%%%%
start_thres = min(global_thres*3, max_grad * 0.2)  % 5, 0.2
cont_thres = global_thres * 0.3
% cont_thres = 0.3*start_thres
    % Predict the next edge point
    for cnt = 1:length(local_maxima)
        idx = local_maxima(cnt);
        edge_linking(idx, start_thres, cont_thres);
    end

    
% % %%%%%%%%% Dynamics Hysteresis %%%%%%%%%
%     for cnt = 1:length(local_maxima)
%         idx = local_maxima(cnt);
%         dynamic_hysteresis(idx, start_thres, cont_thres);
%     end



first_cut = zeros(size(I));
first_cut(local_maxima) = 1;

second_cut = zeros(size(I));
second_cut(linked_edge) = 1;
% length(linked_edge)

% addition = logical(first_cut) | logical(second_cut);
% noise = logical(addition) & ~logical(second_cut);
% final = addition - noise;
% E = final;

E = logical(second_cut) | logical(first_cut);

figure(5); imagesc(second_cut); colormap(gray);


end

function flag = is_valid(sub)
    % Check if the subscriptions exceed the image boundary
    global nr nc
    if sub(1)<1 || sub(1)>nr || sub(2)<1 || sub(2)>nc
        flag = false;
    else
        flag = true;
    end

end

function [pt1, pt2, ratio] = interp_helper(theta)
    % Determine two pixels used for intoplation
    % Due to the symmetricity, only need to consider 0=<theta<pi
    theta = abs(theta);
    if theta>=0 && theta<=pi/4
        pt1 = [0 1]; pt2 = [1 1];
        ratio = tan(theta);
    elseif theta>pi/4 && theta<=pi/2
        pt1 = [1 0]; pt2 = [1 1];
        ratio = tan(pi/2 - theta);
    elseif theta>pi/2 && theta<=pi*0.75
        pt1 = [1 0]; pt2 = [1 -1];
        ratio = tan(theta - pi/2);
    elseif theta>pi*0.75 && theta<=pi
        pt1 = [0 -1]; pt2 = [1, -1];
        ratio = tan(pi - theta);
    end    
end


function edge_linking(idx, start_thres, cont_thres)
    global linked_edge visited_idx J_mag J_dir rows cols nr nc
    
    % Check if higher than start_thres
    if J_mag(idx)<start_thres
        return;
    end

    linked_edge = cat(2, linked_edge, idx);


    while true 
        if ~isempty(find(visited_idx==idx, 1))
            return;
        end

        visited_idx = cat(2, visited_idx, idx);

        % Predict the next edge point
        tangent_dir = J_dir(idx) - pi/2;
        % Reduce angles to [-pi, pi)
        tangent_dir = mod(tangent_dir, 2*pi);
        if tangent_dir >= pi
            tangent_dir = tangent_dir - 2*pi;
        end

        [pt1, pt2, ~] = interp_helper(tangent_dir);

        % Now we only consider one neighbor
        pt1(1) = pt1(1) * sign(tangent_dir);
        pt2(1) = pt2(1) * sign(tangent_dir);

        pt1_sub = [rows(idx)+pt1(1) cols(idx)+pt1(2)];
        pt2_sub = [rows(idx)+pt2(1) cols(idx)+pt2(2)];

        % Check if the candidate pixels are within boundary
        if ~is_valid(pt1_sub) && ~is_valid(pt2_sub)
            return;
        end

        % If one of the two candidates is invalid
        if ~is_valid(pt1_sub)
            pt1_sub = pt2_sub;
        elseif ~is_valid(pt2_sub)
            pt2_sub = pt1_sub;
        end

        % Convert subscription into index
        pt1_idx = sub2ind([nr nc], pt1_sub(1), pt1_sub(2));
        pt2_idx = sub2ind([nr nc], pt2_sub(1), pt2_sub(2));

        candidate = [pt1_idx pt2_idx];
        [mag, ind] = max(J_mag(candidate));
        next_idx = candidate(ind);

        if mag >= cont_thres
            % Recursively link the edge
            idx = next_idx;
           
            linked_edge = cat(2,linked_edge, idx);
        else
            return;
        end
    end
end

%%%%%%%% This function is not in use !!! %%%%%%%%%%
function dynamic_hysteresis(cur_idx, start_thres, cont_thres)
    % Dynamic hysteresis for edge linking
    
    global linked_edge visited_idx walk_flag
    global J_mag J_dir rows cols nr nc
    
    % Check if higher than start_thres
    if J_mag(cur_idx)<start_thres
        return;
    end

    linked_edge = cat(2, linked_edge, cur_idx);
    visited_idx = cat(2, visited_idx, cur_idx);


    walk_flag = true;
    
    while walk_flag
        % Check if visited
        if ~isempty(find(visited_idx==cur_idx, 1))
            return;
        end
        
        visited_idx = cat(2, visited_idx, cur_idx);

        % Predict the next edge point
        tangent_dir = J_dir(cur_idx) - pi/2;
        % Reduce angles to [-pi, pi)
        tangent_dir = mod(tangent_dir, 2*pi);
        if tangent_dir >= pi
            tangent_dir = tangent_dir - 2*pi;
        end

        [pt1, pt2, ~] = interp_helper(tangent_dir);

        % Now we only consider one neighbor
        pt1(1) = pt1(1) * sign(tangent_dir);
        pt2(1) = pt2(1) * sign(tangent_dir);

        pt1_sub = [rows(cur_idx)+pt1(1) cols(cur_idx)+pt1(2)];
        pt2_sub = [rows(cur_idx)+pt2(1) cols(cur_idx)+pt2(2)];

        % Check if the candidate pixels are within boundary
        if ~is_valid(pt1_sub) && ~is_valid(pt2_sub)
            return;
        end

        % If one of the two candidates is invalid
        if ~is_valid(pt1_sub)
            pt1_sub = pt2_sub;
        elseif ~is_valid(pt2_sub)
            pt2_sub = pt1_sub;
        end

        % Convert subscription into index
        pt1_idx = sub2ind([nr nc], pt1_sub(1), pt1_sub(2));
        pt2_idx = sub2ind([nr nc], pt2_sub(1), pt2_sub(2));

        candidate = [pt1_idx pt2_idx];
        [~, ind] = max(J_mag(candidate));
        next_idx = candidate(ind);

        if J_mag(next_idx)>J_mag(cur_idx) && ...
                isempty(find(visited_idx==next_idx, 1))
            cur_idx = next_idx;
        end
        
        
        
        if J_mag(cur_idx)<=cont_thres
            walk_flag = false;
        else  % decrease lower boundary????
            cont_thres = cont_thres * 0.6;
            linked_edge = cat(2, linked_edge, cur_idx);
        end
    
    end   
end


%%
%% Convolution for 1D or 2D kernel
function J  = myConv2(I, G)
% Declaration of J
J = I;

[gnx, gny] = size(G);

% Determine the mode of convolution
% horizontal, vertical, or 2D
if gnx == 1
    mode = 'Gx';
    offset = floor(gny/2);
elseif gny == 1
    mode = 'Gy';
    offset = floor(gnx/2);
elseif gnx > 1 && gny >1
    offset = floor(gnx/2);
    mode = 'Gxy';
end

switch mode

    case 'Gx'
        disp('case Gx!!')
        newI = mirror_pad(I, mode, offset);
        J = conv2(newI, G, 'valid');
        
    case 'Gy'
        disp('case Gy!!')
        newI = mirror_pad(I, mode, offset);
        J = conv2(newI, G, 'valid');
        
    case 'Gxy'
        newI = mirror_pad(I, mode, offset);
        J = conv2(newI, G, 'valid');

end
end

%% Helper function for adding mirror_pad
function newI = mirror_pad(I, mode, offset)
% TODO: deal with even number of rows/cols
switch mode
    case 'Gx'
        left = fliplr( I(:, 1:offset) );
        right = fliplr( I(:, end-offset+1:end) );
        if offset == 1 % difference
            newI = [I, right];
        else
            
            newI = [left, I, right];
        end

    case 'Gy'
        top = flipud( I(1:offset, :) );
        bottom = flipud( I(end-offset+1:end, :) );
        if offset == 1
            newI = [I; bottom];
        else
            newI = [top; I; bottom];
        end

    case 'Gxy'
        left = fliplr( I(:, 1:offset) );
        right = fliplr( I(:, end-offset+1:end) );
        top = flipud( I(1:offset, :) );
        bottom = flipud( I(end-offset+1:end, :) );

        left_upper = rot90(I(1:offset, 1:offset),2);
        right_upper = rot90(I(1:offset, end-offset+1:end),2);
        left_bottom = rot90(I(end-offset+1:end, 1:offset),2);
        right_bottom = rot90(I(end-offset+1:end, end-offset+1:end),2);
        
        if offset ~= 1
            newI = [left, I, right];
            newI = [left_upper top right_upper; newI; ...
                left_bottom bottom right_bottom];
        else
            newI = [I, right];
            newI = [top right_upper;newI;bottom right_bottom];
        end

end
end
