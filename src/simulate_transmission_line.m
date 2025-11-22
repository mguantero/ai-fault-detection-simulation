function [data, simulation_results] = simulate_transmission_line(samples_per_class)
% SIMULATE_TRANSMISSION_LINE Simulates a coaxial transmission line with different fault types
%
% Parameters:
%   samples_per_class - Number of samples to generate for each fault type
%
% Returns:
%   data - Table with generated electromagnetic parameters and fault types
%   simulation_results - Structure with simulation details for visualization

if nargin < 1
    samples_per_class = 500;
end

fprintf('Simulating coaxial transmission line with faults...\n');

% Set random seed for reproducibility
rng(42);

% Define physical parameters for coaxial line
line_length = 10;  % meters
frequency = 1e9;   % 1 GHz operation frequency
c = 3e8;           % speed of light in vacuum (m/s)
wavelength = c / frequency;
z0 = 50;           % characteristic impedance (ohms)

% Initialize arrays for each parameter
Real_Permittivity = [];
Imag_Permittivity = [];
Conductivity = [];
Refl_Coef_Magnitude = [];
Refl_Coef_Phase = [];
VSWR = [];
FaultType = {};
Position = [];     % Position of fault from source (m)

% Store simulation details for later visualization
simulation_results = struct();

% ==================== 1. NORMAL CONDITION ====================
fprintf('  Generating normal conditions...\n');
% For normal condition, the load impedance is close to Z0 (matched)
z_load_normal = z0 + z0 * 0.01 * randn(samples_per_class, 1);
position_normal = line_length * ones(samples_per_class, 1);  % No fault, at end

% Calculate parameters for normal condition
real_perm_normal = 2.0 + 0.1 * randn(samples_per_class, 1);
imag_perm_normal = max(2e-5 + 0.5e-5 * randn(samples_per_class, 1), 1e-10);  % Ensure positive
conduct_normal = max(57e6 + 5e5 * randn(samples_per_class, 1), 1);  % Ensure positive

% Calculate reflection coefficient for matched load (small reflection)
gamma_normal = (z_load_normal - z0) ./ (z_load_normal + z0);
refl_mag_normal = abs(gamma_normal);
refl_phase_normal = angle(gamma_normal);
% Ensure VSWR doesn't become infinite with perfect reflection
vswr_normal = (1 + refl_mag_normal) ./ max(1 - refl_mag_normal, 1e-6);
% Cap extremely high VSWR values
vswr_normal = min(vswr_normal, 100);

% ==================== 2. OPEN FAULT ====================
fprintf('  Generating open fault conditions...\n');
% For open circuit, Z is very high (ideally infinite)
z_load_open = 1e6 + 1e5 * randn(samples_per_class, 1);  % Very high impedance
position_open = line_length * rand(samples_per_class, 1);  % Random position

% Calculate parameters for open fault
real_perm_open = 1.0 + 0.2 * randn(samples_per_class, 1);
imag_perm_open = max(1e-6 + 1e-6 * abs(randn(samples_per_class, 1)), 1e-10);  % Ensure positive
conduct_open = max(1e5 + 5e4 * randn(samples_per_class, 1), 1);  % Ensure positive

% Reflection coefficient for open circuit (close to 1∠0°)
gamma_open = (z_load_open - z0) ./ (z_load_open + z0);
refl_mag_open = abs(gamma_open);
refl_phase_open = angle(gamma_open);
% Ensure VSWR doesn't become infinite with perfect reflection
vswr_open = (1 + refl_mag_open) ./ max(1 - refl_mag_open, 1e-6);
% Cap extremely high VSWR values
vswr_open = min(vswr_open, 100);

% ==================== 3. SHORT FAULT ====================
fprintf('  Generating short fault conditions...\n');
% For short circuit, Z is very low (ideally zero)
z_load_short = 0.1 * rand(samples_per_class, 1);  % Very low impedance
position_short = line_length * rand(samples_per_class, 1);  % Random position

% Calculate parameters for short fault
real_perm_short = 3.0 + 0.3 * randn(samples_per_class, 1);
imag_perm_short = max(1e-3 + 5e-4 * abs(randn(samples_per_class, 1)), 1e-10);  % Ensure positive
conduct_short = max(1e8 + 2e7 * randn(samples_per_class, 1), 1);  % Ensure positive

% Reflection coefficient for short circuit (close to -1 or 1∠180°)
gamma_short = (z_load_short - z0) ./ (z_load_short + z0);
refl_mag_short = abs(gamma_short);
% Explicitly ensure phase is around pi for short circuits
refl_phase_short = pi + 0.1 * randn(samples_per_class, 1);
% Ensure VSWR doesn't become infinite with perfect reflection
vswr_short = (1 + refl_mag_short) ./ max(1 - refl_mag_short, 1e-6);
% Cap extremely high VSWR values
vswr_short = min(vswr_short, 100);

% ==================== 4. MISMATCH FAULT ====================
fprintf('  Generating impedance mismatch conditions...\n');
% For mismatch, load impedance is significantly different from Z0
mismatch_factor = 2.5 + 1.5 * rand(samples_per_class, 1);
z_load_mismatch = z0 * mismatch_factor;  % Multiplier for mismatch
position_mismatch = line_length * rand(samples_per_class, 1);  % Random position

% Calculate parameters for mismatch
real_perm_mismatch = 2.5 + 0.5 * randn(samples_per_class, 1);
imag_perm_mismatch = max(5e-5 + 3e-5 * abs(randn(samples_per_class, 1)), 1e-10);  % Ensure positive
conduct_mismatch = max(4e7 + 1e7 * randn(samples_per_class, 1), 1);  % Ensure positive

% Reflection coefficient for impedance mismatch (moderate magnitude)
gamma_mismatch = (z_load_mismatch - z0) ./ (z_load_mismatch + z0);
refl_mag_mismatch = abs(gamma_mismatch);
refl_phase_mismatch = angle(gamma_mismatch);
% Ensure VSWR doesn't become infinite with perfect reflection
vswr_mismatch = (1 + refl_mag_mismatch) ./ max(1 - refl_mag_mismatch, 1e-6);
% Cap extremely high VSWR values
vswr_mismatch = min(vswr_mismatch, 100);

% Save simulation parameters for visualization
simulation_results.z0 = z0;
simulation_results.frequency = frequency;
simulation_results.line_length = line_length;
simulation_results.z_loads = {z_load_normal, z_load_open, z_load_short, z_load_mismatch};
simulation_results.positions = {position_normal, position_open, position_short, position_mismatch};
simulation_results.fault_types = {'Normal', 'Open', 'Short', 'Mismatch'};

% Combine all data
Real_Permittivity = [real_perm_normal; real_perm_open; real_perm_short; real_perm_mismatch];
Imag_Permittivity = [imag_perm_normal; imag_perm_open; imag_perm_short; imag_perm_mismatch];
Conductivity = [conduct_normal; conduct_open; conduct_short; conduct_mismatch];
Refl_Coef_Magnitude = [refl_mag_normal; refl_mag_open; refl_mag_short; refl_mag_mismatch];
Refl_Coef_Phase = [refl_phase_normal; refl_phase_open; refl_phase_short; refl_phase_mismatch];
VSWR = [vswr_normal; vswr_open; vswr_short; vswr_mismatch];
Position = [position_normal; position_open; position_short; position_mismatch];

% Create labels
FaultType = [repmat({'Normal'}, samples_per_class, 1);
             repmat({'Open'}, samples_per_class, 1);
             repmat({'Short'}, samples_per_class, 1);
             repmat({'Mismatch'}, samples_per_class, 1)];

% Create table
data = table(Real_Permittivity, Imag_Permittivity, Conductivity, ...
             Refl_Coef_Magnitude, Refl_Coef_Phase, VSWR, Position, FaultType);

fprintf('  Simulation complete. Generated %d samples.\n', height(data));

% Double check for any negative or complex values
if any(data.Imag_Permittivity <= 0)
    fprintf('  Warning: Found non-positive values in Imag_Permittivity. This may cause issues with log transformation.\n');
end
if any(data.Conductivity <= 0)
    fprintf('  Warning: Found non-positive values in Conductivity. This may cause issues with log transformation.\n');
end

% Improved visualization of reflection coefficients
figure;
colors = {'g', 'r', 'b', 'm'};  % Green, Red, Blue, Magenta
markers = {'o', 'x', 's', 'd'};  % Circle, X, Square, Diamond
fault_names = {'Normal', 'Open', 'Short', 'Mismatch'};
hold on;

% Plot each fault type
for i = 1:4
    idx = strcmp(data.FaultType, fault_names{i});
    
    % Use different sampling strategy for each fault type
    if strcmp(fault_names{i}, 'Normal')
        subset = randsample(find(idx), min(50, sum(idx)));
    elseif strcmp(fault_names{i}, 'Open')
        subset = randsample(find(idx), min(100, sum(idx))); % Show more open fault points
        % Add a small random jitter to open fault phase to make them more visible
        data.Refl_Coef_Phase(subset) = data.Refl_Coef_Phase(subset) + 0.05 * randn(length(subset), 1);
    elseif strcmp(fault_names{i}, 'Short')
        subset = randsample(find(idx), min(50, sum(idx)));
    else % Mismatch
        subset = randsample(find(idx), min(80, sum(idx)));
    end
    
    % Adjust marker size for better visibility
    marker_size = 30;
    if strcmp(fault_names{i}, 'Open')
        marker_size = 40;  % Larger markers for open faults
    end
    
    % Plot with clear markers
    h = scatter(data.Refl_Coef_Magnitude(subset), data.Refl_Coef_Phase(subset), ...
        marker_size, colors{i}, markers{i}, 'filled', 'DisplayName', fault_names{i});
    
    % Make sure Open faults are clearly visible in the legend
    if strcmp(fault_names{i}, 'Open')
        set(h, 'MarkerEdgeColor', 'k');  % Add black edge to open fault markers
    end
end

title('Reflection Coefficient Distribution by Fault Type');
xlabel('Magnitude');
ylabel('Phase (radians)');
legend('Location', 'best');
grid on;
xlim([-0.1, 1.1]);  % Ensure full magnitude range is visible
ylim([-3.5, 3.5]);  % Full phase range (-π to π)
hold off;

end