function [X_train, y_train, X_test, y_test, preprocessing_info] = preprocess_data(data)
% PREPROCESS_DATA Preprocesses the transmission line fault data for modeling
%
% Parameters:
%   data - Table with transmission line fault data
%
% Returns:
%   X_train - Training features (normalized)
%   y_train - Training labels
%   X_test - Test features (normalized)
%   y_test - Test labels
%   preprocessing_info - Structure with preprocessing parameters for future use

fprintf('Preprocessing transmission line data...\n');

% Convert fault types to numeric labels
[y_numeric, fault_classes] = grp2idx(categorical(data.FaultType));

% Extract features - we'll use the electromagnetic parameters
feature_cols = {'Real_Permittivity', 'Imag_Permittivity', 'Conductivity', ...
                'Refl_Coef_Magnitude', 'Refl_Coef_Phase', 'VSWR'};
X = table2array(data(:, feature_cols));

% Check for and handle negative or zero values before log transformation
if any(X(:, 2) <= 0)
    fprintf('  Warning: Non-positive values found in Imag_Permittivity. Adding small offset.\n');
    X(:, 2) = X(:, 2) + abs(min(X(:, 2))) + eps;
end

if any(X(:, 3) <= 0)
    fprintf('  Warning: Non-positive values found in Conductivity. Adding small offset.\n');
    X(:, 3) = X(:, 3) + abs(min(X(:, 3))) + eps;
end

% Apply log transformation to highly skewed features
X(:, 2) = log10(X(:, 2));  % Log transform for Imag_Permittivity
X(:, 3) = log10(X(:, 3));  % Log transform for Conductivity

% Cap VSWR values to avoid numerical issues
X(:, 6) = min(X(:, 6), 100);

% Ensure no complex values remain
if ~isreal(X)
    fprintf('  Warning: Complex values detected after transformation. Taking absolute values.\n');
    X = abs(X);
end

% Calculate mean and standard deviation for normalization
mu = mean(X);
sigma = std(X);

% Z-score normalization (standardization)
X_scaled = (X - mu) ./ sigma;

fprintf('  Applied log transform to Imag_Permittivity and Conductivity\n');
fprintf('  Standardized all features to zero mean and unit variance\n');

% Split data into training (80%) and testing (20%) sets
cv = cvpartition(height(data), 'HoldOut', 0.2);
X_train = X_scaled(cv.training, :);
y_train = y_numeric(cv.training);
X_test = X_scaled(cv.test, :);
y_test = y_numeric(cv.test);

% Store preprocessing information for future predictions
preprocessing_info = struct();
preprocessing_info.feature_cols = feature_cols;
preprocessing_info.mu = mu;
preprocessing_info.sigma = sigma;
preprocessing_info.log_transform_cols = [2, 3];
preprocessing_info.fault_classes = fault_classes;

fprintf('  Split data into %d training and %d test samples\n', ...
    length(y_train), length(y_test));

% ==== Visualization REMOVED ====
% The boxplot display of feature distributions by fault type is now only handled in plot_results.m.

end