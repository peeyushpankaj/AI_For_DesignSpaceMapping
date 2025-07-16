% Code to plot temperature-entropy diagram from sscfluids_brayton_cycle
%% Plot Description:
%
% This figure shows an animation of the Brayton Cycle on a
% temperature-entropy diagram over time. The five cycle points on the
% figure correspond to the sensor measurements labeled "T,s 1" to "T,s 5",
% respectively.

% Copyright 2016-2020 The MathWorks, Inc.

% Generate simulation results if they don't exist
if(~exist('simlog_sscfluids_brayton_cycle', 'var'))
    sim('sscfluids_brayton_cycle')
end

% Reuse figure if it exists, else create new figure
if ~exist('h1_sscfluids_brayton_cycle', 'var') || ...
        ~isgraphics(h1_sscfluids_brayton_cycle, 'figure')
    h1_sscfluids_brayton_cycle = figure('Name', 'sscfluids_brayton_cycle');
end
figure(h1_sscfluids_brayton_cycle)
clf(h1_sscfluids_brayton_cycle)

PlotTemperatureEntropyDiagram(simlog_sscfluids_brayton_cycle, [bdroot '/Air Properties'])



% Plot Brayton Cycle points from simulation result
function PlotTemperatureEntropyDiagram(simlog, prop_blk)

LineColors = get(gca, 'ColorOrder');

% Get air property tables from block mask
Simulink.Block.eval(prop_blk)
props = get_param(prop_blk, 'MaskWSVariables');
prop_names = {props.Name};
p_TLU = props(strcmp(prop_names, 'p_TLU2')).Value;
T_TLU = props(strcmp(prop_names, 'T_TLU2')).Value;
s_TLU = props(strcmp(prop_names, 's_TLU2')).Value;

% For each pressure, compute specific entropy as a function of temperature 
% Use log-space to improve fidelity
p_plot = [0.01 0.02 0.05 0.1, 0.2 0.5 1 2 5 10];
T_plot = logspace(log10(273.15), log10(2000), 100);
s_interp = griddedInterpolant({log10(T_TLU), log10(p_TLU)}, s_TLU);
s_plot = s_interp({log10(T_plot), log10(p_plot)});

% Plot pressure contours
for k = 1 : length(p_plot)
    h = plot(s_plot(:,k), T_plot, 'Color', LineColors(3,:), 'LineWidth', 0.5);
    h.Annotation.LegendInformation.IconDisplayStyle = 'off';
    hold on
    text(s_plot(70,k), T_plot(70), num2str(p_plot(k)), ...
        'HorizontalAlignment', 'right', 'Rotation', 45)
end
h.DisplayName = 'Pressure Lines (MPa)';
h.Annotation.LegendInformation.IconDisplayStyle = 'on';

% Get simulation results
t = simlog.Ts_1.Pressure_Temperature_Sensor_G.P.series.time;
m = length(t);
T = zeros(m, 5);
s = zeros(m, 5);
for k = 1 : 5
    T(:,k) = simlog.(['Ts_' num2str(k)]).Pressure_Temperature_Sensor_G.T.series.values('K');
    s(:,k) = simlog.(['Ts_' num2str(k)]).Thermodynamic_Properties_Sensor_G.S.series.values('kJ/(kg*K)');
end

% Interpolate results to obtain equal time steps
N = 300;
t_plot = linspace(t(1), t(end), N);
T_plot = interp1(t, [T, T(:,1)], t_plot);
s_plot = interp1(t, [s, s(:,1)], t_plot);

% Plot cycle points at t = 0
handle_cycle = plot(s_plot(1,:), T_plot(1,:), 'Color', LineColors(5,:), 'LineWidth', 2);
handle_cycle.Annotation.LegendInformation.IconDisplayStyle = 'off';
markers = 'osd^v';
handle_points = gobjects(1, 5);
for k = 1 : 5
    handle_points(k) = plot(s_plot(1,k), T_plot(1,k), markers(k), 'MarkerSize', 8, ...
        'MarkerFaceColor', LineColors(1,:), 'MarkerEdgeColor', LineColors(1,:));
    handle_points(k).DisplayName = ['Cycle Point ' num2str(k)];
end

% Format figure
axis([3 6 273.15 2000])
xlabel('Specific Entropy (kJ/(kg*K))')
ylabel('Temperature (K)')
handle_title = title(sprintf('Temperature-Entropy Diagram (t = %.f s)', 0));
set(gcf,'Name','sscfluids_brayton_cycle_plot1ts')
legend('show', 'Location', 'northwest')
hold off

% Create Play/Pause button for animation.
status = 'paused';
idxPaused = 1;
hButton = uicontrol('Style', 'pushbutton', 'String', 'Pause', ...
    'Units', 'normalized', 'Position', [0.13 0.94, 0.1, 0.05], ...
    'Callback', @(hObject, eventData) playAnimation);

% Play animation
playAnimation


    function playAnimation
        % Nested function to loop through time and set the cycle point data
        try
            if strcmp(status, 'playing')
                status = 'paused';
                set(hButton, 'String', 'Play')
                return
            end
            
            status = 'playing';
            set(hButton, 'String', 'Pause')
            
            % Plot temperature and specific entropy at cycle points.
            for i = idxPaused : length(t_plot)
                if strcmp(status, 'paused')
                    % Save state of the animation.
                    idxPaused = i;
                    return
                end
                set(handle_cycle, 'XData', s_plot(i,:), 'YData', T_plot(i,:))
                for j = 1 : 5
                    set(handle_points(j), 'XData', s_plot(i,j), 'YData', T_plot(i,j))
                end
                set(handle_title, 'String', sprintf('Temperature-Entropy Diagram (t = %.f s)', t_plot(i)))
                drawnow
            end
            
            status = 'paused';
            set(hButton, 'String', 'Play')
            idxPaused = 1;
            
        catch ME
            % End gracefully if user closed figure during the animation.
            if ~strcmp(ME.identifier, 'MATLAB:class:InvalidHandle')
                rethrow(ME)
            end
        end
    end


end