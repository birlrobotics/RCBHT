%% loadTrainingPriorProb
% This function loads prior probabilities for the Side Approach that were
% derived offline for the first 7 experiments performed on the
% SideApproach.

%%
function [Prot Psnap Pmat] = loadTrainingPriorProb

%% Define Path
    Path = 'C:\\Documents and Settings\\suarezjl\\My Documents\\MATLAB\\Active Sensing\\Probability\\20120525-TrainingData\\Prior';
    
%% Load Data    
    % Rotation
    Prot = xlsread(strcat(Path,'\\Prior_Rotation_Fx-Fz.xls')); % When loading data is saved to a structure. 
    
    % Snap
    Psnap = xlsread(strcat(Path,'\\Prior_Snap_Fx-Fz.xls'));
    
    % Mating
    Pmat = xlsread(strcat(Path,'\\Prior_Mating_Fx-Fz.xls'));
end