function KeyPoints = extract_keypoints(input_img, n_octave, sigma0)

% FLAG FOR DEBUGGING
debugging = true;
% debugging = false;

%---------------------------------------------------------------

pre_level = double(input_img); 

% 6 GSS -> 5 Dog -> 3 Extrema(level)
% So scale factor is:
k = 2^(1/3);
dot_color = {'b.','g.','y.','r.','c.'};
line_color = {'b','g','y','r','c'};


figure(1);
imagesc(pre_level);
colormap(gray);


KeyPoints = {};
for oct=1:n_octave
    if oct>1  % Subsample BLURRED image
        pre_level = pre_level(2:2:size(pre_level,1), 2:2:size(pre_level,2));
%         sigma0 = 2*sigma0;
    end
    
    % Get DoG
    dog = {[]};
    for j=0:5
        sigma_now = sigma0*k^(j-1+oct-1);
        g = fspecial('gaussian', [9 9], sigma_now);
        cur_level = imfilter(pre_level, g, 'symmetric', 'same');
        
        if j>0
            dog{j}.img = cur_level - pre_level;
            dog{j}.scale = sigma_now/k;
            % Mag and Ori of gradient for Orientation Assignment later
            L_gx = [diff(pre_level,1,2), zeros(size(pre_level,1),1)];
            L_gy = [diff(pre_level,1,1); zeros(1,size(pre_level,2))];
            [dog{j}.g_dir, dog{j}.g_mag] = cart2pol(L_gx, L_gy);

    %             %%%%%%%% TODO: IS THIS CORRECT???
    %             % Need to blur with a Gaussian of sigma = 1.5*scale
    %             g_filter = fspecial('gaussian',[7 7], 1.5*sigma_now);
    %             dog{j-1}.g_mag = imfilter(dog{j-1}.g_mag,g_filter,'symmetric','same');

            dog{j}.oct = oct;
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
       
    
    % Check dog{2~4} for extrema
    for idx = 2:4
        lower_dog = dog{idx-1}.img;
        cur_dog   = dog{idx}.img;
        upper_dog = dog{idx+1}.img;
        % First grab all the candidates
        cols_remain = cols;
        rows_remain = rows;
        inds_remain = inds;
        
        % TODO: USE meshgrid to speed up
        for dx=-1:1
            for dy=-1:1
                if isempty(inds_remain)
                    break;
                end

                new_cols = cols_remain+dx;
                new_rows = rows_remain+dy;
                new_inds = sub2ind([nr nc], new_rows(:), new_cols(:));

                if dx==0 && dy==0
                    % compare to itself on cur_dog
                    inds_maxima = inds_remain(cur_dog(inds_remain)>lower_dog(new_inds)&...
                                        cur_dog(inds_remain)>upper_dog(new_inds));
                    inds_minima = inds_remain(cur_dog(inds_remain)<lower_dog(new_inds)&...
                        cur_dog(inds_remain)<upper_dog(new_inds));
                   
                else
                    inds_maxima = inds_remain(cur_dog(inds_remain)>cur_dog(new_inds)&...
                                       cur_dog(inds_remain)>lower_dog(new_inds)&...
                                       cur_dog(inds_remain)>upper_dog(new_inds));

                    inds_minima = inds_remain(cur_dog(inds_remain)<cur_dog(new_inds)&...
                                       cur_dog(inds_remain)<lower_dog(new_inds)&...
                                       cur_dog(inds_remain)<upper_dog(new_inds));
                end
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
        KeyPoints = assign_orientation(dog{idx}, keypoints_inds, KeyPoints);

        % DEBUGGING
        if debugging            
            figure(1);
            
            hold on;
            cnt = numel(KeyPoints);
            plot(KeyPoints{cnt}.location(:,1), KeyPoints{cnt}.location(:,2),dot_color{mod(cnt,5)+1});

            % Plot the arrows indicating orientations
            [u v] = pol2cart(KeyPoints{cnt}.orientation, KeyPoints{cnt}.scale);
            disp('scale');
            disp(KeyPoints{cnt}.scale);
            quiver(KeyPoints{cnt}.location(:,1), KeyPoints{cnt}.location(:,2), u, v, line_color{mod(cnt,5)+1});
            hold off;
        end

    end

end
