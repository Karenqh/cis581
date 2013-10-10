function J = myImcrop(I)
% Display the image in figure 1
figure(1);
imshow(I);

% Prompts the user to crop out a sub-image
[x, y] = ginput(2);

% Round to get integers
x = floor(x);
y = floor(y);

J = I(y(1):y(2), x(1):x(2), :);

% Displays and returns the sub-image
figure(2);
imshow(J);
end

