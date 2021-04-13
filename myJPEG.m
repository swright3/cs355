image = imread('lena512gray.pgm');
figure, imagesc(image);
title('Original image');
colormap('gray');

imcoefs = dct2(image);
figure, imagesc(log(abs(imcoefs)));
colormap(jet);
title('Original image coefficients');

compressedImcoefs = imcoefs;
zeros = 0;
for i = 2:length(imcoefs)
    compressedImcoefs(i,length(compressedImcoefs)-i+2:length(compressedImcoefs)) = imcoefs(i,length(compressedImcoefs)-i+2:length(compressedImcoefs))*0;
    zeros = zeros + (i-1);
end
figure, imagesc(log(abs(compressedImcoefs)));
colormap(jet);
title('Compressed image coefficients');

compressionRatio = (512^2-zeros)/512^2;
disp('Compression ratio = ');
disp(compressionRatio);

compressedImage = idct2(compressedImcoefs);
compressedImage = uint8(compressedImage);
figure, imagesc(compressedImage);
title('Compressed image');
colormap('gray');

ssimval = ssim(compressedImage, image);
disp('SSIM = ');
disp(ssimval);
mse = immse(compressedImage, image);
disp('MSE = ');
disp(mse);

zeros = 0;
for x = 1:length(imcoefs)/8
    for y = 1:length(imcoefs)/8
        imageBlock = image(1+((y-1)*8):8+((y-1)*8),1+((x-1)*8):8+((x-1)*8));
        blockCoefs = dct2(imageBlock);
        compressedBlock = blockCoefs;
        for i = 2:length(compressedBlock)
            compressedBlock(i,length(compressedBlock)-i+2:length(compressedBlock)) = imcoefs(i,length(compressedBlock)-i+2:length(compressedBlock))*0;
            zeros = zeros + (i-1);
        end
        compressedImcoefs2(1+((y-1)*8):8+((y-1)*8),1+((x-1)*8):8+((x-1)*8)) = compressedBlock;
        compressedImage2(1+((y-1)*8):8+((y-1)*8),1+((x-1)*8):8+((x-1)*8)) = idct2(compressedBlock);
    end
end

disp('Compression ratio 2 = ');
compressionRatio2 = (512^2-zeros)/512^2;
disp(compressionRatio2);

compressedImage2 = uint8(compressedImage2);
figure, imagesc(compressedImage2);
title('Compressed image 2');
colormap('gray');

ssimval2 = ssim(compressedImage2, image);
disp('SSIM 2 = ');
disp(ssimval2);
mse2 = immse(compressedImage2, image);
disp('MSE 2 = ');
disp(mse2);

zeros1 = 0;
zeros2 = 0;
for x = 1:length(imcoefs)/8
    for y = 1:length(imcoefs)/8
        imageBlock = image(1+((y-1)*8):8+((y-1)*8),1+((x-1)*8):8+((x-1)*8));
        blockCoefs = dct2(imageBlock);
        compressedBlock1 = round(blockCoefs./Q50);
        compressedBlock2 = round(blockCoefs./Q90);
        compressedImcoefs3(1+((y-1)*8):8+((y-1)*8),1+((x-1)*8):8+((x-1)*8)) = compressedBlock1;
        compressedImage3(1+((y-1)*8):8+((y-1)*8),1+((x-1)*8):8+((x-1)*8)) = idct2(compressedBlock1);
        compressedImcoefs4(1+((y-1)*8):8+((y-1)*8),1+((x-1)*8):8+((x-1)*8)) = compressedBlock2;
        compressedImage4(1+((y-1)*8):8+((y-1)*8),1+((x-1)*8):8+((x-1)*8)) = idct2(compressedBlock2);
    end
end

for y = 1:length(imcoefs)
    for x = 1:length(imcoefs)
        if compressedImcoefs3(y,x) == 0
            zeros1 = zeros1 + 1;
        end
        if compressedImcoefs4(y,x) == 0
            zeros2 = zeros2 + 1;
        end
    end
end

compressedImage3 = uint8(compressedImage3);
figure, imagesc(compressedImage3);
title('Compressed image 3');
colormap('gray');

disp('Compression ratio 3 = ');
compressionRatio3 = (512^2-zeros1)/512^2;
disp(compressionRatio3);

ssimval3 = ssim(compressedImage3, image);
disp('SSIM 3 = ');
disp(ssimval3);
mse3 = immse(compressedImage3, image);
disp('MSE 3 = ');
disp(mse3);

disp('Compression ratio 4 = ');
compressionRatio4 = (512^2-zeros2)/512^2;
disp(compressionRatio4);

compressedImage4 = uint8(compressedImage4);
figure, imagesc(compressedImage4);
title('Compressed image 4');
colormap('gray');

ssimval4 = ssim(compressedImage4, image);
disp('SSIM 4 = ');
disp(ssimval4);
mse4 = immse(compressedImage4, image);
disp('MSE 4 = ');
disp(mse4);
    