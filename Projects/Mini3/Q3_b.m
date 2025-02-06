data = load('steamgen.dat')
data = (data - mean(data, 1)) ./ std(data, 0, 1);
x1 = data(2:end, 2:end-4);
x2 = data(1:end-1, 2:end-4);
x = [x1 x2];
y1 = data(2:end, end-3);
y2 = data(2:end, end-2);
y3 = data(2:end, end-1);
y4 = data(2:end, end);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt = genfisOptions('SubtractiveClustering');
fis1 = genfis(x,y1, opt);
fis2 = genfis(x,y2, opt);
fis3 = genfis(x,y3, opt);
fis4 = genfis(x,y4, opt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
testingData1 = [x y1];
testingData2 = [x y2];
testingData3 = [x y3];
testingData4 = [x y4];
options1 = anfisOptions('InitialFIS',fis1);   
options1.EpochNumber = 10;
options2 = anfisOptions('InitialFIS',fis2);   
options2.EpochNumber = 10;
options3 = anfisOptions('InitialFIS',fis3);   
options3.EpochNumber = 10;
options4 = anfisOptions('InitialFIS',fis4);   
options4.EpochNumber = 10;
[fis1,trainError1,stepSize1] = anfis(testingData1,options1);
[fis2,trainError2,stepSize2] = anfis(testingData2,options2);
[fis3,trainError3,stepSize3] = anfis(testingData3,options3);
[fis4,trainError4,stepSize4] = anfis(testingData4,options4);

