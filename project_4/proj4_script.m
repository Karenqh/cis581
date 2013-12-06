% CIS 581 PROJECT 4: LOGO REPLACEMENT

% Read in test set
close all;
clc;
clear;

% listing = dir('SampleSet/SampleSet2/planar*');
listing = dir('SampleSet/SampleSet2/Reference*');

img_input = {[]};
for i=1:length(listing)
    imgid = strcat('SampleSet/SampleSet2/', listing(i).name);
    img_input{i} = rgb2gray(imread(imgid));
end


% First round smoothing
smoother = fspecial('gaussian', [5 5], 0.5);
% Scale space extrema
sigma0 = 1.6;
for cnt=1:numel(img_input)
    % Pre-smooth input image
    input_img = imfilter(img_input{cnt}, smoother,'symmetric','same');
    
    % Determine number of octaves
    [nr nc] = size(input_img);
    n_octave = round( log2(min(nr, nc)) );
    disp(n_octave)
    
    % Extract Keypoints with Location, Orientation, Scale
    KeyPoints = extract_keypoints(input_img, n_octave, sigma0);
    
    % Greate descriptors
    blah = feature_descriptor(double(img_input{cnt}), KeyPoints);
    
    % Match keypoints
    
end