load durer;
I = X;
Z = -I;
%figure; colormap('gray');
%imagesc(Z);
Y = X; Y(410:530,80:160) = Y(410:530,80:160)-50; X = Y;
figure, imshow(Y,[])
