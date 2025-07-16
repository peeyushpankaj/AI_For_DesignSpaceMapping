% Code to plot PowerTurbine map from sscfluids_brayton_cycle

% Copyright 2016-2020 The MathWorks, Inc.

% Generate simulation results if they don't exist
if(~exist('simlog_TurboShaftEngine', 'var'))
    sim('TurboShaftEngine')
end

plotAPUMap(PT, simlog_TurboShaftEngine)

% Create map from PT data
function plotAPUMap(PT, simlog)

fluids.internal.mask.plotTurbineMap('TurboShaftEngine_mod/TurboShaftEngine/PowerTurbine');

%% Plot Operating Line
ax(1) = subplot(2, 1, 2);
hold on;

% Get simulation results
t = simlog.TurboShaftEngine.PowerTurbine.mdot_A.series.time;
mdot_A = simlog.TurboShaftEngine.PowerTurbine.mdot_A.series.values('kg/s');
p_A = simlog.TurboShaftEngine.PowerTurbine.A.p.series.values('MPa');
p_B = simlog.TurboShaftEngine.PowerTurbine.B.p.series.values('MPa');
T_A = simlog.TurboShaftEngine.PowerTurbine.A.T.series.values('K');

% Compute corrected mass flow rate and pressure ratio
mdot_corrected = mdot_A .* sqrt(T_A/PT.reference_temperature) ./ (p_A/PT.reference_pressure);
pr = p_A ./ p_B;

% Skip the initial transients
idx = t >= 100;
mdot_corrected = mdot_corrected(idx);
pr = pr(idx);

% Plot the operating line
LineColors = get(gca, 'ColorOrder');
h = plot(pr, mdot_corrected, 'Color', LineColors(5,:), 'LineWidth', 2, 'DisplayName', 'Operating Line');
set(gcf,'Name','TurboShaftEngine_plot4PT')
hold off;
end