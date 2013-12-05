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
n_octave = 4;   % AS MANY AS POSSIBLE
sigma0 = 0.5;
for cnt=4:numel(img_input)
    % Extract Keypoints with Location, Orientation, Scale
    extrema_inds = extract_keypoints(img_input{cnt}, n_octave, sigma0);
    
    % Interpolation to get exact locations of extremium
        
    % Discard pixels along edges
    
    
end