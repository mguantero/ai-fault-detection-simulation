function smith_chart(data, z0)
% SMITH_CHART Create a standard Smith chart visualization of reflection data
%
% Parameters:
%   data - Table with transmission line fault data
%   z0 - Characteristic impedance (typically 50 ohms)

fprintf('Creating Smith chart visualization...\n');

% Create new figure with proper size
figure('Name', 'Smith Chart Visualization', 'NumberTitle', 'off', ...
       'Position', [100, 100, 800, 700]);
       
% IMPORTANT: Clear any existing plots and start fresh
clf;
hold on;

% Define colors and markers for fault types
fault_types = {'Normal', 'Open', 'Short', 'Mismatch'};
colors = {'g', 'k', 'b', 'm'};  % Green, Black, Blue, Magenta
markers = {'o', 'x', 's', 'd'};  % Circle, X, Square, Diamond

% Draw Smith chart background (FIXED CODE)
% Draw the outer unity circle
theta = linspace(0, 2*pi, 200);
plot(cos(theta), sin(theta), 'k-', 'LineWidth', 1, 'DisplayName', '');

% Draw constant resistance circles
r_values = [0, 0.2, 0.5, 1, 2, 5];
for r = r_values
    center = r/(1+r);
    radius = 1/(1+r);
    circle_x = center + radius*cos(theta);
    circle_y = radius*sin(theta);
    plot(circle_x, circle_y, 'k:', 'LineWidth', 0.5, 'DisplayName', '');
    
    % Add resistance labels (except at origin)
    if r > 0
        text(center + radius*0.05, 0.05, sprintf('%.1f', r), ...
            'FontSize', 8, 'HorizontalAlignment', 'left', 'Color', [0.4 0.4 0.4]);
    end
end

% Draw constant reactance arcs
x_values = [0.2, 0.5, 1, 2, 5];
for x = x_values
    % Positive reactance (upper half)
    [x_points, y_points] = reactance_arc(x);
    plot(x_points, y_points, 'k:', 'LineWidth', 0.5, 'DisplayName', '');
    
    % Negative reactance (lower half)
    [x_points, y_points] = reactance_arc(-x);
    plot(x_points, y_points, 'k:', 'LineWidth', 0.5, 'DisplayName', '');
    
    % Add reactance labels
    [end_x, end_y] = reactance_point(x, 0.5);
    text(end_x + 0.05, end_y, sprintf('j%.1f', x), ...
        'FontSize', 8, 'Color', [0.4 0.4 0.4]);
    [end_x, end_y] = reactance_point(-x, 0.5);
    text(end_x + 0.05, end_y, sprintf('-j%.1f', x), ...
        'FontSize', 8, 'Color', [0.4 0.4 0.4]);
end

% Draw the real axis
plot([-1, 1], [0, 0], 'k-', 'LineWidth', 1, 'DisplayName', '');

% Plot each fault type
legendEntries = {};
for i = 1:length(fault_types)
    fault_type = fault_types{i};
    
    % Get indices for current fault type
    idx = strcmp(data.FaultType, fault_type);
    if sum(idx) == 0
        continue;
    end
    
    % Get reflection coefficients
    mag = data.Refl_Coef_Magnitude(idx);
    phase = data.Refl_Coef_Phase(idx);
    
    % Convert to complex reflection coefficient
    gamma = mag .* exp(1i * phase);
    
    % Convert to normalized impedance (z/z0)
    z_norm = (1 + gamma) ./ (1 - gamma);
    
    % Calculate mean impedance for the legend
    mean_z = mean(abs(z_norm)) * z0;
    
    % Select subset of points to display (avoid overcrowding)
    num_points = min(50, length(z_norm));
    indices = round(linspace(1, length(z_norm), num_points));
    
    % Extract real and imaginary parts of normalized impedance
    r = real(z_norm(indices));
    x = imag(z_norm(indices));
    
    % Plot the points with appropriate marker and color
    h = scatter(r, x, 60, colors{i}, markers{i}, 'LineWidth', 2, ...
         'DisplayName', sprintf('%s (Z ≈ %.1f Ω)', fault_type, mean_z));
    legendEntries{end+1} = h;
end

% Finalize the plot
title('Smith Chart: Normalized Impedance (Z/Z0)', 'FontSize', 14);
legend([legendEntries{:}], 'Location', 'eastoutside');
axis equal;
axis([-1.2 1.2 -1.2 1.2]);
axis off;
hold off;

end

function [x_points, y_points] = reactance_arc(x)
    % Generate points for constant reactance arc
    r_values = linspace(0, 5, 100);
    x_points = zeros(1, length(r_values));
    y_points = zeros(1, length(r_values));
    
    for i = 1:length(r_values)
        [x_points(i), y_points(i)] = reactance_point(x, r_values(i));
    end
end

function [x, y] = reactance_point(x_norm, r_norm)
    % Calculate point on Smith chart for given normalized resistance and reactance
    z_norm = r_norm + 1i * x_norm;
    gamma = (z_norm - 1) ./ (z_norm + 1);
    x = real(gamma);
    y = imag(gamma);
end