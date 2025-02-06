s = tf('s');
T = s / (s + 1); 
theta = 3; %delay
[num_pade, den_pade] = pade(theta, 2); % 2nd-order Pade
Pade_approx = tf(num_pade, den_pade);
T_delayed = T * Pade_approx;
[Gm, Pm, Wcg, Wcp] = margin(T_delayed);
% PID parameters
Kp = 0.6 * Ku;
Ti = Tu / 2;
Td = Tu / 8;
C = pid(Kp, Kp/Ti, Kp*Td);

% Closed-loop system
sys_cl = feedback(C * T_delayed, 1);
t = 0:0.1:20;          
u = ones(size(t));     
n = 0.1 * randn(size(t)); 
u_noisy = u + n;      

[y_noisy, ~] = lsim(sys_cl, u_noisy, t);
[y_clean, ~] = lsim(sys_cl, u, t); 

figure;
plot(t, y_clean, 'b', 'LineWidth', 1.5); hold on;
plot(t, y_noisy, 'r', 'LineWidth', 1);
plot(t, u, 'k--', 'LineWidth', 1);
legend('????? ???? ????', '????? ?? ????', '????? ????');
xlabel('???? (?????)');
ylabel('????');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fis = mamfis('Name', 'FuzzyController');

fis = addInput(fis, [-1 1], 'Name', 'Error');
fis = addInput(fis, [-0.5 0.5], 'Name', 'dError');
fis = addOutput(fis, [-2 2], 'Name', 'Control');

fis = addMF(fis, 'Error', 'trapmf', [-1 -1 -0.8 -0.5], 'Name', 'NB');
fis = addMF(fis, 'Error', 'trimf', [-0.8 -0.5 -0.2], 'Name', 'NM');
fis = addMF(fis, 'Error', 'trimf', [-0.3 0 0.3], 'Name', 'Z');
fis = addMF(fis, 'Error', 'trimf', [0.2 0.5 0.8], 'Name', 'PM');
fis = addMF(fis, 'Error', 'trapmf', [0.5 0.8 1 1], 'Name', 'PB');

fis = addMF(fis, 'dError', 'trapmf', [-0.5 -0.5 -0.3 -0.1], 'Name', 'NB');
fis = addMF(fis, 'dError', 'trimf', [-0.3 -0.15 0], 'Name', 'NM');
fis = addMF(fis, 'dError', 'trimf', [-0.1 0 0.1], 'Name', 'Z');
fis = addMF(fis, 'dError', 'trimf', [0 0.15 0.3], 'Name', 'PM');
fis = addMF(fis, 'dError', 'trapmf', [0.1 0.3 0.5 0.5], 'Name', 'PB');

fis = addMF(fis, 'Control', 'trapmf', [-2 -2 -1.5 -1], 'Name', 'SD');
fis = addMF(fis, 'Control', 'trimf', [-1.5 -1 -0.5], 'Name', 'MD');
fis = addMF(fis, 'Control', 'trimf', [-0.5 0 0.5], 'Name', 'NC');
fis = addMF(fis, 'Control', 'trimf', [0.5 1 1.5], 'Name', 'MI');
fis = addMF(fis, 'Control', 'trapmf', [1 1.5 2 2], 'Name', 'SI');

ruleList = [
    1 1 5 1 1;
    1 2 4 1 1;
    1 3 4 1 1;
    1 4 3 1 1;
    1 5 2 1 1;
    2 1 4 1 1;
    2 2 4 1 1;
    2 3 3 1 1;
    2 4 2 1 1;
    2 5 2 1 1;
    3 1 4 1 1;
    3 2 3 1 1;
    3 3 3 1 1;
    3 4 2 1 1;
    3 5 1 1 1;
    4 1 3 1 1;
    4 2 2 1 1;
    4 3 2 1 1;
    4 4 2 1 1;
    4 5 1 1 1;
    5 1 2 1 1;
    5 2 2 1 1;
    5 3 1 1 1;
    5 4 1 1 1;
    5 5 1 1 1;
];

fis = addRule(fis, ruleList);

t = 0:0.1:20;
u = ones(size(t));
n = 0.1 * randn(size(t)); 
u = u + n
y = zeros(size(t));
e = zeros(size(t));
de = zeros(size(t));

for i = 2:length(t)
    e(i) = u(i) - y(i-1);
    de(i) = (e(i) - e(i-1)) / (t(i) - t(i-1));
    control = evalfis(fis, [e(i), de(i)]);
    [y_temp, ~] = lsim(T_delayed, control * ones(1, i), t(1:i));
    y(i) = y_temp(end);
end

figure;
plot(t, y, 'LineWidth', 1.5);
hold on;
plot(t, u, 'k--', 'LineWidth', 1);
xlabel('???? (?????)');
ylabel('????');
title('???? ????? ?? ?????? ????');
legend('????? ?????', '????? ????');
grid on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C2 = pid(0.4013, 1.139, 0);
sys_cl2 = feedback(C2 * T_delayed, 1);

[y_noisy2, ~] = lsim(sys_cl2, u_noisy, t);
[y_clean2, ~] = lsim(sys_cl2, u, t); 

figure;
plot(t, y_clean, 'b', 'LineWidth', 1.5); hold on;
plot(t, y_noisy, 'r', 'LineWidth', 1);
plot(t, u, 'k--', 'LineWidth', 1);
legend('????? ???? ????', '????? ?? ????', '????? ????');
xlabel('???? (?????)');
ylabel('????');