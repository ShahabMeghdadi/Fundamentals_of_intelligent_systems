data = csvread('matlabin.csv', 1, 0); 
x = data(:,1:end-1);
y = data(:,end);
test_size = 0.2;
cv = cvpartition(size(x, 1), 'HoldOut', test_size);  
x_train = x(training(cv), :);  % Training data (features)
y_train = y(training(cv));     % Training labels
x_test = x(test(cv), :);       % Test data (features)
y_test = y(test(cv));          % Test labels
opt = genfisOptions('SubtractiveClustering');
fis = genfis(x_train, y_train, opt);
trainData = [x_train y_train];
testingData = [x_test y_test];
options = anfisOptions('InitialFIS',fis);   
options.EpochNumber = 100;
[fis,trainError,stepSize] = anfis(trainData,options);
y_pred = evalfis(fis, x_test);
mse = mean((y_test - y_pred).^2);
disp(['MSE: ', num2str(mse)]);
ss_tot = sum((y_test - mean(y_test)).^2);  % Total sum of squares
ss_res = sum((y_test - y_pred).^2);        % Residual sum of squares
r2_score = 1 - (ss_res / ss_tot);          % R² formula
disp(['R² Score: ', num2str(r2_score)]);

