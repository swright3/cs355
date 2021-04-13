I = imread('lena512color.tiff')
figure, subplot(1,4,1);
imshow(I); 
colormap('gray'); 
subplot(1,4,2);
imshow(I(:,:,1),[]); title('red');
subplot(1,4,3); 
imshow(I(:,:,2),[]); title('green');
subplot(1,4,4); 
imshow(I(:,:,3),[]); title('blue');

M = [0.2990,0.5870,0.1140;-0.1687,-0.3313,0.5000;0.5000,-0.4187,0.0813];
N = [0;128;128];
V = reshape(double(I),[],3);
V2 = V';
V3 = M*V2;
V4 = V3'
V5 = reshape(uint8(V4),512,512,3)
figure, colormap('gray'); 
subplot(1,3,1);
imshow(V5(:,:,1),[]); title('Y');
subplot(1,3,2); 
imshow(V5(:,:,2),[]); title('Cb');
subplot(1,3,3); 
imshow(V5(:,:,3),[]); title('Cr');