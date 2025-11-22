% Main script for Transmission Line Fault Detection Project
% This script orchestrates the entire workflow

clear all;
close all;
clc;

fprintf('================================================\n');
fprintf('   TRANSMISSION LINE FAULT DETECTION PROJECT    \n');
fprintf('================================================\n\n');

% Add all subdirectories to path
addpath('src', 'visualization', 'models', 'data');

% Step 1: Simulate transmission line and generate dataset
fprintf('Step 1: Simulating transmission line faults...\n');
[data, simulation_results] = simulate_transmission_line(500);
fprintf('Generated %d samples across 4 fault types\n\n', height(data));

% Save the dataset
if ~exist('data', 'dir')
    mkdir('data');
end
save('data/transmission_line_data.mat', 'data', 'simulation_results');
writetable(data, 'data/transmission_line_data.csv');

% Step 2: Preprocess the data
fprintf('Step 2: Preprocessing data...\n');
[X_train, y_train, X_test, y_test, preprocessing_info] = preprocess_data(data);
fprintf('Data split into %d training and %d testing samples\n\n', ...
    size(X_train, 1), size(X_test, 1));

% Step 3: Train and evaluate only SVM model
fprintf('Step 3: Training SVM classification model...\n');
[best_model, model_info] = train_model(X_train, y_train, X_test, y_test);
fprintf('Best model: %s (Accuracy: %.2f%%)\n\n', ...
    model_info.best_model_name, model_info.best_accuracy*100);

% Step 4: Visualize results (only selected figures)
fprintf('Step 4: Visualizing results...\n');
plot_results(data, simulation_results, model_info);

% Step 5: Launch GUI
fprintf('Step 5: Launching fault detection GUI...\n');
fault_detection_gui(best_model, preprocessing_info);

fprintf('\nProject execution complete!\n');