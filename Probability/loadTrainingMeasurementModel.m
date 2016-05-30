%% loadTrainingMeasurementModel
% This function loads the measurement model probabilities that were
% generated as a mean value from training data.
%
% The measurements are for low-level behaviors (LLBs) that are deemed essential
% to characterized the desired high-level behaviors (HLBs) for a successful cantilever snap
% assembly based on the Pivot Approach for four snaps.
%
% The desired LLBs are associated for each of the six force axis and for
% each of the automata states. For each state a list of six LLBs is
% presented for each of the six force axes:
%
% ROT:    {FX	NA	     FX     NA       FX     NA}
% Snap:   {CT	U(Al,FX) FX     U(Al,FX) CT     U(Al,FX)}
% Mating: {FX	FX       FX     FX       FX     FX}
% 
% Where, 
% FX = fixed LLB
% CT = contact
% U()= the union of probabilities for two LLBS
% NA = Not applicable
%
% The output are (could be rendered sparse) matrices that correspond to each automata state
% with the selected LLBs.
%%
function [PMMrot PMMsnap PMMmat] = loadTrainingMeasurementModel

%% Define Path
    Path = 'C:\\Documents and Settings\\suarezjl\\My Documents\\MATLAB\\Active Sensing\\Probability\\20120525-TrainingData\\Measurement Mean';
    
%% Load Data    
    % Rotation
    PMMrot = load(strcat(Path,'\\Mean-Rotation-Fx-Fz.mat')); % When loading data is saved to a structure. 
    PMMrot = PMMrot.Sheet1;                                     % Extract information from structure into easy-to-understand variable name
    
    % Snap
    PMMsnap = load(strcat(Path,'\\Mean-Snap-Fx-Fz.mat'));
    PMMsnap = PMMsnap.Sheet1;
    
    % Mating
    PMMmat = load(strcat(Path,'\\Mean-Mating-Fx-Fz.mat'));
    PMMmat = PMMmat.Sheet1; 

end