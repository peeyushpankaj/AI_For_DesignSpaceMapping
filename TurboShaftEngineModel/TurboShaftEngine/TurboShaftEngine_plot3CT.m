% Code to plot GasTurbine map from sscfluids_brayton_cycle

% Copyright 2016-2020 The MathWorks, Inc.

% Generate simulation results if they don't exist
if(~exist('simlog_TurboShaftEngine', 'var'))
    sim('TurboShaftEngine')
end

plotTurbineMap(turbine, simlog_TurboShaftEngine)

% Create map from turbine data
function plotTurbineMap(CT, simlog)

fluids.internal.mask.plotTurbineMap('TurboShaftEngine_mod/TurboShaftEngine/CoreTurbine');

%% Plot Operating Line

ax(1) = subplot(2, 1, 2);
hold on;

% Get simulation results
t = simlog.TurboShaftEngine.CoreTurbine.mdot_A.series.time;
mdot_A = simlog.TurboShaftEngine.CoreTurbine.mdot_A.series.values('kg/s');
p_A = simlog.TurboShaftEngine.CoreTurbine.A.p.series.values('MPa');
p_B = simlog.TurboShaftEngine.CoreTurbine.B.p.series.values('MPa');
T_A = simlog.TurboShaftEngine.CoreTurbine.A.T.series.values('K');

% Compute corrected mass flow rate and pressure ratio
mdot_corrected = mdot_A .* sqrt(T_A/CT.reference_temperature) ./ (p_A/CT.reference_pressure);
pr = p_A ./ p_B;

% Skip the initial transients
idx = t >= 100;
mdot_corrected = mdot_corrected(idx);
pr = pr(idx);

% Plot the operating line
LineColors = get(gca, 'ColorOrder');
h = plot(pr, mdot_corrected, 'Color', LineColors(5,:), 'LineWidth', 2, 'DisplayName', 'Operating Line');
set(gcf,'Name','TurboShaftEngine_plot3turbine')
hold off;
end