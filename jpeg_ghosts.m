diffImages = jpeg_ghosts2('splicedbeach.jpg',8,1,100,1);
figure, imagesc(diffImages{70});
colormap('gray');
% figure, subplot(10,10,1);
% for image = 1:100
%     subplot(10,10,image);
%     diffImage = diffImages{image};
%     imagesc(diffImage);
%     colormap('gray');
% end
    
function diffImages = jpeg_ghosts2(file, b, minQ, maxQ, stepQ)
diffImages = {};
image = imread(file);
disp(size(image));
rows = height(image);
columns = width(image);
for Q = minQ:stepQ:maxQ
    imwrite(image,'compressedImage.jpg','jpg','Quality',Q);
    compressedImage = imread('compressedImage.jpg');
    block = 0;
    for y = 1:rows-b
        for x = 1:columns-b
            block = block+1;
            imageBlock = image(y:y+b-1,x:x+b-1,:);
            compressedBlock = compressedImage(y:y+b-1,x:x+b-1,:);
            diffBlock = zeros(b,b,'uint8');
            diffAverage = 0;
            %SSD = 0;
            for i = 1:3
                diffBlock = diffBlock + ((imageBlock(:,:,i)-compressedBlock(:,:,i)).^2);
                diffAverage = diffAverage + (sum(diffBlock,'all')/(b^2));
                %SSD = SSD + sum(((imageBlock(:,:,i)-compressedBlock(:,:,i)).^2),'all');
            end
            diffAverage = diffAverage/3;
            %SSD = sum(diffBlock,'all');
            diffImage(y,x) = diffAverage;
        end
    end
    diffImages{Q} = diffImage;
end
end
