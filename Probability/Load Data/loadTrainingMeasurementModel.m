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
% Output:
% Is a structure containing an mxn matrix for each automata state with the selected LLBs.
%%
function [PMMrot PMMsnap PMMmat] = loadTrainingMeasurementModel

%% Define Path
    Path = 'C:\\Documents and Settings\\suarezjl\\My Documents\\MATLAB\\Active Sensing\\Probability\\20120525-TrainingData\\Measurement Mean';
    
%% Load Data    
    % Rotation
    PMMrot = xlsread(strcat(Path,'\\Mean-Rotation-Fx-Fz.xls')); % When loading data is saved to a structure. 
    
    % Snap
    PMMsnap = xlsread(strcat(Path,'\\Mean-Snap-Fx-Fz.xls'));
    
    % Mating
    PMMmat = xlsread(strcat(Path,'\\Mean-Mating-Fx-Fz.xls'));   
       
end