% IEA 10 MW + EOG wind preview.
% Compare feedback-only with feedback-feedforward control.

%% Setup
clearvars; close all; clc;
addpath(genpath('..\WetiMatlabFunctions'))

% Define paths
OpenFASTPath = '..\OpenFAST\openfast_x64_v4.exe';
SimulationPath = '..\IEA10-198-RWT_LAC';

% Define FAST input file
SimulationName = 'IEA-10.0-198-RWT_EOG';

%% Run FB and FF simulation

% Change to the simulation folder so OpenFAST can find all DLLs
CurrentFolder = pwd;
cd(SimulationPath);

% Feedback only
dos(['"..\OpenFAST\openfast_x64_v4.exe" ', ...
    SimulationName,'_FB_2.6.fst']);

% Feedback + feedforward
dos(['"..\OpenFAST\openfast_x64_v4.exe" ', ...
    SimulationName,'_FBFF.fst']);

% Return to MATLAB script folder
cd(CurrentFolder);

%% Comparison
% Read simulation results
FB = ReadFASTbinaryIntoStruct( ...
    fullfile(SimulationPath,[SimulationName,'_FB.outb']));

FBFF = ReadFASTbinaryIntoStruct( ...
    fullfile(SimulationPath,[SimulationName,'_FBFF.outb']));

% Read ROSCO debug file
FBFF_R = ReadROSCOtextIntoStruct( ...
    fullfile(SimulationPath,[SimulationName,'_FBFF.RO.dbg']));

%% Plot
figure('Name','Simulation results')
sgtitle('10MW-RWT-LAC')
subplot(4,1,1);
hold on; grid on; box on
plot(FB.Time, FB.Wind1VelX);
plot(FBFF_R.Time, FBFF_R.REWS);
ylabel('[m/s]');
legend('Wind1VelX','REWS preview', ...
    'Interpreter','none','Location','best')

subplot(4,1,2);
hold on; grid on; box on
plot(FB.Time, FB.BldPitch1);
plot(FBFF.Time, FBFF.BldPitch1);
ylabel({'BldPitch1'; '[deg]'});
legend('feedback only','feedback-feedforward', ...
    'Location','best')

subplot(4,1,3);
hold on; grid on; box on
plot(FB.Time, FB.RotSpeed);
plot(FBFF.Time, FBFF.RotSpeed);
ylabel({'RotSpeed'; '[rpm]'});
legend('feedback only','feedback-feedforward', ...
    'Location','best')

subplot(4,1,4);
hold on; grid on; box on
plot(FB.Time, FB.TwrBsMyt/1e3);
plot(FBFF.Time, FBFF.TwrBsMyt/1e3);
ylabel({'TwrBsMyt'; '[MNm]'});
legend('feedback only','feedback-feedforward', ...
    'Location','best')

xlabel('time [s]')
linkaxes(findobj(gcf, 'Type', 'Axes'),'x');
xlim([0 40])