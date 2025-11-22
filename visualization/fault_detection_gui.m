function fault_detection_gui(model, preprocessing_info)
% FAULT_DETECTION_GUI Create a simple GUI for fault detection
%
% Parameters:
%   model - Trained classification model
%   preprocessing_info - Structure with preprocessing parameters

% Create a figure
fig = figure('Name', 'Transmission Line Fault Detector', ...
             'Position', [300, 300, 700, 550], ...
             'MenuBar', 'none', ...
             'NumberTitle', 'off', ...
             'Color', [0.94, 0.94, 0.94]);

% Create a dark blue header bar
header_panel = uipanel('Position', [0, 0.95, 1, 0.05], ...
                      'BackgroundColor', [0, 0.2, 0.4], ...
                      'BorderType', 'none');

% Title on the header bar
uicontrol('Parent', header_panel, ...
          'Style', 'text', ...
          'String', 'Transmission Line Fault Detector', ...
          'Position', [20, 5, 400, 20], ...
          'FontSize', 12, ...
          'FontWeight', 'bold', ...
          'ForegroundColor', [1, 1, 1], ...
          'BackgroundColor', [0, 0.2, 0.4]);

% Parameter input labels and default values
param_labels = {'Real Permittivity:', 'Imaginary Permittivity:', ...
                'Conductivity (S/m):', 'Reflection Coefficient Magnitude:', ...
                'Reflection Coefficient Phase (rad):', 'VSWR:'};
param_defaults = {'2.0751', '0.000022363', '57004019', '0.000065038', '-0.02673', '12.6437'};

% Create parameter input fields
edit_fields = cell(6, 1);
for i = 1:6
    uicontrol('Style', 'text', ...
              'String', param_labels{i}, ...
              'Position', [120, 520-i*50, 200, 25], ...
              'FontSize', 10, ...
              'HorizontalAlignment', 'right', ...
              'BackgroundColor', [0.94, 0.94, 0.94]);
    
    edit_fields{i} = uicontrol('Style', 'edit', ...
                              'String', param_defaults{i}, ...
                              'Position', [330, 520-i*50, 200, 25], ...
                              'FontSize', 10);
end

% Mode selection dropdown
uicontrol('Style', 'text', ...
          'String', 'Select input mode:', ...
          'Position', [120, 170, 200, 25], ...
          'FontSize', 10, ...
          'HorizontalAlignment', 'right', ...
          'BackgroundColor', [0.94, 0.94, 0.94]);

mode_selector = uicontrol('Style', 'popup', ...
                          'String', {'Manual Input', 'Simulate Normal', 'Simulate Open', 'Simulate Short', 'Simulate Mismatch'}, ...
                          'Position', [330, 170, 200, 25], ...
                          'FontSize', 10, ...
                          'Callback', @mode_selection_callback);

% Analyze and Clear buttons
analyze_btn = uicontrol('Style', 'pushbutton', ...
                        'String', 'Analyze', ...
                        'Position', [270, 120, 100, 40], ...
                        'FontSize', 12, ...
                        'BackgroundColor', [0.4, 0.7, 0.9], ...
                        'Callback', @analyze_callback);

clear_btn = uicontrol('Style', 'pushbutton', ...
                     'String', 'Clear', ...
                     'Position', [380, 120, 100, 40], ...
                     'FontSize', 12, ...
                     'BackgroundColor', [0.9, 0.5, 0.5], ...
                     'Callback', @clear_callback);

% Detection result panel (BIGGER now)
result_panel = uipanel('Title', 'Detection Result', ...
                      'TitlePosition', 'centertop', ...
                      'Position', [0.25, 0.03, 0.5, 0.12], ... % made larger
                      'FontSize', 10, ...
                      'BackgroundColor', [0.94, 0.94, 0.94]);

% Fixed result text (smaller font + centered)
result_text = uicontrol('Parent', result_panel, ...
    'Style', 'text', ...
    'String', '', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.3, 0.9, 0.5], ... % centered properly
    'FontSize', 11, ... % smaller font for better fit
    'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.94, 0.94, 0.94]);

% ================================
% Callback functions
% ================================

% Mode selection callback
function mode_selection_callback(source, ~)
    selected_mode = source.Value;
    
    if selected_mode == 1
        return; % Manual input
    end
    
    switch selected_mode
        case 2, params = generate_params('Normal');
        case 3, params = generate_params('Open');
        case 4, params = generate_params('Short');
        case 5, params = generate_params('Mismatch');
    end
    
    % Update fields with generated parameters
    for i = 1:6
        set(edit_fields{i}, 'String', num2str(params(i), '%.6g'));
    end
    
    % Clear previous results
    set(result_text, 'String', '');
end

% Clear button callback
function clear_callback(~, ~)
    for i = 1:6
        set(edit_fields{i}, 'String', param_defaults{i});
    end
    set(result_text, 'String', '');
end

% Analyze button callback
function analyze_callback(~, ~)
    try
        params = zeros(1, 6);
        for i = 1:6
            params(i) = str2double(get(edit_fields{i}, 'String'));
        end
        
        % Preprocess input
        params_processed = preprocess_input(params);
        
        % Prediction
        [predicted_label, score] = predict(model, params_processed);
        fault_type = preprocessing_info.fault_classes{predicted_label};
        
        % Set color and update result
        if strcmp(fault_type, 'Normal')
            color = [0, 0.7, 0];  % Green
        else
            color = [0.8, 0, 0];  % Red
        end
        
        set(result_text, 'String', ['Detected: ' fault_type], ...
                         'ForegroundColor', color);
                     
    catch e
        set(result_text, 'String', 'Error in analysis', ...
                         'ForegroundColor', [0.8, 0, 0]);
    end
end

% ================================
% Helper functions
% ================================

% Preprocessing
function processed_input = preprocess_input(input)
    log_cols = preprocessing_info.log_transform_cols;
    for i = log_cols
        input(i) = log10(input(i));
    end
    processed_input = (input - preprocessing_info.mu) ./ preprocessing_info.sigma;
end

% Simulated parameter generation
function params = generate_params(fault_type)
    rng('shuffle');
    switch fault_type
        case 'Normal'
            real_perm = 2.0 + 0.1 * randn();
            imag_perm = 2e-5 + 0.5e-5 * randn();
            conduct = 57e6 + 5e5 * randn();
            refl_mag = 1e-4 + 5e-5 * abs(randn());
            refl_phase = -0.03 + 0.02 * randn();
            vswr = 1 + 0.2 * abs(randn()) + 10 * refl_mag;
        case 'Open'
            real_perm = 1.0 + 0.2 * randn();
            imag_perm = 1e-6 + 1e-6 * abs(randn());
            conduct = 1e5 + 5e4 * randn();
            refl_mag = 0.95 + 0.05 * rand();
            refl_phase = 0.0 + 0.1 * randn();
            vswr = (1 + refl_mag) / (1 - refl_mag) + 0.5 * randn();
        case 'Short'
            real_perm = 3.0 + 0.3 * randn();
            imag_perm = 1e-3 + 5e-4 * abs(randn());
            conduct = 1e8 + 2e7 * randn();
            refl_mag = 0.90 + 0.09 * rand();
            refl_phase = pi + 0.2 * randn();
            vswr = (1 + refl_mag) / (1 - refl_mag) + 0.5 * randn();
        case 'Mismatch'
            real_perm = 2.5 + 0.5 * randn();
            imag_perm = 5e-5 + 3e-5 * abs(randn());
            conduct = 4e7 + 1e7 * randn();
            refl_mag = 0.3 + 0.2 * rand();
            refl_phase = -1.0 + 2.0 * rand();
            vswr = (1 + refl_mag) / (1 - refl_mag) + 0.3 * randn();
        otherwise
            error('Unknown fault type');
    end
    params = [real_perm, imag_perm, conduct, refl_mag, refl_phase, vswr];
end

end
