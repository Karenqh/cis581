function all_extrema_inds = scale_space_extrema(input_img, n_octave, sigma0)

% FLAG FOR DEBUGGING
debugging = true;
% debugging = false;

% Outputs
extrema_xs = {[]};
extrema_ys = {[]};
all_extrema_inds = {[]};

% cur_level = input_img;  
cur_level = double(input_img); % THIS SEEMES MAKES MORE SENSE

% We just use 5 scales (4 intervels) for each octave
% So scale factor is:
k = 2^(1/4);

for oct=1:n_octave
    if oct>1  % Subsample BLURRED image
        cur_level = cur_level(1:2:size(cur_level,1), 1:2:size(cur_level,2));
        sigma0 = 2*sigma0;
    end
    
    % Get DoG
    dog = {[]};
    for j=1:5
        g = fspecial('gaussian', [9 9], sigma0*k^(j-1));
        cur_level = imfilter(cur_level, g, 'symmetric', 'same');
        if j>1
            dog{j-1}.img = cur_level - pre_level;
            dog{j-1}.scale = sigma0*k^(j-1);
            % Mag and Ori of gradient for Orientation Assignment later
            L_gx = [diff(pre_level,1,2), zeros(size(pre_level,1),1)];
            L_gy = [diff(pre_level,1,1); zeros(1,size(pre_level,2))];
            [dog{j-1}.g_dir, dog{j-1}.g_mag] = cart2pol(L_gx, L_gy);
            %%%%%%%% TODO: IS THIS CORRECT???
            % Need to blur with a Gaussian of sigma = 1.5*scale
            g_filter = fspecial('gaussian',[7 7], 1.5*sigma0*k^(j-1));
            dog{j-1}.g_mag = imfilter(dog{j-1}.g_mag,g_filter,'symmetric','same');
            dog{j-1}.oct = oct;
        end
        pre_level = cur_level;
    end
    
    
    % Locate local extrema
    nr = size(dog{1}.img,1);
    nc = size(dog{1}.img,2);
    [cols_all, rows_all] = meshgrid(1:nc, 1:nr);
       
    % Candidate pixels
    [cols, rows] = meshgrid(2:nc-1, 2:nr-1);
    inds = sub2ind([nr nc], rows(:), cols(:));
       
    %%%%%%%% We only check dog{2} and dog{3}
    
    % dog{2}
    lower_dog = dog{1}.img;
    cur_dog   = dog{2}.img;
    upper_dog = dog{3}.img;
    % First grab all the candidates
    cols_remain = cols;
    rows_remain = rows;
    inds_remain = inds;
    for dx=-1:1
        for dy=-1:1
            if isempty(inds_remain)
                break;
            end
            
            new_cols = cols_remain+dx;
            new_rows = rows_remain+dy;
            new_inds = sub2ind([nr nc], new_rows(:), new_cols(:));

            inds_maxima = inds_remain(cur_dog(inds_remain)>=cur_dog(new_inds)&...
                               cur_dog(inds_remain)>lower_dog(new_inds)&...
                               cur_dog(inds_remain)>upper_dog(new_inds));
            
            inds_minima = inds_remain(cur_dog(inds_remain)<cur_dog(new_inds)&...
                               cur_dog(inds_remain)<lower_dog(new_inds)&...
                               cur_dog(inds_remain)<upper_dog(new_inds));
            
            inds_remain = unique([inds_maxima;inds_minima]);   
            cols_remain = cols_all(inds_remain);
            rows_remain = rows_all(inds_remain);

        end
    end
    
    % Get subpixel keypoints
%     [xs ys sigmas] = subpixel_extrema(lower_dog, cur_dog, upper_dog, inds_remain);

    %-------- Reject Unrobust Points -------
    keypoints_inds = localize_keypoints(cur_dog, inds_remain);
    
    %-------- Assign Orientation -------
    KeyPoints = assign_orientation(dog{2}, keypoints_inds);
    
    
    %  dog{3}
    lower_dog = dog{2}.img;
    cur_dog   = dog{3}.img;
    upper_dog = dog{4}.img;
    % First grab all the candidates
    cols_remain = cols;
    rows_remain = rows;
    inds_remain = inds;
    for dx=-1:1
        for dy=-1:1
            
            if isempty(inds_remain)
                break;
            end
            
            new_cols = cols_remain+dx;
            new_rows = rows_remain+dy;
            new_inds = sub2ind([nr nc], new_rows(:), new_cols(:));

            inds_maxima = inds_remain(cur_dog(inds_remain)>=cur_dog(new_inds)&...
                               cur_dog(inds_remain)>lower_dog(new_inds)&...
                               cur_dog(inds_remain)>upper_dog(new_inds));
                           
            inds_minima = inds_remain(cur_dog(inds_remain)<cur_dog(new_inds)&...
                               cur_dog(inds_remain)<lower_dog(new_inds)&...
                               cur_dog(inds_remain)<upper_dog(new_inds));
            
            inds_remain = unique([inds_maxima;inds_minima]);   
            cols_remain = cols_all(inds_remain);
            rows_remain = rows_all(inds_remain);

        end
    end
    %%%%%%%???????? store them separately??    
    keypoints_inds_2 = localize_keypoints(cur_dog, inds_remain);
    
    KeyPoints = assign_orientation(dog{2}, keypoints_inds_2, KeyPoints);

    
    keypoints_inds = cat(1,keypoints_inds, keypoints_inds_2);

    
    % Obtaion extrema locations
    keypoints_inds = unique(keypoints_inds);
    all_extrema_inds{oct} = keypoints_inds;
    [extrema_ys{oct} extrema_xs{oct}] = ind2sub([nr nc], keypoints_inds);
   
    % DEBUGGING
    if debugging 
        if oct == 1
            close all;
        end
        figure(oct)
        imagesc(cur_level);
        colormap(gray);
        hold on;
        plot(extrema_xs{oct}, extrema_ys{oct},'.');
        hold off;
    end
end
