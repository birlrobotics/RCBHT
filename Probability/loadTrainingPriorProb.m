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
    Prot = load(strcat(Path,'\\Prior_Rotation_Fx-Fz.mat')); % When loading data is saved to a structure. 
    Prot = Prot.Sheet1;                                     % Extract information from structure into easy-to-understand variable name
    
    % Snap
    Psnap = load(strcat(Path,'\\Prior_Snap_Fx-Fz.mat'));
    Psnap = Psnap.Sheet1;
    
    % Mating
    Pmat = load(strcat(Path,'\\Prior_Mating_Fx-Fz.mat'));
    Pmat = Pmat.Sheet1;    

end