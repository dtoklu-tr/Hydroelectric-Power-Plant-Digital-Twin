
%% HYDROELECTRIC POWER PLANT DIGITAL TWIN
% Reference: Kavşak Bendi HEPP

clc;
clear;
close all;

%% 1. Physical Constants

rho = 1000;       % Water density (kg/m3)
g = 9.81;         % Gravitational acceleration (m/s2)

%% 2. Hydraulic Parameters

gross_head = 100;       
hydraulic_losses = 5;  
net_head = gross_head - hydraulic_losses;

%% 3. Efficiency Parameters

turbine_efficiency = 0.90;
generator_efficiency = 0.96;

total_efficiency = turbine_efficiency * generator_efficiency;

%% 4. Installed Power

main_unit_power = 61.95;      
ecological_unit_power = 5.43;

number_of_main_units = 3;

total_installed_power = ...
    number_of_main_units * main_unit_power ...
    + ecological_unit_power;

%% 5. Flow Rate Calculations

main_flow = (main_unit_power * 1e6) / ...
    (rho * g * net_head * total_efficiency);

ecological_flow = (ecological_unit_power * 1e6) / ...
    (rho * g * net_head * total_efficiency);

total_flow = number_of_main_units * main_flow ...
    + ecological_flow;

%% 6. Power Calculations

unit_names = ["Main Unit 1";
              "Main Unit 2";
              "Main Unit 3";
              "Ecological Unit"];

flows = [main_flow;
         main_flow;
         main_flow;
         ecological_flow];

power_limits = [main_unit_power;
                main_unit_power;
                main_unit_power;
                ecological_unit_power];

hydraulic_power = rho * g .* flows * net_head / 1e6;

mechanical_power = hydraulic_power * turbine_efficiency;

electrical_power = mechanical_power * generator_efficiency;

%% 7. Results Table

results = table( ...
    unit_names, flows, hydraulic_power, ...
    mechanical_power, electrical_power, power_limits, ...
    'VariableNames', {'Unit', 'Flow_m3_s', ...
    'HydraulicPower_MW', 'MechanicalPower_MW', ...
    'ElectricalPower_MW', 'InstalledPower_MW'});

disp('KAVSAK BENDI HEPP - DIGITAL TWIN')
disp('--------------------------------')
disp(results)

%% 8. Total Power

total_electrical_power = sum(electrical_power);

fprintf('\nTotal Flow: %.2f m3/s\n', total_flow);
fprintf('Total Electrical Power: %.2f MW\n', ...
    total_electrical_power);
fprintf('Installed Capacity: %.2f MW\n', ...
    total_installed_power);
fprintf('Total Efficiency: %.1f %%\n', ...
    total_efficiency * 100);

%% 9. GRAPHICAL ANALYSIS

% Figure 1: Electrical Power by Turbine
figure;

bar(electrical_power);

title('Electrical Power Generation by Turbine');
xlabel('Turbine Unit');
ylabel('Electrical Power (MW)');

xticklabels(unit_names);
xtickangle(20);
grid on;


% Figure 2: Flow Rate by Turbine
figure;

bar(flows);

title('Water Flow Rate by Turbine');
xlabel('Turbine Unit');
ylabel('Flow Rate (m^3/s)');

xticklabels(unit_names);
xtickangle(20);
grid on;


% Figure 3: Contribution to Total Power Generation
figure;

pie(electrical_power, unit_names);

title('Contribution of Turbine Units to Total Power');


% Figure 4: Flow Rate vs Electrical Power
figure;

flow_range = linspace(0, main_flow, 100);

power_range = rho * g .* flow_range ...
    * net_head * total_efficiency / 1e6;

plot(flow_range, power_range, 'LineWidth', 2);

hold on;

yline(main_unit_power, '--r', 'Installed Power Limit');

title('Flow Rate vs Electrical Power - Francis Turbine');
xlabel('Flow Rate (m^3/s)');
ylabel('Electrical Power (MW)');

grid on;
hold off;

%% 10. PARAMETRIC ANALYSIS - FLOW RATE

% Flow rate range
flow_range_total = linspace(0, total_flow * 1.2, 100);

% Theoretical electrical power
power_flow = rho * g .* flow_range_total ...
    * net_head * total_efficiency / 1e6;

% Limit power to installed capacity
power_flow_limited = min(power_flow, total_installed_power);

% Plot
figure;

plot(flow_range_total, power_flow_limited, ...
    'LineWidth', 2);

hold on;

xline(total_flow, '--r', 'Design Flow');
yline(total_installed_power, '--k', 'Installed Capacity');

title('Effect of Flow Rate on Plant Power');
xlabel('Total Flow Rate (m^3/s)');
ylabel('Electrical Power (MW)');

grid on;
hold off;
%% 11. PARAMETRIC ANALYSIS - NET HEAD

% Net head range
head_range = linspace(70, 110, 100);

% Theoretical electrical power
power_head = rho * g * total_flow ...
    .* head_range * total_efficiency / 1e6;

% Limit power to installed capacity
power_head_limited = min(power_head, total_installed_power);

% Plot
figure;

plot(head_range, power_head_limited, ...
    'LineWidth', 2);

hold on;

xline(net_head, '--r', 'Reference Net Head');
yline(total_installed_power, '--k', 'Installed Capacity');

title('Effect of Net Head on Plant Power');
xlabel('Net Head (m)');
ylabel('Electrical Power (MW)');

grid on;
hold off;

%% 12. OPERATING SCENARIO COMPARISON

scenario_names = ["Low Head"; "Reference"; "High Head"];

scenario_heads = [80; 95; 105];

scenario_flows = [total_flow; total_flow; total_flow];

scenario_power = rho * g .* scenario_flows ...
    .* scenario_heads * total_efficiency / 1e6;

% Apply installed capacity limit
scenario_power = min(scenario_power, total_installed_power);

scenario_results = table( ...
    scenario_names, ...
    scenario_heads, ...
    scenario_flows, ...
    scenario_power, ...
    'VariableNames', ...
    {'Scenario', 'NetHead_m', 'Flow_m3_s', 'Power_MW'});

disp('OPERATING SCENARIO COMPARISON')
disp(scenario_results)

% Scenario comparison chart
figure;

bar(scenario_power);

title('Power Generation Under Different Operating Scenarios');
xlabel('Operating Scenario');
ylabel('Electrical Power (MW)');

xticklabels(scenario_names);
grid on;

%% 13. RESERVOIR WATER BALANCE MODEL

% Assumed reservoir parameters
initial_volume = 50e6;       % m3
reservoir_area = 5e6;        % m2
initial_level = 100;         % Reference elevation (m)

% Simulation settings
simulation_hours = 24;
dt = 3600;                   % 1 hour in seconds

time = 0:dt:simulation_hours*dt;
number_of_steps = length(time);

% Initialize variables
reservoir_volume = zeros(1, number_of_steps);
reservoir_level = zeros(1, number_of_steps);
inflow = zeros(1, number_of_steps);
outflow = zeros(1, number_of_steps);
net_head_dynamic = zeros(1, number_of_steps);
power_dynamic = zeros(1, number_of_steps);

% Initial conditions
reservoir_volume(1) = initial_volume;
reservoir_level(1) = initial_level;

% Simulation loop
for k = 1:number_of_steps

    % Variable reservoir inflow
    inflow(k) = 180 + 20*sin(2*pi*(k-1)/24);

    % Constant turbine discharge
    outflow(k) = total_flow;

    % Calculate net head based on reservoir level
    net_head_dynamic(k) = net_head + ...
        (reservoir_level(k) - initial_level);

    % Calculate electrical power
    power_dynamic(k) = rho*g*outflow(k) ...
        * net_head_dynamic(k)*total_efficiency/1e6;

    % Apply installed capacity limit
    power_dynamic(k) = min(power_dynamic(k), ...
        total_installed_power);

    % Update reservoir volume and level
    if k < number_of_steps

        reservoir_volume(k+1) = reservoir_volume(k) ...
            + (inflow(k)-outflow(k))*dt;

        % Prevent negative reservoir volume
        reservoir_volume(k+1) = max( ...
            reservoir_volume(k+1), 0);

        reservoir_level(k+1) = initial_level ...
            + (reservoir_volume(k+1)-initial_volume) ...
            / reservoir_area;

    end
end

%% 14. RESERVOIR RESULTS

fprintf('\nRESERVOIR SIMULATION RESULTS\n');
fprintf('Initial Volume: %.2f million m3\n', ...
    reservoir_volume(1)/1e6);

fprintf('Final Volume: %.2f million m3\n', ...
    reservoir_volume(end)/1e6);

fprintf('Initial Level: %.2f m\n', ...
    reservoir_level(1));

fprintf('Final Level: %.2f m\n', ...
    reservoir_level(end));

fprintf('Initial Net Head: %.2f m\n', ...
    net_head_dynamic(1));

fprintf('Final Net Head: %.2f m\n', ...
    net_head_dynamic(end));

fprintf('Initial Power: %.2f MW\n', ...
    power_dynamic(1));

fprintf('Final Power: %.2f MW\n', ...
    power_dynamic(end));

%% 15. RESERVOIR DYNAMIC GRAPHS

time_hours = time/3600;

% Figure 1: Reservoir Volume
figure;

plot(time_hours, reservoir_volume/1e6, ...
    'LineWidth', 2);

title('Reservoir Volume Over Time');
xlabel('Time (hours)');
ylabel('Reservoir Volume (million m^3)');
grid on;


% Figure 2: Reservoir Water Level
figure;

plot(time_hours, reservoir_level, ...
    'LineWidth', 2);

title('Reservoir Water Level Over Time');
xlabel('Time (hours)');
ylabel('Reservoir Level (m)');
grid on;


% Figure 3: Dynamic Power Generation
figure;

plot(time_hours, power_dynamic, ...
    'LineWidth', 2);

title('Power Generation Over Time');
xlabel('Time (hours)');
ylabel('Electrical Power (MW)');
grid on;

%% 16. TURBINE OPERATING STATUS MODEL

% Time intervals: 24 hours
hours = 0:23;

% Turbine operating status
% 1 = ON, 0 = OFF

% Columns:
% 1 = Francis 1
% 2 = Francis 2
% 3 = Francis 3
% 4 = Ecological turbine

turbine_status = ones(24,4);

% Hours 06-11: Francis 3 is OFF
turbine_status(7:12,3) = 0;

% Hours 18-23: Francis 2 is OFF
turbine_status(19:24,2) = 0;

% Turbine design flow rates
turbine_flows = [main_flow;
                 main_flow;
                 main_flow;
                 ecological_flow];

% Turbine installed powers
turbine_power_limits = [main_unit_power;
                        main_unit_power;
                        main_unit_power;
                        ecological_unit_power];

%% 17. HOURLY POWER AND FLOW CALCULATIONS

hourly_total_flow = zeros(24,1);
hourly_total_power = zeros(24,1);

hourly_unit_power = zeros(24,4);

for k = 1:24

    for j = 1:4

        if turbine_status(k,j) == 1

            hourly_unit_power(k,j) = ...
                turbine_power_limits(j);

        else

            hourly_unit_power(k,j) = 0;

        end

    end

    hourly_total_flow(k) = ...
        sum(turbine_status(k,:) .* turbine_flows');

    hourly_total_power(k) = ...
        sum(hourly_unit_power(k,:));

end

% Calculate daily energy production
daily_energy = sum(hourly_total_power);

%% 18. RESULTS TABLE

operating_results = table( ...
    hours', ...
    turbine_status(:,1), ...
    turbine_status(:,2), ...
    turbine_status(:,3), ...
    turbine_status(:,4), ...
    hourly_total_flow, ...
    hourly_total_power, ...
    'VariableNames', ...
    {'Hour','Francis_1','Francis_2', ...
    'Francis_3','Ecological', ...
    'TotalFlow_m3_s','TotalPower_MW'});

disp('TURBINE OPERATING RESULTS')
disp(operating_results)

fprintf('\nDaily Energy Production: %.2f MWh\n', ...
    daily_energy);

%% 19. TURBINE OPERATING GRAPHS

% Figure 1: Total Power Generation
figure;

stairs(hours, hourly_total_power, 'LineWidth', 2);

title('Hourly Power Generation');
xlabel('Time (hours)');
ylabel('Total Power (MW)');

xlim([0 23]);
grid on;


% Figure 2: Total Turbine Flow
figure;

stairs(hours, hourly_total_flow, 'LineWidth', 2);

title('Hourly Turbine Flow Rate');
xlabel('Time (hours)');
ylabel('Total Flow Rate (m^3/s)');

xlim([0 23]);
grid on;


% Figure 3: Turbine Operating Status
figure;

imagesc(hours, 1:4, turbine_status');

colorbar;
clim([0 1]);

yticks(1:4);
yticklabels({'Francis 1','Francis 2', ...
    'Francis 3','Ecological Turbine'});

xlabel('Time (hours)');
ylabel('Turbine Unit');
title('Turbine Operating Status');

%% 20. FRANCIS TURBINE EFFICIENCY MODEL

% Illustrative turbine efficiency curve
% These are assumed values, not manufacturer data.

flow_percent = [0 40 50 60 70 80 90 100 110];

efficiency_percent = [0 72 78 83 87 89 90 90 88];

% Convert percentage values to decimal
efficiency_curve = efficiency_percent / 100;

% Generate flow operating points
flow_ratio = linspace(0, 1.10, 100);

% Calculate turbine flow values
flow_values = flow_ratio * main_flow;

% Interpolate turbine efficiency
turbine_efficiency_curve = interp1( ...
    flow_percent/100, ...
    efficiency_curve, ...
    flow_ratio, ...
    'linear');

% Calculate electrical power
power_curve = rho * g .* flow_values ...
    * net_head .* turbine_efficiency_curve ...
    * generator_efficiency / 1e6;

% Apply installed power limit
power_curve = min(power_curve, main_unit_power);

%% 21. EFFICIENCY CURVE GRAPH

figure;

plot(flow_ratio*100, turbine_efficiency_curve*100, ...
    'LineWidth', 2);

title('Francis Turbine Efficiency Curve');
xlabel('Flow Rate (% of Design Flow)');
ylabel('Turbine Efficiency (%)');

grid on;
xlim([0 110]);
ylim([0 100]);

%% 22. POWER CURVE GRAPH

figure;

plot(flow_ratio*100, power_curve, ...
    'LineWidth', 2);

hold on;

yline(main_unit_power, '--r', ...
    'Installed Power Limit');

title('Francis Turbine Power vs Flow Rate');
xlabel('Flow Rate (% of Design Flow)');
ylabel('Electrical Power (MW)');

grid on;
hold off;

%% 23. SELECTED OPERATING POINTS

selected_percent = [40; 60; 80; 100; 110];

selected_efficiency = interp1( ...
    flow_percent, efficiency_percent, ...
    selected_percent);

selected_flow = main_flow * selected_percent / 100;

selected_power = rho * g .* selected_flow ...
    * net_head .* (selected_efficiency/100) ...
    * generator_efficiency / 1e6;

selected_power = min(selected_power, main_unit_power);

efficiency_results = table( ...
    selected_percent, ...
    selected_flow, ...
    selected_efficiency, ...
    selected_power, ...
    'VariableNames', ...
    {'Flow_Percent','Flow_m3_s', ...
    'Turbine_Efficiency_Percent','Electrical_Power_MW'});

disp('FRANCIS TURBINE EFFICIENCY ANALYSIS')
disp(efficiency_results)

%% 24. GENERATOR MODEL

% Assumed generator parameters
generator_efficiency_model = 0.96;
power_factor = 0.90;
generator_voltage = 13.8;  % kV - reference assumption
grid_frequency = 50;       % Hz

% Mechanical power entering each generator
mechanical_power_generator = mechanical_power;

% Electrical active power
generator_active_power = ...
    mechanical_power_generator * generator_efficiency_model;

% Apparent power
generator_apparent_power = ...
    generator_active_power / power_factor;

% Reactive power
generator_reactive_power = sqrt( ...
    generator_apparent_power.^2 ...
    - generator_active_power.^2);

% Three-phase line current
generator_current = ...
    generator_apparent_power * 1e6 ...
    ./ (sqrt(3) * generator_voltage * 1e3);

%% 25. GENERATOR RESULTS TABLE

generator_results = table( ...
    unit_names, ...
    mechanical_power_generator, ...
    generator_active_power, ...
    generator_apparent_power, ...
    generator_reactive_power, ...
    generator_current, ...
    'VariableNames', ...
    {'Generator','MechanicalPower_MW', ...
    'ActivePower_MW','ApparentPower_MVA', ...
    'ReactivePower_MVAr','LineCurrent_A'});

disp('GENERATOR ELECTRICAL ANALYSIS')
disp(generator_results)

fprintf('\nTotal Active Power: %.2f MW\n', ...
    sum(generator_active_power));

fprintf('Total Apparent Power: %.2f MVA\n', ...
    sum(generator_apparent_power));

fprintf('Grid Frequency Reference: %.1f Hz\n', ...
    grid_frequency);

%% 26. GENERATOR GRAPHS

% Figure 1: Active Power
figure;

bar(generator_active_power);

title('Generator Active Power');
xlabel('Generator Unit');
ylabel('Active Power (MW)');

xticklabels(unit_names);
xtickangle(20);
grid on;


% Figure 2: Apparent Power
figure;

bar(generator_apparent_power);

title('Generator Apparent Power');
xlabel('Generator Unit');
ylabel('Apparent Power (MVA)');

xticklabels(unit_names);
xtickangle(20);
grid on;


% Figure 3: Generator Current
figure;

bar(generator_current);

title('Three-Phase Generator Line Current');
xlabel('Generator Unit');
ylabel('Line Current (A)');

xticklabels(unit_names);
xtickangle(20);
grid on;


% Figure 4: Active and Reactive Power
figure;

bar([generator_active_power, generator_reactive_power]);

title('Generator Active and Reactive Power');
xlabel('Generator Unit');
ylabel('Power');

xticklabels(unit_names);
xtickangle(20);

legend('Active Power (MW)', 'Reactive Power (MVAr)');
grid on;

%% 27. TRANSFORMER MODEL

% Reference transformer parameters
transformer_LV = 13.8;       % kV
transformer_HV = 154;        % kV

transformer_ONAN = 80;       % MVA
transformer_ONAF = 100;      % MVA

transformer_loss_percent = 0.5; % Assumed loss (%)

% Select the first main generator
selected_generator = 1;

transformer_input_power = ...
    generator_active_power(selected_generator);

transformer_apparent_power = ...
    generator_apparent_power(selected_generator);

% Voltage transformation ratio
voltage_ratio = transformer_HV / transformer_LV;

% Transformer output power
transformer_losses = ...
    transformer_input_power * transformer_loss_percent / 100;

transformer_output_power = ...
    transformer_input_power - transformer_losses;

% Transformer loading
loading_ONAN = ...
    transformer_apparent_power / transformer_ONAN * 100;

loading_ONAF = ...
    transformer_apparent_power / transformer_ONAF * 100;

% Three-phase currents
LV_current = transformer_apparent_power * 1e6 / ...
    (sqrt(3) * transformer_LV * 1e3);

HV_current = transformer_apparent_power * 1e6 / ...
    (sqrt(3) * transformer_HV * 1e3);

%% 28. TRANSFORMER RESULTS

fprintf('\nTRANSFORMER ANALYSIS\n');
fprintf('Voltage Ratio: %.3f\n', voltage_ratio);
fprintf('Input Active Power: %.2f MW\n', ...
    transformer_input_power);
fprintf('Output Active Power: %.2f MW\n', ...
    transformer_output_power);
fprintf('Transformer Losses: %.3f MW\n', ...
    transformer_losses);
fprintf('Apparent Power: %.2f MVA\n', ...
    transformer_apparent_power);
fprintf('LV Current: %.2f A\n', LV_current);
fprintf('HV Current: %.2f A\n', HV_current);
fprintf('ONAN Loading: %.2f %%\n', loading_ONAN);
fprintf('ONAF Loading: %.2f %%\n', loading_ONAF);

%% 29. TRANSFORMER LOADING CHECK

if transformer_apparent_power <= transformer_ONAN

    disp('Transformer loading is within ONAN rating.');

elseif transformer_apparent_power <= transformer_ONAF

    disp('Transformer requires ONAF cooling operation.');

else

    disp('WARNING: Transformer capacity is exceeded.');

end

%% 30. TRANSFORMER RESULTS TABLE

transformer_results = table( ...
    transformer_input_power, ...
    transformer_output_power, ...
    transformer_apparent_power, ...
    LV_current, ...
    HV_current, ...
    loading_ONAN, ...
    loading_ONAF, ...
    'VariableNames', ...
    {'InputPower_MW','OutputPower_MW', ...
    'ApparentPower_MVA','LV_Current_A', ...
    'HV_Current_A','ONAN_Loading_Percent', ...
    'ONAF_Loading_Percent'});

disp(transformer_results)

%% 31. TRANSFORMER GRAPHS

% Figure 1: Voltage Transformation
figure;

bar([transformer_LV, transformer_HV]);

title('Transformer Voltage Levels');
ylabel('Voltage (kV)');
xticklabels({'Low Voltage','High Voltage'});
grid on;


% Figure 2: Transformer Current
figure;

bar([LV_current, HV_current]);

title('Transformer Current Comparison');
ylabel('Line Current (A)');
xticklabels({'Low Voltage Side','High Voltage Side'});
grid on;


% Figure 3: Transformer Loading
figure;

bar([loading_ONAN, loading_ONAF]);

title('Transformer Loading Comparison');
ylabel('Loading (%)');
xticklabels({'ONAN','ONAF'});
yline(100,'--r','Rated Capacity');
grid on;

%% 32. GRID CONNECTION MODEL

% Grid reference parameters
grid_voltage = 154;       % kV
grid_frequency = 50;      % Hz

% Transformer output active power
grid_active_power = transformer_output_power;

% Assume reactive power remains unchanged
grid_reactive_power = ...
    generator_reactive_power(selected_generator);

% Grid apparent power
grid_apparent_power = sqrt( ...
    grid_active_power^2 + grid_reactive_power^2);

% Grid power factor
grid_power_factor = ...
    grid_active_power / grid_apparent_power;

% High voltage side current
grid_current = grid_apparent_power * 1e6 / ...
    (sqrt(3) * grid_voltage * 1e3);

% Power transfer efficiency
grid_transfer_efficiency = ...
    grid_active_power / transformer_input_power * 100;

%% 33. GRID CONNECTION RESULTS

fprintf('\nGRID CONNECTION ANALYSIS\n');

fprintf('Grid Voltage: %.2f kV\n', grid_voltage);
fprintf('Grid Frequency: %.2f Hz\n', grid_frequency);

fprintf('Active Power to Grid: %.2f MW\n', ...
    grid_active_power);

fprintf('Reactive Power to Grid: %.2f MVAr\n', ...
    grid_reactive_power);

fprintf('Apparent Power to Grid: %.2f MVA\n', ...
    grid_apparent_power);

fprintf('Grid Power Factor: %.3f\n', ...
    grid_power_factor);

fprintf('Grid Current: %.2f A\n', grid_current);

fprintf('Transfer Efficiency: %.2f %%\n', ...
    grid_transfer_efficiency);

%% 34. GRID CONNECTION RESULTS TABLE

grid_results = table( ...
    grid_voltage, ...
    grid_frequency, ...
    grid_active_power, ...
    grid_reactive_power, ...
    grid_apparent_power, ...
    grid_power_factor, ...
    grid_current, ...
    'VariableNames', ...
    {'GridVoltage_kV','Frequency_Hz', ...
    'ActivePower_MW','ReactivePower_MVAr', ...
    'ApparentPower_MVA','PowerFactor', ...
    'LineCurrent_A'});

disp('GRID CONNECTION RESULTS')
disp(grid_results)

%% 35. GRID CONNECTION GRAPHS

% Figure 1: Voltage Levels
figure;

bar([transformer_LV, transformer_HV]);

title('Generator and Grid Voltage Levels');
ylabel('Voltage (kV)');
xticklabels({'Generator Side','Grid Side'});
grid on;


% Figure 2: Power Flow
figure;

bar([transformer_input_power, ...
     transformer_output_power]);

title('Active Power Transfer');
ylabel('Active Power (MW)');
xticklabels({'Transformer Input','Grid Output'});
grid on;


% Figure 3: Grid Power Components
figure;

bar([grid_active_power, grid_reactive_power]);

title('Power Components at Grid Connection');
ylabel('Power');
xticklabels({'Active Power (MW)','Reactive Power (MVAr)'});
grid on;

%% 36. PROTECTION AND FAULT SIMULATION

% Reference protection limits (illustrative)
voltage_min = 0.90;       % pu
voltage_max = 1.10;       % pu

frequency_min = 49;       % Hz
frequency_max = 51;       % Hz

% Transformer ONAN current limit
transformer_current_limit = ...
    transformer_ONAN * 1e6 / ...
    (sqrt(3) * transformer_HV * 1e3);

% Define operating scenarios
scenario_names = [
    "Normal Operation"
    "Overcurrent"
    "Undervoltage"
    "Underfrequency"
    "Transformer Overload"
];

voltage_pu = [1.00; 1.00; 0.85; 1.00; 1.00];

frequency = [50; 50; 50; 48.5; 50];

apparent_power = [
    transformer_apparent_power
    90
    transformer_apparent_power
    transformer_apparent_power
    85
];

% Calculate high-voltage side current
scenario_current = apparent_power * 1e6 ./ ...
    (sqrt(3) * transformer_HV * 1e3);

% Protection checks
overcurrent = scenario_current > ...
    transformer_current_limit;

undervoltage = voltage_pu < voltage_min;

overvoltage = voltage_pu > voltage_max;

underfrequency = frequency < frequency_min;

overfrequency = frequency > frequency_max;

transformer_overload = ...
    apparent_power > transformer_ONAN;

% Overall protection status
protection_trip = ...
    overcurrent | undervoltage | overvoltage | ...
    underfrequency | overfrequency | transformer_overload;

% Scenario status
protection_status = strings(length(scenario_names),1);

for k = 1:length(scenario_names)

    if protection_trip(k)
        protection_status(k) = "TRIP";
    else
        protection_status(k) = "NORMAL";
    end

end

%% 37. PROTECTION RESULTS TABLE

protection_results = table( ...
    scenario_names, ...
    voltage_pu, ...
    frequency, ...
    apparent_power, ...
    scenario_current, ...
    overcurrent, ...
    undervoltage, ...
    underfrequency, ...
    transformer_overload, ...
    protection_status, ...
    'VariableNames', ...
    {'Scenario','Voltage_pu','Frequency_Hz', ...
    'ApparentPower_MVA','Current_A', ...
    'Overcurrent','Undervoltage', ...
    'Underfrequency','TransformerOverload', ...
    'ProtectionStatus'});

disp('PROTECTION SYSTEM ANALYSIS')
disp(protection_results)

%% 38. PROTECTION STATUS GRAPH

figure;

imagesc(protection_trip');

colormap([0.2 0.7 0.3; 0.9 0.2 0.2]);

colorbar;
clim([0 1]);

yticks(1);
yticklabels({'Protection Status'});

xticks(1:length(scenario_names));
xticklabels(scenario_names);
xtickangle(25);

title('Protection Response Under Different Scenarios');
grid on;


%% 39. CURRENT LIMIT ANALYSIS

figure;

bar(scenario_current);

hold on;

yline(transformer_current_limit, '--r', ...
    'ONAN Current Limit');

title('Transformer High Voltage Side Current');
xlabel('Operating Scenario');
ylabel('Current (A)');

xticks(1:length(scenario_names));
xticklabels(scenario_names);
xtickangle(25);

grid on;
hold off;

%% 11. GENERAL HPP PERFORMANCE ANALYSIS

% Plant reference parameters
perf_rho = 1000;                 % Water density (kg/m3)
perf_g = 9.81;                   % Gravitational acceleration (m/s2)

perf_gross_head = 100;           % Gross head (m)
perf_losses = 5;                 % Hydraulic losses (m)
perf_net_head = perf_gross_head - perf_losses;

perf_eta_turbine = 0.90;
perf_eta_generator = 0.96;
perf_eta_total = perf_eta_turbine * perf_eta_generator;

% Installed electrical power
perf_unit_power = [61.95; 61.95; 61.95; 5.43]; % MW
perf_unit_names = ["Francis 1"; "Francis 2"; ...
                   "Francis 3"; "Ecological Unit"];

perf_total_installed = sum(perf_unit_power);

% Calculate nominal flow rates
perf_unit_flow = (perf_unit_power * 1e6) ./ ...
    (perf_rho * perf_g * perf_net_head * perf_eta_total);

perf_total_flow = sum(perf_unit_flow);

% Hydraulic and mechanical power
perf_hydraulic_power = perf_rho * perf_g * ...
    perf_total_flow * perf_net_head / 1e6;

perf_mechanical_power = perf_hydraulic_power * perf_eta_turbine;

% Electrical output
perf_electrical_power = perf_mechanical_power * ...
    perf_eta_generator;

% Plant efficiency
perf_calculated_efficiency = ...
    perf_electrical_power / perf_hydraulic_power * 100;

% Installed capacity utilization
perf_capacity_utilization = ...
    perf_electrical_power / perf_total_installed * 100;

%% Nominal Performance Summary

perf_summary = table( ...
    perf_total_installed, ...
    perf_total_flow, ...
    perf_net_head, ...
    perf_hydraulic_power, ...
    perf_mechanical_power, ...
    perf_electrical_power, ...
    perf_calculated_efficiency, ...
    perf_capacity_utilization, ...
    'VariableNames', { ...
    'InstalledPower_MW', ...
    'TotalFlow_m3s', ...
    'NetHead_m', ...
    'HydraulicPower_MW', ...
    'MechanicalPower_MW', ...
    'ElectricalPower_MW', ...
    'TotalEfficiency_percent', ...
    'CapacityUtilization_percent'});

disp('GENERAL HPP PERFORMANCE SUMMARY');
disp(perf_summary);

%% Unit Performance Table

perf_unit_table = table( ...
    perf_unit_names, ...
    perf_unit_power, ...
    perf_unit_flow, ...
    'VariableNames', ...
    {'Unit', 'InstalledPower_MW', 'FlowRate_m3s'});

disp('INDIVIDUAL UNIT PERFORMANCE');
disp(perf_unit_table);

%% 24-Hour Operating Schedule

perf_hours = (0:23)';

% Each column represents one generating unit
perf_schedule = ones(24,4);

% Francis Unit 3 is OFF between 06:00 and 11:00
perf_schedule(7:12,3) = 0;

% Francis Unit 2 is OFF between 18:00 and 23:00
perf_schedule(19:24,2) = 0;

% Hourly electrical power
perf_hourly_power = perf_schedule * perf_unit_power;

% Hourly total flow
perf_hourly_flow = perf_schedule * perf_unit_flow;

% Hourly energy (1-hour intervals)
perf_hourly_energy = perf_hourly_power;

% Daily energy production
perf_daily_energy = sum(perf_hourly_energy);

% Average daily power
perf_average_power = mean(perf_hourly_power);

% Daily capacity factor
perf_daily_capacity_factor = ...
    perf_daily_energy / (perf_total_installed * 24) * 100;

%% Daily Performance Summary

perf_daily_summary = table( ...
    perf_daily_energy, ...
    perf_average_power, ...
    perf_daily_capacity_factor, ...
    'VariableNames', { ...
    'DailyEnergy_MWh', ...
    'AveragePower_MW', ...
    'DailyCapacityFactor_percent'});

disp('DAILY PERFORMANCE SUMMARY');
disp(perf_daily_summary);

%% Hourly Operating Table

perf_hourly_table = table( ...
    perf_hours, ...
    perf_hourly_flow, ...
    perf_hourly_power, ...
    'VariableNames', ...
    {'Hour', 'TotalFlow_m3s', 'ElectricalPower_MW'});

disp('24-HOUR OPERATING RESULTS');
disp(perf_hourly_table);

%% Graph 1 - Hourly Electrical Power

figure;
plot(perf_hours, perf_hourly_power, '-o', ...
    'LineWidth', 1.5);

xlabel('Time (hour)');
ylabel('Electrical Power (MW)');
title('HPP - 24 Hour Electrical Power');
grid on;

%% Graph 2 - Hourly Total Flow

figure;
plot(perf_hours, perf_hourly_flow, '-s', ...
    'LineWidth', 1.5);

xlabel('Time (hour)');
ylabel('Total Flow Rate (m3/s)');
title('HPP - 24 Hour Total Flow');
grid on;

%% Graph 3 - Installed Power Distribution

figure;
pie(perf_unit_power, perf_unit_names);

title('Installed Power Distribution by Unit');
%% STAGE 11 - HPP OPERATING POINTS AND PERFORMANCE ANALYSIS

% Reference HPP parameters
stage11_installed_power = 191.28; % MW
stage11_reference_flow = 237.55; % m3/s
stage11_net_head = 95; % m
stage11_total_efficiency = 0.864;

% Operating load scenarios
stage11_load_percent = [50; 75; 100];

% Calculate operating conditions
stage11_load_factor = stage11_load_percent / 100;

stage11_power = stage11_installed_power .* stage11_load_factor;

stage11_flow = stage11_reference_flow .* stage11_load_factor;

stage11_daily_energy = stage11_power .* 24;

stage11_capacity_utilization = ...
    (stage11_power ./ stage11_installed_power) .* 100;

% Create performance table
stage11_results = table( ...
    stage11_load_percent, ...
    stage11_flow, ...
    stage11_power, ...
    stage11_daily_energy, ...
    stage11_capacity_utilization, ...
    'VariableNames', { ...
    'LoadPercent', ...
    'FlowRate_m3s', ...
    'Power_MW', ...
    'DailyEnergy_MWh', ...
    'CapacityUtilization_percent'});

disp('STAGE 11 - HPP OPERATING POINT ANALYSIS')
disp(stage11_results)

% Figure 1 - Load percentage versus power
figure;

plot(stage11_load_percent, stage11_power, ...
    '-o', 'LineWidth', 2, 'MarkerSize', 8);

xlabel('Operating Load (%)');
ylabel('Electrical Power (MW)');
title('Operating Load vs Electrical Power');
grid on;

% Figure 2 - Load percentage versus flow
figure;

plot(stage11_load_percent, stage11_flow, ...
    '-s', 'LineWidth', 2, 'MarkerSize', 8);

xlabel('Operating Load (%)');
ylabel('Flow Rate (m^3/s)');
title('Operating Load vs Total Flow Rate');
grid on;

% Figure 3 - Daily energy production
figure;

bar(stage11_load_percent, stage11_daily_energy);

xlabel('Operating Load (%)');
ylabel('Daily Energy (MWh)');
title('Daily Energy Production at Different Load Levels');
grid on;

% Figure 4 - Power and capacity comparison
figure;

bar(stage11_load_percent, ...
    [stage11_power, ...
    stage11_capacity_utilization]);

xlabel('Operating Load (%)');
ylabel('Value');
title('Power and Capacity Utilization Comparison');

legend('Electrical Power (MW)', ...
    'Capacity Utilization (%)', ...
    'Location', 'northwest');

grid on;

disp('STAGE 11 COMPLETED SUCCESSFULLY')
%% STAGE 12 - INTEGRATED PHYSICAL AND MATHEMATICAL HPP MODEL

% Physical constants
stage12_rho = 1000;       % kg/m3
stage12_g = 9.81;         % m/s2

% Reference plant parameters
stage12_gross_head = 100;             % m
stage12_hydraulic_losses = 5;         % m
stage12_net_head = stage12_gross_head - stage12_hydraulic_losses;

stage12_turbine_efficiency = 0.90;
stage12_generator_efficiency = 0.96;

stage12_total_efficiency = ...
    stage12_turbine_efficiency * stage12_generator_efficiency;

stage12_installed_power = 191.28;     % MW
stage12_reference_flow = 237.55;     % m3/s

% Operating scenarios
stage12_scenario = [
    "Normal Operation"
    "Reduced Flow"
    "Reduced Net Head"
    "Reduced Efficiency"
    "Combined Degradation"
];

stage12_flow = [
    237.55
    190.00
    237.55
    237.55
    190.00
];

stage12_head = [
    95
    95
    85
    95
    85
];

stage12_turbine_eff = [
    0.90
    0.90
    0.90
    0.85
    0.85
];

stage12_generator_eff = [
    0.96
    0.96
    0.96
    0.94
    0.94
];

% Hydraulic power calculation
stage12_hydraulic_power = ...
    (stage12_rho * stage12_g .* stage12_flow .* stage12_head) / 1e6;

% Mechanical power calculation
stage12_mechanical_power = ...
    stage12_hydraulic_power .* stage12_turbine_eff;

% Electrical power before installed capacity limitation
stage12_calculated_power = ...
    stage12_mechanical_power .* stage12_generator_eff;

% Apply installed capacity limit
stage12_electrical_power = min( ...
    stage12_calculated_power, stage12_installed_power);

% Calculate total efficiency
stage12_total_efficiency_percent = ...
    (stage12_electrical_power ./ stage12_hydraulic_power) * 100;

% Calculate power losses
stage12_hydraulic_to_mechanical_loss = ...
    stage12_hydraulic_power - stage12_mechanical_power;

stage12_mechanical_to_electrical_loss = ...
    stage12_mechanical_power - stage12_calculated_power;

% Create results table
stage12_results = table( ...
    stage12_scenario, ...
    stage12_flow, ...
    stage12_head, ...
    stage12_hydraulic_power, ...
    stage12_mechanical_power, ...
    stage12_electrical_power, ...
    stage12_total_efficiency_percent, ...
    'VariableNames', { ...
    'Scenario', ...
    'Flow_m3s', ...
    'NetHead_m', ...
    'HydraulicPower_MW', ...
    'MechanicalPower_MW', ...
    'ElectricalPower_MW', ...
    'TotalEfficiency_percent'});

disp('STAGE 12 - INTEGRATED HPP PHYSICAL MODEL')
disp(stage12_results)

% Figure 1 - Energy conversion
figure;

bar([stage12_hydraulic_power, ...
     stage12_mechanical_power, ...
     stage12_electrical_power]);

xticks(1:length(stage12_scenario));
xticklabels(stage12_scenario);
xtickangle(25);

ylabel('Power (MW)');
title('Hydraulic to Electrical Energy Conversion');
legend('Hydraulic Power', 'Mechanical Power', ...
    'Electrical Power', 'Location', 'best');
grid on;

% Figure 2 - Electrical power comparison
figure;

bar(stage12_electrical_power);

xticks(1:length(stage12_scenario));
xticklabels(stage12_scenario);
xtickangle(25);

ylabel('Electrical Power (MW)');
title('Electrical Power Under Different Operating Conditions');
grid on;

% Figure 3 - Total efficiency comparison
figure;

plot(1:length(stage12_scenario), ...
    stage12_total_efficiency_percent, ...
    '-o', 'LineWidth', 2, 'MarkerSize', 8);

xticks(1:length(stage12_scenario));
xticklabels(stage12_scenario);
xtickangle(25);

ylabel('Total Efficiency (%)');
title('HPP Total Efficiency Comparison');
grid on;

disp('STAGE 12 COMPLETED SUCCESSFULLY')
