file = 'kimono1_1920x1080_150_10bit_420.raw';
fid = fopen(file,'r');
data = fread(fid,'uint16');
Ysize = 2073600
Cbsize = 518400;
Crsize = 518400;
Y = data(1:Ysize);
Cb = data(Ysize+1:Ysize+Cbsize);
Cr = data(Ysize+Cbsize+1:3110400);
Y = reshape(Y,1080,[]);
Cb = reshape(Cb,540,[]);
Cr = reshape(Cr,540,[]);
figure, subplot(1,3,1);
imshow(Y,[]); title('Y'); 
subplot(1,3,2);
imshow(Cb,[]); title('Cb');
subplot(1,3,3); 
imshow(Cr,[]); title('Cr');
Y2 = Y';
for x = 1:960
    for y = 1:540
        Yx1y1 = Y2(1+((x-1)*2),1+((y-1)*2));
        Yx2y1 = Y2(2+((x-1)*2),1+((y-1)*2));
        Yx1y2 = Y2(1+((x-1)*2),2+((y-1)*2));
        Yx2y2 = Y2(2+((x-1)*2),2+((y-1)*2));
        YA(x,y) = floor((Yx1y1+Yx1y2+Yx2y1+Yx2y2)/4);  
        YB(x,y) = floor((Yx1y1+Yx1y2)/2);
        YC(x,y) = floor((Yx2y1+Yx2y2)/2);
        YD(x,y) = Yx1y1;
    end
end
YA = YA';
YB = YB';
YC = YC';
YD = YD';
YA = YA(1:540,1:960);
YB = YB(1:540,1:960);
YC = YC(1:540,1:960);
YD = YD(1:540,1:960);
figure, imshow(Y,[]);
figure, imshow(YA,[]);
figure, imshow(YB,[]);
figure, imshow(YC,[]);
figure, imshow(YD,[]);
Cbvector = reshape(Cb,1,[]);
YAvector = reshape(YA,1,[]);
YBvector = reshape(YB,1,[]);
YCvector = reshape(YC,1,[]);
YDvector = reshape(YD,1,[]);
varCb = var(Cbvector);
varYA = var(YAvector);
varYB = var(YBvector);
varYC = var(YCvector);
varYD = var(YDvector);
covYA = cov(Cbvector,YAvector);
covYB = cov(Cbvector,YBvector);
covYC = cov(Cbvector,YCvector);
covYD = cov(Cbvector,YDvector);
rA = (covYA/sqrt(varCb*varYA))^2;
rB = (covYB/sqrt(varCb*varYB))^2;
rC = (covYC/sqrt(varCb*varYC))^2;
rD = (covYD/sqrt(varCb*varYD))^2;
rA = 0;
rB = 0;
rC = 0;
rD = 0;
meanCb = mean(Cbvector)
meanYA = mean(YAvector)
meanYB = mean(YBvector)
meanYC = mean(YCvector)
meanYD = mean(YDvector)
for i=1:518400
    rA = rA + ((Cbvector(i)-meanCb)*(YAvector(i) - meanYA));
    rB = rB + ((Cbvector(i)-meanCb)*(YBvector(i) - meanYB));
    rC = rC + ((Cbvector(i)-meanCb)*(YCvector(i) - meanYC));
    rD = rD + ((Cbvector(i)-meanCb)*(YDvector(i) - meanYD));
end
rA = (rA/518400)^2;
rB = (rB/518400)^2;
rC = (rC/518400)^2;
rD = (rD/518400)^2;