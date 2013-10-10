function [ im1_pts, im2_pts] = click_correspondences(im1,im2)
cpselect(im1, im2, cpstruct);