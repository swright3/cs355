image = imread('jeep.png');
se = strel('disk',4,0);
A = circMatcher(image,se,155);
figure, imagesc(A);
colormap('gray');
title('A_155_disk4_0');
A = circMatcher(image,se,160);
figure, imagesc(A);
colormap('gray');
title('A_160_disk4_0');
A = circMatcher(image,se,165);
figure, imagesc(A);
colormap('gray');
title('A_165_disk4_0');

function S = imCshift(X,k,l)
S = zeros([height(X),width(X)],'uint8');
for y = 1:height(X)
    for x = 1:width(X)
        newX = mod(x+k,width(X));
        newY = mod(y+l,height(X));
        if newX == 0
            newX = width(X);
        end
        if newY == 0
            newY = height(X);
        end
        S(newY,newX) = X(y,x);
    end
end
% figure, imagesc(X);
% colormap('gray');
% figure, imagesc(S);
% colormap('gray');
end

function d = simThresh(x,s,t)
d = abs(x-s);
d(d<t) = 0;
d(d>=t) = 1;
end

function A = circMatcher(image,se,threshold)
image = rgb2gray(image);
A = zeros([height(image),width(image)]);
for k = 1:width(image)/2
    for l = 1:height(image)/2
        shiftedImage = imCshift(image,k,l);
        differenceImage = simThresh(image,shiftedImage,threshold);
        eroded = imerode(differenceImage,se);
        dilated = imdilate(eroded,se);
        A = A | dilated;
    end
end
end

%threshold of 160 gives a binary image with only one group of obviously
%edited pixels, no stray 0s
