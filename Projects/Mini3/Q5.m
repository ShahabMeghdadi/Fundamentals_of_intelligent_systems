clc;
clear;
close all
data_t = readtable('AirQualityUCI.xlsx');
data = table2array(data_t(:, 3:end));
data(any(data == -200, 2), :) = [];
data = (data - mean(data, 1)) ./ std(data, 0, 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numSamples = size(data, 1);
numTrain = round(0.6 * numSamples);
numTest = round(0.2 * numSamples);
numVal = numSamples - numTrain - numTest; 
rng(42); 
idx = randperm(numSamples); 
testIdx = idx(1:numTest);
valIdx = idx(numTest+1:numTest+numVal);
trainIdx = setdiff(1:numSamples, [testIdx, valIdx]); 
trainData = data(trainIdx, :);
testData = data(testIdx, :);
valData = data(valIdx, :);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputData = trainData(:,8);
trainData(:,8) = [];
%x0 = trainData(3:end, :);
%x1 = trainData(2:end-1, :);
%x2 = trainData(1:end-2, :);
inputData = trainData;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt = genfisOptions('SubtractiveClustering');
fis = genfis(inputData,outputData, opt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trainingData = [inputData outputData]
outtest = testData(:,8);
intest = testData;
intest(:,8) = []
testingData = [intest outtest];
options = anfisOptions('InitialFIS',fis);   
options.EpochNumber = 800;
options.InitialStepSize = 0.02;
options.StepSizeDecreaseRate = options.StepSizeDecreaseRate/2;
%[fis,trainError,stepSize] = anfis(trainingData,options);
options.ValidationData = testingData;
[fis,trainError,stepSize,chkFIS,chkError] = anfis(trainingData,options)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
subplot(3, 1, 1);
plot(trainError);
subplot(3, 1, 2);
plot(chkError);
subplot(3, 1, 3);
plot(stepSize);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trainingOutputFis = evalfis(chkFIS,trainingData(:,1:end-1))
testingOutputFis = evalfis(chkFIS,testingData(:,1:end-1))
mseTrain0 = mean((trainingOutputFis - trainingData(:,end)).^2);
mseTest0 = mean((testingOutputFis - testingData(:,end)).^2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mseTestArr = []
mseTrainArr = []
minErrTs = inf;
minErrTr = 0;
bestModel = [];
for i = 1:-0.01:0.01
    X = trainingData(:,1:end-1)';
    T = trainingData(:,end)';
    spread = i;
    net = newrbe(X,T,spread)
    Y = sim(net, X);
    mseTrain = mean((Y - T).^2);
    Y = sim(net, intest');
    mseTest = mean((Y - outtest').^2);
    mseTestArr = [mseTestArr mseTest]
    mseTrainArr = [mseTrainArr mseTrain]
    if mseTest < minErrTs
        bestModel = net;
        minErrTs = mseTest;
        minErrTr = mseTrain;
    end
end
figure;
subplot(2, 1, 1);
plot(mseTestArr);
subplot(2, 1, 2);
plot(mseTrainArr);
disp(minErrTr);
disp(minErrTs);
numCenters = size(bestModel.IW{1}, 1);  
disp(['Number of centers: ', num2str(numCenters)]);