%% Export selected MATLAB model figures and result tables
% Set MATLAB's Current Folder to the repository root before running.
% This script runs Plant_Model.m first, then exports its outputs.

clc;
projectRoot = pwd;
run(fullfile(projectRoot, 'MATLAB', 'Plant_Model.m'));

% Plant_Model.m starts with CLEAR, so recreate folder variables afterwards.
projectRoot = pwd;
resultsFolder = fullfile(projectRoot, 'Results', 'MATLAB_Output', 'Auto_Export');
figuresFolder = fullfile(resultsFolder, 'Figures');
tablesFolder = fullfile(resultsFolder, 'Tables');
if ~exist(figuresFolder, 'dir'); mkdir(figuresFolder); end
if ~exist(tablesFolder, 'dir'); mkdir(tablesFolder); end

% Export all figures created by Plant_Model.m.
figHandles = findall(0, 'Type', 'figure');
if ~isempty(figHandles)
    [~, order] = sort([figHandles.Number]);
    figHandles = figHandles(order);
    for k = 1:numel(figHandles)
        outName = sprintf('MATLAB_Figure_%02d.png', k);
        exportgraphics(figHandles(k), fullfile(figuresFolder, outName), ...
            'Resolution', 300);
    end
end

% Export selected result tables when they exist in the workspace.
if exist('results', 'var'); writetable(results, fullfile(tablesFolder, 'unit_results_matlab.csv')); end
if exist('scenario_results', 'var'); writetable(scenario_results, fullfile(tablesFolder, 'operating_scenarios_matlab.csv')); end
if exist('perf_summary', 'var'); writetable(perf_summary, fullfile(tablesFolder, 'performance_summary_matlab.csv')); end
if exist('perf_unit_table', 'var'); writetable(perf_unit_table, fullfile(tablesFolder, 'unit_performance_matlab.csv')); end
if exist('perf_daily_summary', 'var'); writetable(perf_daily_summary, fullfile(tablesFolder, 'daily_performance_matlab.csv')); end
if exist('perf_hourly_table', 'var'); writetable(perf_hourly_table, fullfile(tablesFolder, 'hourly_operation_matlab.csv')); end
if exist('protection_results', 'var'); writetable(protection_results, fullfile(tablesFolder, 'protection_results_matlab.csv')); end
if exist('stage12_results', 'var'); writetable(stage12_results, fullfile(tablesFolder, 'integrated_scenarios_matlab.csv')); end

fprintf('\nExport completed. Figures: %d\n', numel(figHandles));
fprintf('Output folder: %s\n', resultsFolder);
