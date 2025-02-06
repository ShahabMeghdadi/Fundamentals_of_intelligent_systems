data = load('ballbeam.dat')
x = data(:,1)
outputData = data(:,2);
x3 = outputData(2: end-1);
outputData = outputData(3: end);
x0 = x(3: end);
x1 = x(2: end-1);
x2 = x(1: end-2);
inputData = [x0 x1 x2 x3];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt = genfisOptions('GridPartition');
opt.NumMembershipFunctions = [3 3 3 3];
opt.InputMembershipFunctionType = ["gaussmf" "gaussmf" "gaussmf" "gaussmf"];
fis = genfis(inputData,outputData, opt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trainingData = [inputData outputData];
options = anfisOptions('InitialFIS',fis);   
options.EpochNumber = 20;
options.InitialStepSize = 0.02;
options.StepSizeDecreaseRate = options.StepSizeDecreaseRate/2;
[fis,trainError,stepSize] = anfis(trainingData,options);