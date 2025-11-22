# Models Directory

This directory contains the trained machine learning models for the transmission line fault detection project.

## Files

- `best_model.mat`: The best performing machine learning model for fault detection
- Other model files generated during training

## Model Types

The project trains and evaluates several types of models:

1. **Decision Tree**: Simple and interpretable model that makes decisions based on feature thresholds
2. **Support Vector Machine (SVM)**: More complex model that finds optimal hyperplanes to separate classes
3. **K-Nearest Neighbors (KNN)**: Classification based on the k closest training examples

## Usage

The models can be loaded and used for prediction as follows:

```matlab
% Load the best model
load('best_model.mat');

% Preprocess new data using the same parameters used for training
X_new_processed = preprocess_input(X_new);

% Make prediction
fault_type = predict(best_model, X_new_processed);