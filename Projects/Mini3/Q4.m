num_rules = 9;
num_training_points = 250;
total_points = 700;
learning_rate = 0.05;

state_values = zeros(num_training_points, num_rules);
output_values = zeros(num_training_points, num_rules);
spread_values = zeros(num_training_points, num_rules);
true_output = zeros(total_points, 1);
input_signal = zeros(total_points, 1);
state_input = zeros(total_points, 1);
predicted_output = zeros(total_points, 1);
model_output = zeros(total_points, 1);
z_values = zeros(total_points, 1);
rule_activations = zeros(total_points, 1);

input_signal(1) = -1 + 2 * rand;
true_output(1) = 0;
rule_activations(1) = 0.6 * sin(pi * input_signal(1)) + 0.3 * sin(3 * pi * input_signal(1)) + 0.1 * sin(5 * pi * input_signal(1));
model_output(1) = rule_activations(1);

input_min = -1;
input_max = 1;
input_step = (input_max - input_min) / (num_rules - 1);

for rule_idx = 1:num_rules
    state_values(1, rule_idx) = -1 + input_step * (rule_idx - 1);
    input_signal(1, rule_idx) = state_values(1, rule_idx);
    output_values(1, rule_idx) = 0.6 * sin(pi * input_signal(1, rule_idx)) + 0.3 * sin(3 * pi * input_signal(1, rule_idx)) + 0.1 * sin(5 * pi * input_signal(1, rule_idx));
end

spread_values(1, 1:num_rules) = (max(input_signal(1, :)) - min(input_signal(1, :))) / num_rules;
state_values(2, :) = state_values(1, :);
output_values(2, :) = output_values(1, :);
spread_values(2, :) = spread_values(1, :);

initial_state_values = state_values(1, :);
initial_spread_values = spread_values(1, :);
initial_output_values = output_values(1, :);

for training_idx = 2:num_training_points
    rule_sum = 0; weighted_sum = 0;
    state_input(training_idx) = -1 + 2 * rand;
    input_signal(training_idx) = state_input(training_idx);
    rule_activations(training_idx) = 0.6 * sin(pi * input_signal(training_idx)) + 0.3 * sin(3 * pi * input_signal(training_idx)) + 0.1 * sin(5 * pi * input_signal(training_idx));
    
    activations = zeros(1, num_rules);
    for rule_idx = 1:num_rules
        z_values(rule_idx) = exp(-((state_input(training_idx) - state_values(training_idx, rule_idx)) / spread_values(training_idx, rule_idx))^2);
        activations(rule_idx) = z_values(rule_idx);
        rule_sum = rule_sum + activations(rule_idx);
        weighted_sum = weighted_sum + output_values(training_idx, rule_idx) * activations(rule_idx);
    end
    
    predicted_output(training_idx) = weighted_sum / rule_sum;
    
    output_values(training_idx + 1, :) = output_values(training_idx, :) + learning_rate * activations * (rule_activations(training_idx) - predicted_output(training_idx));
    state_values(training_idx + 1, :) = state_values(training_idx, :);
    spread_values(training_idx + 1, :) = spread_values(training_idx, :);
    
    true_output(training_idx + 1) = 0.3 * true_output(training_idx) + 0.6 * true_output(training_idx - 1) + rule_activations(training_idx);
    predicted_output(training_idx + 1) = 0.3 * true_output(training_idx) + 0.6 * true_output(training_idx - 1) + predicted_output(training_idx);
end

final_state_values = state_values(num_training_points, :);
final_spread_values = spread_values(num_training_points, :);
final_output_values = output_values(num_training_points, :);

for test_idx = num_training_points:total_points
    rule_sum = 0; weighted_sum = 0;
    state_input(test_idx) = sin(2 * test_idx * pi / 200);
    input_signal(test_idx) = state_input(test_idx);
    rule_activations(test_idx) = 0.6 * sin(pi * input_signal(test_idx)) + 0.3 * sin(3 * pi * input_signal(test_idx)) + 0.1 * sin(5 * pi * input_signal(test_idx));
    
    activations = zeros(1, num_rules);
    for rule_idx = 1:num_rules
        z_values(rule_idx) = exp(-((state_input(test_idx) - state_values(num_training_points, rule_idx)) / spread_values(num_training_points, rule_idx))^2);
        activations(rule_idx) = z_values(rule_idx);
        rule_sum = rule_sum + activations(rule_idx);
        weighted_sum = weighted_sum + output_values(num_training_points, rule_idx) * activations(rule_idx);
    end
    
    model_output(test_idx) = weighted_sum / rule_sum;
    true_output(test_idx + 1) = 0.3 * true_output(test_idx) + 0.6 * true_output(test_idx - 1) + rule_activations(test_idx);
    predicted_output(test_idx + 1) = 0.3 * true_output(test_idx) + 0.6 * true_output(test_idx - 1) + model_output(test_idx);
end

test_range = num_training_points+1:total_points;
RMSE = sqrt(mean((true_output(test_range) - predicted_output(test_range)).^2));
fprintf('RMSE for predicted data: %.4f\n', RMSE);

figure1 = figure('Color', [1 1 1]);
plot(1:701, true_output, 'b', 1:701, predicted_output, 'g', 'Linewidth', 2);
legend('Output of the system', 'Output of the model');
axis([0 701 -5 5]);
grid on;

[x_mesh, y_mesh] = meshgrid(linspace(input_min, input_max, 100), linspace(input_min, input_max, 100));
z_surface = zeros(size(x_mesh));

for i = 1:size(x_mesh, 1)
    for j = 1:size(x_mesh, 2)
        x_input = x_mesh(i, j);
        rule_sum = 0; weighted_sum = 0;
        activations = zeros(1, num_rules);
        for rule_idx = 1:num_rules
            z_values(rule_idx) = exp(-((x_input - state_values(num_training_points, rule_idx)) / spread_values(num_training_points, rule_idx))^2);
            activations(rule_idx) = z_values(rule_idx);
            rule_sum = rule_sum + activations(rule_idx);
            weighted_sum = weighted_sum + output_values(num_training_points, rule_idx) * activations(rule_idx);
        end
        z_surface(i, j) = weighted_sum / rule_sum;
    end
end

figure2 = figure('Color', [1 1 1]);
surf(x_mesh, y_mesh, z_surface);
xlabel('Input (x)');
ylabel('Input (y)');
zlabel('Output (predicted)');
title('Fuzzy Surface of the System');
