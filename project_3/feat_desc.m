function p = feat_desc(im, y, x)

% 40x40 window around the corner 
% Downsize to 8x8 (blur and then sample every 5th
% pixel, see image pyramid lecture) 
% Normalize 8x8 patch to mean 0 and standard deviation of 1 

% As a bonus, you can implement the Geometric Blur features

%% Frequently used constants
imgsize = size(im);
nr = imgsize(1);
nc = imgsize(2);

%% Gaussian pre-filtering
h = fspecial('gaussian', [5 5], 2);
im = imfilter(im, h, 'symmetric', 'same');

%% Create 40-by-40 window and sub-sample
% Get the inds of corners
inds = sub2ind(size(im), y, x);

% Get matrices of subs and locate corners
[cols, rows] = meshgrid(1:size(im,2), 1:size(im,1));
corner_cols = cols(inds);  % n-by-1
corner_rows = rows(inds);

% JUST GET THE INDS AND STORE THEM (LINEARIZED)

rows_list = zeros(64,length(y));
cols_list = zeros(64,length(y));
count = 0;
for i = -15:5:20
    for j = -15:5:20
        count = count + 1;
        rows_tmp = corner_rows + i;  % n-by-1
        cols_tmp = corner_cols + j;
        
        % MAY JUST THROW OUT THE PIXELS TOO CLOSE TO BOUNDRY
        
        % Deal with points outside boundaries
        rows_tmp(rows_tmp<1) = 1 - rows_tmp(rows_tmp<1);
        rows_tmp(rows_tmp>nr) = 2*nr+1 - rows_tmp(rows_tmp>nr);
        
        cols_tmp(cols_tmp<1) = 1 - cols_tmp(cols_tmp<1);
        cols_tmp(cols_tmp>nc) = 2*nc+1 - cols_tmp(cols_tmp>nc);
 
        % Store the subs
        rows_list(count,:) = rows_tmp';
        cols_list(count,:) = cols_tmp';
    end
end

% Get the descripters
p = [];
for cnt = 1:length(y)
    indices = sub2ind(imgsize, rows_list(:,cnt), cols_list(:,cnt));
    % Normalization: 0-mean, 1-std
    vals = double( im(indices) );
    vals = vals - mean(vals);
    vals = vals/std(vals);
    
    %%%%%%% Check if normalized %%%%%%%%%%%%%
    if mean(vals) > 1e-10
        disp('MEAN of descripters is not ZERO');
        return;
    end
    if std(vals)-1 > 1e-10
        disp('STD of descripters is not ONE');
        return;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    p = cat(2, p, vals);
end




% % AN OLD ATTEMPT
% p = [];
% for cnt = 1:length(y)
%     % MIRROR PAD TO KEEP POINTS???
%     if corner_rows(cnt)<20 || corner_rows(cnt)>(nr-20) ...
%             || corner_cols(cnt)<20 || corner_cols(cnt)>(nc-20)
%         if corner_rows(cnt)<10 || corner_rows(cnt)>(nr-10) ...
%             || corner_cols(cnt)<10 || corner_cols(cnt)>(nc-10)
%             % Discard points too close to boundary ???
%             break;
%         else
%             % window size use 20*20
%             break;   % FOR NOW
%         end
%     end
%     
%     % get a list of 40*40 pixels
%     subs_row = (corner_rows(cnt)-19:corner_rows(cnt)+20)';
%     subs_col = (corner_cols(cnt)-19:corner_cols(cnt)+20)';
%     idxs = sub2ind(imgsize, subs_row, subs_col);
% end
%     





