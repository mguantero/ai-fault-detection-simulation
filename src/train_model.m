function [best_model, model_info] = train_model(X_train, y_train, X_test, y_test)
% TRAIN_MODEL Train only SVM classification model and select the best one
%
% Parameters:
%   X_train - Training features
%   y_train - Training labels
%   X_test - Test features
%   y_test - Test labels
%
% Returns:
%   best_model - The best performing model
%   model_info - Structure with model performance metrics

fprintf('Training classification model (SVM only) for fault detection...\n');
model_names = {'SVM'};
training_times = zeros(1,1);
accuracies = zeros(1,1);
models = cell(1,1);

% Train SVM
fprintf('  Training SVM model...\n');
tic;
svm_model = fitcecoc(X_train, y_train, 'Learners', templateSVM('KernelFunction', 'rbf'));
training_times(1) = toc;
svm_pred = predict(svm_model, X_test);
accuracies(1) = sum(svm_pred == y_test) / length(y_test);
models{1} = svm_model;
fprintf('    Accuracy: %.2f%%\n', accuracies(1)*100);

best_model = svm_model;
best_model_name = 'SVM';

fprintf('  Best model: %s (Accuracy: %.2f%%)\n', best_model_name, accuracies(1)*100);

% Confusion matrix for SVM
y_pred = svm_pred;
C = confusionmat(y_test, y_pred);

% Precision, recall, F1-score for each class
num_classes = length(unique(y_train));
precision = diag(C) ./ sum(C, 1)';
recall = diag(C) ./ sum(C, 2);
f1_score = 2 * (precision .* recall) ./ (precision + recall);

model_info = struct();
model_info.model_names = model_names;
model_info.accuracies = accuracies;
model_info.training_times = training_times;
model_info.best_model_name = best_model_name;
model_info.best_accuracy = accuracies(1);
model_info.confusion_matrix = C;
model_info.precision = precision;
model_info.recall = recall;
model_info.f1_score = f1_score;
model_info.y_pred = y_pred;
model_info.y_test = y_test;

% Save best model
if ~exist('models', 'dir')
    mkdir('models');
end
save('models/best_model.mat', 'best_model', 'model_info');

end