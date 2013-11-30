function [extrema_xs, extrema_ys] = scale_space_extrema(input_img, n_octave, sigma1)

extrema_xs = {[]};
extrema_ys = {[]};
cur_level = input_img;

for i=1:n_octave
    if i>1  % Sub-sample BLURRED image
        cur_level = cur_level(1:2:size(cur_level,1), 1:2:size(cur_level,2));
    end
    
    % Get DoG
    dog = {[]};
    for j=1:5
        k = max(1, j-1);
        g = fspecial('gaussian', [5 5], sigma1*k*sqrt(2));
        cur_level = imfilter(cur_level, g, 'symmetric', 'same');
        if j>1
            dog{j-1} = pre_level - cur_level;
        end
        pre_level = cur_level;
    end
    
    
    % Locate local extrema
    nr = size(dog{1},1);
    nc = size(dog{1},2);
    [cols_all, rows_all] = meshgrid(1:nc, 1:nr);
       
    % Candidate pixels
    [cols, rows] = meshgrid(2:nc-1, 2:nr-1);
    inds = sub2ind([nr nc], rows(:), cols(:));
       
    %%%%%%%% We only checkt dog{2} and dog{3}
    
    % dog{2}
    lower_layer = dog{1};
    cur_layer   = dog{2};
    upper_layer = dog{3};
    % First compare in current level
    cols_remain = cols;
    rows_remain = rows;
    inds_remain = inds;
    for dx=-1:1
        for dy=-1:1
            new_cols = cols_remain+dx;
            new_rows = rows_remain+dy;
            new_inds = sub2ind([nr nc], new_rows(:), new_cols(:));

            inds_maxima = inds_remain(cur_layer(inds_remain)>=cur_layer(new_inds)&...
                               cur_layer(inds_remain)>lower_layer(new_inds)&...
                               cur_layer(inds_remain)>upper_layer(new_inds));
            
            inds_minima = inds_remain(cur_layer(inds_remain)<cur_layer(new_inds)&...
                               cur_layer(inds_remain)<lower_layer(new_inds)&...
                               cur_layer(inds_remain)<upper_layer(new_inds));
            
            inds_remain = unique([inds_maxima;inds_minima]);   
            cols_remain = cols_all(inds_remain);
            rows_remain = rows_all(inds_remain);

        end
    end
    extrema_inds = inds_remain;
    
    % Get subpixel keypoints
    
    %  dog{3}
    lower_layer = dog{2};
    cur_layer   = dog{3};
    upper_layer = dog{4};
    % First compare in current level
    cols_remain = cols;
    rows_remain = rows;
    inds_remain = inds;
    for dx=-1:1
        for dy=-1:1
            new_cols = cols_remain+dx;
            new_rows = rows_remain+dy;
            new_inds = sub2ind([nr nc], new_rows(:), new_cols(:));

            inds_maxima = inds_remain(cur_layer(inds_remain)>=cur_layer(new_inds)&...
                               cur_layer(inds_remain)>lower_layer(new_inds)&...
                               cur_layer(inds_remain)>upper_layer(new_inds));
                           
            inds_minima = inds_remain(cur_layer(inds_remain)<cur_layer(new_inds)&...
                               cur_layer(inds_remain)<lower_layer(new_inds)&...
                               cur_layer(inds_remain)<upper_layer(new_inds));
            
            inds_remain = unique([inds_maxima;inds_minima]);   
            cols_remain = cols_all(inds_remain);
            rows_remain = rows_all(inds_remain);

        end
    end
    %%%%%%%???????? store them separately??
    extrema_inds = [extrema_inds;inds_remain];
    
    % Obtaion extrema locations
    extrema_inds = unique(extrema_inds);
    [extrema_ys{i} extrema_xs{i}] = ind2sub([nr nc], extrema_inds);
   
end
