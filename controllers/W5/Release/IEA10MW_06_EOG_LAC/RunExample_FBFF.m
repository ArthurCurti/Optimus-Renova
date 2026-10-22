
clearvars;
close all;
clc;

ExeFile = '..\OpenFAST\openfast_x64_v4.exe';
ModelFolder = '..\IEA10-198-RWT_LAC';
ModelFile = 'IEA-10.0-198-RWT_EOG_FBFF.fst';

CurrentFolder = pwd;
cd(ModelFolder);

[status,result] = system(['"', ExeFile, '" "', ModelFile, '"']);

cd(CurrentFolder);

disp(result)
disp(['OpenFAST status = ', num2str(status)])
% % Script to run DLC 1.2 for "FeedbackOnly".
% 
% % setup
% clearvars;close all;clc;
% addpath(genpath('..\WetiMatlabFunctions'))
% 
% % get configuration for DLC 1.2
% SimulationMode              = 'FeedbackOnly';
% [PostProcessingConfig,PreProcessingVariation,InputFiles,Modifications] = GetParametersForDLC1p2(SimulationMode);
% 
% % generate simulation folder and copy all files from OpenFAST and TemplateFolder to SimulationFolder
% ExeFile                     = 'openfast_x64_v4.exe';
% SimulationFolder            = ['SimulationResults_',SimulationMode];
% TemplateFolder              = '../IEA10-198-RWT';
% if ~exist(SimulationFolder,'dir')
%     mkdir(SimulationFolder)
% end
% copyfile(TemplateFolder,SimulationFolder)
% copyfile(['..\OpenFAST\',ExeFile],fullfile(SimulationFolder,ExeFile))
% 
% % get SimulationNames and DataFiles
% [SimulationNames,DataFiles] = PreProcessingSimulations(SimulationFolder,PreProcessingVariation,InputFiles,Modifications);
% 
% % run simulations
% [status,result]             = ProcessingSimulations(SimulationFolder,SimulationNames,ExeFile);
% 
% % TimeResults
% TimeResults                 = CollectTimeResults(DataFiles,PostProcessingConfig);
% PlotTimeResults(TimeResults,PostProcessingConfig);
% 
% % Statistics
% Statistics                  = CalculateStatistics(TimeResults,PostProcessingConfig);
% 
% % Evaluate only, if you want to overwrite the results: 
% save(['Statistics_',SimulationMode],'Statistics')