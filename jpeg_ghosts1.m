%diffImages = jpeg_ghosts2('splicedbeach.jpg',8,11,91,10);
%save('diffImages.mat','diffImages');
diffImages = load('diffImages.mat').diffImages;
colormap('gray');
figure, subplot(3,3,1);
sp = 1;
for image = 11:10:91
    subplot(3,3,sp);
    diffImage = diffImages{image};
    imagesc(diffImage);
    colormap('gray');
    sp = sp + 1;
end
    
function diffImages = jpeg_ghosts2(file, b, minQ, maxQ, stepQ)
diffImages = {};
image = imread(file);
disp(size(image));
rows = height(image);
columns = width(image);
for Q = minQ:stepQ:maxQ
    imwrite(image,'compressedImage.jpg','jpg','Quality',Q);
    compressedImage = imread('compressedImage.jpg');
    diffImageBeforeAvg = (image-compressedImage).^2;
    for y = 1:rows-b
        for x = 1:columns-b
            diffBlock = diffImageBeforeAvg(y:y+b-1,x:x+b-1,:);
            diffAverage = 0;
            for i = 1:3
                diffAverage = diffAverage + (sum(diffBlock(:,:,i),'all')/(b^2));
            end
            diffAverage = diffAverage/3;
            diffImage(y,x) = diffAverage;
        end
    end
    minimum = min(diffImage, [], 'all');
    diffMinusMin = diffImage - minimum;
    diffImage = diffMinusMin./max(diffMinusMin, [], 'all');
    diffImages{Q} = diffImage;
end
end

%spliced beach is spliced, q = 70
%spliced boat is spliced, q = 86
%spliced plane might be spliced, q = 1
%spliced soldier might be spliced, q = 85 but its a light area not a dark
%area