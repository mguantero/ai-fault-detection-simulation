function plot_results(data, simulation_results, model_info)
% PLOT_RESULTS Create visualizations of simulation results and model performance
%
% Parameters:
%   data - Table with transmission line fault data
%   simulation_results - Structure with simulation details
%   model_info - Structure with model performance metrics

fprintf('Creating visualizations...\n\n');

% 1. Feature Distribution by Fault Type (improved formatting and spacing)
figure('Name', 'Feature Distributions by Fault Type');
feature_names = {'Real_Permittivity', 'Imag_Permittivity', 'Conductivity', ...
                'Refl_Coef_Magnitude', 'Refl_Coef_Phase', 'VSWR'};
nRows = 2;
nCols = 3;

% Custom subplot positions to leave extra space at the top for sgtitle
subplot_positions = [ ...
    0.05 0.57 0.28 0.32;  % subplot(2,3,1)
    0.37 0.57 0.28 0.32;  % subplot(2,3,2)
    0.69 0.57 0.28 0.32;  % subplot(2,3,3)
    0.05 0.13 0.28 0.32;  % subplot(2,3,4)
    0.37 0.13 0.28 0.32;  % subplot(2,3,5)
    0.69 0.13 0.28 0.32]; % subplot(2,3,6)

for i = 1:6
    ax = subplot(nRows, nCols, i);
    set(ax, 'Position', subplot_positions(i,:));

    current_data = table2array(data(:, i));
    boxplot(current_data, data.FaultType, 'Symbol', '.');
    ylabel('Value');
    title(feature_names{i}, 'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'none');
    xtickangle(45);
end
sgtitle('Feature Distributions by Fault Type', 'FontSize', 18, 'FontWeight', 'bold', 'Interpreter', 'none');
set(gcf, 'Position', [100, 100, 1200, 600]);

% 2. Reflection Coefficient Visualization (Complex Plane)
figure('Name', 'Reflection Coefficient Distribution');
colors = {'g', 'r', 'b', 'm'};
markers = {'o', 'x', 's', 'd'};
hold on;
th = linspace(0, 2*pi, 100);
x_circle = cos(th);
y_circle = sin(th);
plot(x_circle, y_circle, 'k--', 'LineWidth', 1, 'DisplayName', 'Unit Circle');

fault_types = {'Normal', 'Open', 'Short', 'Mismatch'};

for i = [1, 3, 4]
    fault_type = fault_types{i};
    idx = strcmp(data.FaultType, fault_type);
    magnitude = data.Refl_Coef_Magnitude(idx);
    phase = data.Refl_Coef_Phase(idx);

    x = magnitude .* cos(phase);
    y = magnitude .* sin(phase);

    num_points = min(50, length(x));
    step = max(1, floor(length(x) / num_points));
    indices = 1:step:length(x);
    indices = indices(1:min(num_points, length(indices)));

    scatter(x(indices), y(indices), 40, colors{i}, markers{i}, 'filled', 'DisplayName', fault_type);
end

open_idx = strcmp(data.FaultType, 'Open');
if sum(open_idx) > 0
    open_mag = data.Refl_Coef_Magnitude(open_idx);
    open_phase = data.Refl_Coef_Phase(open_idx);

    open_x = open_mag .* cos(open_phase);
    open_y = open_mag .* sin(open_phase);

    num_open_points = min(80, sum(open_idx));
    step = max(1, floor(length(open_x) / num_open_points));
    indices = 1:step:length(open_x);
    indices = indices(1:min(num_open_points, length(indices)));

    scatter(open_x(indices), open_y(indices), 60, 'r', 'x', 'LineWidth', 2, ...
            'MarkerEdgeColor', 'k', 'DisplayName', 'Open');
end

title('Reflection Coefficient in Complex Plane', 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('Real Part');
ylabel('Imaginary Part');
legend('Location', 'best');
axis equal;
grid on;
hold off;

% 3. Transmission Line Impedance Visualization
figure('Name', 'Transmission Line Impedance');
for i = 1:4
    subplot(2, 2, i);
    fault_type = simulation_results.fault_types{i};
    line([0, simulation_results.line_length], [0, 0], 'LineWidth', 3, 'Color', 'k');
    hold on;
    rectangle('Position', [-0.5, -0.3, 0.5, 0.6], 'Curvature', [0.2, 0.2], 'FaceColor', [0.8, 0.8, 0.8]);
    text(-0.25, -0.6, 'Source', 'HorizontalAlignment', 'center');
    rectangle('Position', [simulation_results.line_length, -0.3, 0.5, 0.6], ...
        'Curvature', [0.2, 0.2], 'FaceColor', [0.8, 0.8, 0.8]);
    text(simulation_results.line_length + 0.25, -0.6, 'Load', 'HorizontalAlignment', 'center');

    if ~strcmp(fault_type, 'Normal') && isfield(simulation_results, 'positions') && ...
            length(simulation_results.positions) >= i && ~isempty(simulation_results.positions{i})
        positions = simulation_results.positions{i};
        num_samples = min(20, length(positions));
        if num_samples > 0
            step_size = max(1, floor(length(positions)/num_samples));
            sample_idx = 1:step_size:length(positions);
            sample_idx = sample_idx(1:min(num_samples, length(sample_idx)));
            scatter(positions(sample_idx), zeros(size(sample_idx)), 50, 'rx', 'LineWidth', 2);
        end
    end

    if isfield(simulation_results, 'z_loads') && length(simulation_results.z_loads) >= i && ...
            ~isempty(simulation_results.z_loads{i})
        z_loads = simulation_results.z_loads{i};
        z_mean = mean(z_loads);
        z_std = std(z_loads);

        if strcmp(fault_type, 'Normal')
            text_color = [0 0.5 0];
        else
            text_color = 'r';
        end

        text(simulation_results.line_length/2, 0.5, sprintf('Z_%s = %.1f ± %.1f Ω', ...
            fault_type, z_mean, z_std), 'Color', text_color, ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end

    % Smaller font, bold, for subplot title
    title(['Transmission Line with ', fault_type, ' Condition'], ...
        'FontSize', 10, 'FontWeight', 'bold', 'Interpreter', 'none');
    xlim([-1, simulation_results.line_length + 1]);
    ylim([-1, 1]);
    axis off;
    hold off;
end

end