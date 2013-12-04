% CIS 581 PROJECT 4: LOGO REPLACEMENT

% Read in test set
close all;
clc;
clear;

listing = dir('SampleSet/SampleSet2/planar*');
img_input = {[]};
for i=1:length(listing)
    imgid = strcat('SampleSet/SampleSet2/', listing(i).name);
    img_input{i} = rgb2gray(imread(imgid));
end



% Scale space extrema
n_octave = 4;
sigma0 = 0.5;
for cnt=4:numel(img_input)
    % Get the local extrema from DoG
    extrema_inds = scale_space_extrema(img_input{cnt}, n_octave, sigma0);
    
    % Interpolation to get exact locations of extremium
    
    % Reject pixels of low contrast
    keypoints_inds = localize_keypoints(img_input{cnt}, extrema_inds);
    
    % Discard pixels along edges
    
    
end