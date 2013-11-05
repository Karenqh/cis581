function [y x rmax] = anms(cimg, max_pts)

% Frequently used constants
imgsize = size(cimg);
nr = imgsize(1);
nc = imgsize(2);

% Find each pixel's "dominant territory"
r_queue = inf(numel(cimg),1);
r_matrix = inf(imgsize);
for ind=1:numel(cimg)
    % Initialization
    r = 0;
    hit = false;
    % Find the radius for THIS pixel
    while ~hit
        r = r + 1;
        [i j] = ind2sub(imgsize, ind);
        r_min = max(1, i-r);
        r_max = min(nr, i+r);
        c_min = max(1, j-r);
        c_max = min(nc, j+r);
        
        % Encounter the greatest one
        if r_min==1 && r_max==nr && c_min==1 && c_max==nc
            r = inf;
            break;
        end
        
        [row col] = find( cimg(r_min:r_max, c_min:c_max)>cimg(ind) );
        if ~isempty(row)
            hit = true;
            % Euclidean distance ?????
%             r = norm([row col]);
        end
    end
    % Store the results and reset flag
    r_queue(ind) = r;
    r_matrix(ind) = r;
end

% Sort by radius in descending order
% SOMETHING WRONG WITH THIS METHOD
[r_sorted, pos] = sort(r_queue, 'descend');


% Keep the top max_pts points as Corners
% DO WE REALLY NEED TO Check if the RMAX IS UNIQUE????
rmax = r_sorted(max_pts);

r_matrix(r_matrix<rmax) = 0;
r_matrix(r_matrix>0) = 1;
figure(5); imagesc(r_matrix); colormap(gray);


[y x] = ind2sub(imgsize, pos(1:max_pts));
    