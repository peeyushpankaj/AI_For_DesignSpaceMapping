% Code to plot compressor map

% Copyright 2016-2020 The MathWorks, Inc.

% Generate simulation results if they don't exist
if(~exist('simlog_TurboShaftEngine', 'var'))
    TurboShaftEngine_Params;
    sim('TurboShaftEngine')
end

ptCompressorMap(compressor, simlog_TurboShaftEngine);

% Create map from compressor data
function ptCompressorMap(Comp, simlog)

fluids.internal.mask.plotCompressorMap('TurboShaftEngine_mod/TurboShaftEngine/Compressor');
hold on;

% Get simulation results
t = simlog.TurboShaftEngine.Compressor.mdot_A.series.time;
mdot_A = simlog.TurboShaftEngine.Compressor.mdot_A.series.values('kg/s');
p_A = simlog.TurboShaftEngine.Compressor.A.p.series.values('MPa');
p_B = simlog.TurboShaftEngine.Compressor.B.p.series.values('MPa');
T_A = simlog.TurboShaftEngine.Compressor.A.T.series.values('K');

% Compute corrected mass flow rate and pressure ratio
mdot_corrected = mdot_A .* sqrt(T_A/Comp.reference_temperature) ./ (p_A/Comp.reference_pressure);
pr = p_B ./ p_A;

% Skip the initial transients
idx = t >= 100;
mdot_corrected = mdot_corrected(idx);
pr = pr(idx);

% Plot the operating line
LineColors = get(gca, 'ColorOrder');
plot(mdot_corrected, pr, 'Color', LineColors(5,:), 'LineWidth', 2, 'DisplayName', 'Operating Line');
set(gcf,'Name','TurboShaftEngine_plot2compressor')
hold off;


end
