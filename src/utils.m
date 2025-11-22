% Utility functions for transmission line fault detection project

function vswr = reflection_to_vswr(reflection_coef)
% Converts reflection coefficient to VSWR
% 
% Parameters:
%   reflection_coef - Complex reflection coefficient
%
% Returns:
%   vswr - Voltage Standing Wave Ratio

    mag = abs(reflection_coef);
    vswr = (1 + mag) ./ (1 - mag);
end

function reflection_coef = impedance_to_reflection(z_load, z0)
% Converts load impedance to reflection coefficient
%
% Parameters:
%   z_load - Load impedance (ohms)
%   z0 - Characteristic impedance (ohms)
%
% Returns:
%   reflection_coef - Complex reflection coefficient

    reflection_coef = (z_load - z0) ./ (z_load + z0);
end

function z_load = reflection_to_impedance(reflection_coef, z0)
% Converts reflection coefficient to load impedance
%
% Parameters:
%   reflection_coef - Complex reflection coefficient
%   z0 - Characteristic impedance (ohms)
%
% Returns:
%   z_load - Load impedance (ohms)

    z_load = z0 .* (1 + reflection_coef) ./ (1 - reflection_coef);
end

function [epsilon_r, sigma] = calculate_material_properties(f, z_load, z0)
% Calculate material properties from frequency and impedance
%
% Parameters:
%   f - Frequency (Hz)
%   z_load - Load impedance (ohms)
%   z0 - Characteristic impedance (ohms)
%
% Returns:
%   epsilon_r - Complex relative permittivity
%   sigma - Conductivity (S/m)

    % Constants
    epsilon_0 = 8.85e-12;  % vacuum permittivity
    
    % Get reflection coefficient
    gamma = impedance_to_reflection(z_load, z0);
    
    % Phase velocity factor (simplified model)
    v_factor = 0.7 + 0.2 * (1 - abs(gamma));
    
    % Calculate simplified permittivity (real part)
    epsilon_r_real = 1 / (v_factor^2);
    
    % Calculate simplified imaginary part based on loss
    epsilon_r_imag = abs(gamma) * 1e-5;
    
    % Calculate conductivity (simplified relationship)
    sigma = 2 * pi * f * epsilon_0 * epsilon_r_imag * 1e7;
    
    % Return complex permittivity
    epsilon_r = complex(epsilon_r_real, epsilon_r_imag);
end