% Script to run EOG for "FeedbackOnly".

% setup
clearvars;close all;clc;
addpath(genpath('..\WetiMatlabFunctions'))

%% Paths

% OpenFAST executable
ExeFile = '..\OpenFAST\openfast_x64_v4.exe';

% Folder containing the EOG OpenFAST model
SimulationFolder = '..\IEA10-198-RWT_LAC';

% EOG simulation name
SimulationName = 'IEA-10.0-198-RWT_EOG_FB_2.6';

% Full path to FST file
FSTFile = fullfile(SimulationFolder,[SimulationName,'.fst']);

%% Run EOG FeedbackOnly

CurrentFolder = cd;
cd(SimulationFolder);

[status,result] = system(['"',ExeFile,'" "',SimulationName,'.fst']);

cd(CurrentFolder);

%% Check OpenFAST status

disp(result)

if status ~= 0
    error('OpenFAST did not run successfully.');
end
%% Read EOG results

OutFile = fullfile(SimulationFolder,[SimulationName,'.outb']);

FB = ReadFASTbinaryIntoStruct(OutFile);

%% Plot results

figure('Name','IEA 10 MW EOG - FeedbackOnly')

subplot(4,1,1)
plot(FB.Time,FB.Wind1VelX)
grid on
ylabel('Wind [m/s]')
title('EOG - FeedbackOnly')

subplot(4,1,2)
plot(FB.Time,FB.BldPitch1)
grid on
ylabel('Pitch [deg]')

subplot(4,1,3)
plot(FB.Time,FB.RotSpeed)
grid on
ylabel('Rotor speed [rpm]')

subplot(4,1,4)
plot(FB.Time,FB.TwrBsMyt/1e3)
grid on
ylabel('Tower load [MNm]')
xlabel('Time [s]')

linkaxes(findobj(gcf,'Type','Axes'),'x')
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
% ExeFile                     = 'openfast_x64_v4.exe';z
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