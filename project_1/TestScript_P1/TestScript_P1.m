%%CIS 581 Project 1 Test Script - Fall 2013
% This script passes input similar to what will be tested to the functions
% and tests that the output is in the correct format.
% This is not a test of correctness of the operations themselves

pass = true;

I = uint8(zeros([10,10,3]));
I(3,3,1:3) = 255;
I(7,7,1:3) = 255;

%Click on the two white squares
J = myImcrop(I);
if(numel(size(J)) ~=3)
    fprintf('Image returned not RGB\n');
    pass = false;
end

if pass,
    fprintf('Problem 1 passed.\n');
end

%%
clc;
close all;
clear;

test_files = dir('./TestScript_P1/train_images_P1/*.jpg');

numfiles = length(test_files);
img = cell(1, numfiles);

for k = 1:numfiles 
  img{k} = imread(test_files(k).name); 
end

I = img{8};
E = cannyEdge(I);

pass = true;

if ndims(E) ~= 2,
    fprintf('incorrect edge map size\n');
    pass = false;
end

szI = size(I);
szE = size(E);
if(szI(1) ~= szE(1) || szI(2) ~= szE(2))
    fprintf('Edge map not the same size as the input image\n');
    pass = false;
end

if ~isa(E,'logical')
    fprintf('Edge map is not logical\n');
    pass = false;
end


bw = edge(rgb2gray(I), 'canny');
% bw = zeros(size(I));
figure(2), imshow(I);
figure(1), subplot(1,2,1), imshow(bw); subplot(1,2,2), imshow(E);


if pass
    fprintf('Tests Passed\n');
end



