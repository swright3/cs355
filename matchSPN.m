jpgFiles = dir('SKY\Agfa_CD_504_0\*.jpg');
numFiles = length(jpgFiles);
for k = 1:numFiles
    rgbImage = imread(strcat('SKY\Agfa_CD_504_0\',jpgFiles(k).name));
    image = rgb2gray(rgbImage);
    images{k} = image;
end
spn = computeSPN(images);
save('Agfa_CD_504_0_spn.mat','spn');

jpgFiles = dir('SKY\Agfa_DC_830i_0\*.jpg');
numFiles = length(jpgFiles);
for k = 1:numFiles
    rgbImage = imread(strcat('SKY\Agfa_DC_830i_0\',jpgFiles(k).name));
    image = rgb2gray(rgbImage);
    images{k} = image;
end
spn = computeSPN(images);
save('Agfa_DC_830i_0_spn.mat','spn');

jpgFiles = dir('SKY\Agfa_Sensor505-x_0\*.jpg');
numFiles = length(jpgFiles);
for k = 1:numFiles
    rgbImage = imread(strcat('SKY\Agfa_Sensor505-x_0\',jpgFiles(k).name));
    image = rgb2gray(rgbImage);
    images{k} = image;
end
spn = computeSPN(images);
save('Agfa_Sensor505-x_0_spn.mat','spn');

jpgFiles = dir('SKY\Agfa_Sensor530s_0\*.jpg');
numFiles = length(jpgFiles);
for k = 1:numFiles
    rgbImage = imread(strcat('SKY\Agfa_Sensor530s_0\',jpgFiles(k).name));
    image = rgb2gray(rgbImage);
    images{k} = image;
end
spn = computeSPN(images);
save('Agfa_Sensor530s_0_spn.mat','spn');

jpgFiles = dir('SKY\Canon_Ixus_55_0\*.jpg');
numFiles = length(jpgFiles);
for k = 1:numFiles
    rgbImage = imread(strcat('SKY\Canon_Ixus_55_0\',jpgFiles(k).name));
    image = rgb2gray(rgbImage);
    images{k} = image;
end
spn = computeSPN(images);
save('Canon_Ixus_55_0_spn.mat','spn');

jpgFiles = dir('SKY\Canon_Ixus70_0\*.jpg');
numFiles = length(jpgFiles);
for k = 1:numFiles
    rgbImage = imread(strcat('SKY\Canon_Ixus70_0\',jpgFiles(k).name));
    image = rgb2gray(rgbImage);
    images{k} = image;
end
spn = computeSPN(images);
save('Canon_Ixus70_0_spn.mat','spn');

spn1 = load('Agfa_CD_504_0_spn.mat').spn;
spn2 = load('Agfa_DC_830i_0_spn.mat').spn;
spn3 = load('Agfa_Sensor505-x_0_spn.mat').spn;
spn4 = load('Agfa_Sensor530s_0_spn.mat').spn;
spn5 = load('Canon_Ixus_55_0_spn.mat').spn;
spn6 = load('Canon_Ixus70_0_spn.mat').spn;
spn1 = meanCenter(spn1); %AFGA_CD_504
spn2 = meanCenter(spn2); %AFGA_DC_830i
spn3 = meanCenter(spn3); %AFGA_Sensor505
spn4 = meanCenter(spn4); %AFGA_Sensor530s
spn5 = meanCenter(spn5); %Canon_Ixus70
spn6 = meanCenter(spn6); %Canon_Ixus_55
% figure, imagesc(spn);
% colormap('gray');

jpgFiles = dir('TestRand\*.jpg');
numFiles = length(jpgFiles);
for k = 1:numFiles
    rgbImage = imread(strcat('TestRand\',jpgFiles(k).name));
    image = rgb2gray(rgbImage);
    images{k,1} = image;
    images{k,2} = jpgFiles(k).name;
end
cam1 = [];
cam2 = [];
cam3 = [];
cam4 = [];
cam5 = [];
cam6 = [];

for i = 1:length(images)
    spn = computeSPN2(images{i,1});
    spn = meanCenter(spn);
    correlations(1) = corr2(spn1,spn);
    correlations(2) = corr2(spn2,spn);
    correlations(3) = corr2(spn3,spn);
    correlations(4) = corr2(spn4,spn);
    correlations(5) = corr2(spn5,spn);
    correlations(6) = corr2(spn6,spn);
    [m,index] = max(correlations);
    if index == 1
        cam1 = [cam1, images{i,2}];
    end
    if index == 2
        cam2 = [cam2, images{i,2}];
    end
    if index == 3
        cam3 = [cam3, images{i,2}];
    end
    if index == 4
        cam4 = [cam4, images{i,2}];
    end
    if index == 5
        cam5 = [cam5, images{i,2}];
    end
    if index == 6
        cam6 = [cam6, images{i,2}];
    end
end
disp('afga 504');
disp(cam1);
disp('afga 830i');
disp(cam2);
disp('afga sensor505');
disp(cam3);
disp('afga sensor530s');
disp(cam4);
disp('canon ixus55');
disp(cam5);
disp('canon ixus70');
disp(cam6);
%save('testImages.mat','images');

function spn = computeSPN(images)
spn = zeros([800,800],'uint8');
for i = 1:length(images)
    startY = (height(images{i})-800)/2;
    startX = (width(images{i})-800)/2;
    image = images{i};
    denoisedImage = wiener2(image,[3 3]);
    spn = spn + (image(startY:startY+799,startX:startX+799)-denoisedImage(startY:startY+799,startX:startX+799));
end
spn = spn / length(images);
end

function spn = computeSPN2(image)
startY = (height(image)-800)/2;
startX = (width(image)-800)/2;
denoisedImage = wiener2(image,[3 3]);
spn = image(startY:startY+799,startX:startX+799)-denoisedImage(startY:startY+799,startX:startX+799);
end

function cspn = meanCenter(spn)
cspn = spn - mean(spn,'all');
end