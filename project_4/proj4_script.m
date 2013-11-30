%% CIS 581 PROJECT 4: LOGO REPLACEMENT

%% Read in test set
listing = dir('SampleSet/SampleSet2/planar*');
img_input = {[]};
for i=1:length(listing)
    imgid = strcat('SampleSet/SampleSet2/', listing(i).name);
    img_input{i} = rgb2gray(imread(imgid));
end



%% Scale space
