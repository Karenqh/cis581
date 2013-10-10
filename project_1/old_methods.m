%% Old methods for CIS 581 Project 1

local_maxima = [];
for idx = 1:length(indices)
    % If the idx is on the boundary then ignore
    if rows(idx)==1 || rows(idx)==nr || cols(idx)==1 || cols(idx)==nc
        continue;
    end
    
    % If the magnitude of gradient is lower than the start threshold
    % then ignore this pixel
    if J_mag(idx)<global_thres
        continue;
    end
    
    [pt1, pt2, ratio] = intoplate(J_dir(idx));
    
    % Apply interpolation
    % 1st neighbor
    pt1_sub = [rows(idx)+pt1(1) cols(idx)+pt1(2)];
    pt1_idx = sub2ind(size(I), pt1_sub(1), pt1_sub(2));
    
    pt2_sub = [rows(idx)+pt2(1) cols(idx)+pt2(2)];
    pt2_idx = sub2ind(size(I), pt2_sub(1), pt2_sub(2));
    
    neighbor_1 = J_mag(pt1_idx)*ratio + J_mag(pt2_idx)*(1-ratio);
    
    % 2nd neighbor
    pt1_sub = [rows(idx)-pt1(1) cols(idx)-pt1(2)];
    pt1_idx = sub2ind(size(I), pt1_sub(1), pt1_sub(2));
    
    pt2_sub = [rows(idx)-pt2(1) cols(idx)-pt2(2)];
    pt2_idx = sub2ind(size(I), pt2_sub(1), pt2_sub(2));
    
    neighbor_2 = J_mag(pt1_idx)*ratio + J_mag(pt2_idx)*(1-ratio);
    
    if J_mag(idx)>neighbor_1 && J_mag(idx)>neighbor_2
        local_maxima = [local_maxima, idx];
    end

end

% Ignore the pixels right on boundaries
for i = 1:4
    % Four situation
    switch i
        case 1 % (0, pi/4]
            % Pick target pixels
            idx = find( logical(J_dir>0 & J_dir<=pi/4)==1 );
 
            % Helper vectors
            pt1 = [0 1]; pt2 = [1 1]; 

            % Find local maxima given this gradient direction
            edge_idx = find_local_maxima(pt1, pt2, idx);
            local_maxima = [local_maxima; edge_idx];
        case 2 % (pi/4, pi/2]
            % Helper vectors
            pt1 = [1 0]; pt2 = [1 1]; 
            
            % Pick target pixels
            idx = find( logical(J_dir>pi/4 & J_dir<=pi/2)==1 );
            
            % Find local maxima given this gradient direction
            edge_idx = find_local_maxima(pt1, pt2, idx);
            local_maxima = [local_maxima; edge_idx];
        case 3 % (pi/2, .75*pi]
            % Helper vectors
            pt1 = [1 0]; pt2 = [1 -1]; 
            
            % Pick target pixels
            idx = find( logical(J_dir>pi/2 & J_dir<=pi*0.75)==1 );
            
            % Find local maxima given this gradient direction
            edge_idx = find_local_maxima(pt1, pt2, idx);
            local_maxima = [local_maxima; edge_idx];
            
        case 4 % (.75*pi, pi]
            % Helper vectors
            pt1 = [0 -1]; pt2 = [1, -1]; 
            
            % Pick target pixels
            idx = find( logical(J_dir>pi*0.75 & J_dir<=pi)==1 );
            
            % Find local maxima given this gradient direction
            edge_idx = find_local_maxima(pt1, pt2, idx);
            local_maxima = [local_maxima; edge_idx];
    end
end

    % Helper functions for finding local maxima
    function idx = avoid_border(idx)
        tmp_row = rows(idx); tmp_col = cols(idx);
        idx( logical(tmp_row==1 | tmp_row==nr | tmp_col==1 | tmp_col==nc) ) = [];
    end

    function edge_idx = find_local_maxima(pt1, pt2, idx)
        % Pick out the points on boundaries
        idx = avoid_border(idx);
        
        % Parameters for interpolate
        ratio = tan(J_dir(idx));
        
        % 1st neighbor to interpolate
        p1 = [rows(idx)+pt1(1), cols(idx)+pt1(2)];
        p2 = [rows(idx)+pt2(1), cols(idx)+pt2(2)];

        % Convert to indices
        p1_idx = sub2ind(size(I), p1(:,1), p1(:,2));
        p2_idx = sub2ind(size(I), p2(:,1), p2(:,2));

        % Compute magnitude of gradient
        mag1 = J_mag(p1_idx).*ratio + J_mag(p2_idx);
        mag2 = J_mag(p1_idx).*ratio + J_mag(p2_idx);
        mark = logical(J_mag(idx)>=mag1 & J_mag(idx)>=mag2);
        
        edge_idx = idx(mark);
    end
