%% loadTrainingSystemModel
% The system model is the probability of going from state t-1 to state t.
% In this case we have six states or low level behaviors (LLBs): fix,
% contact, push, pull, shift, and align. They are summarized by: 
% {FX, CT, PS, PL, SH, AL}.
%
% The probabilities of going from one state to another are encoded in a 6x6
% matrix with rows and column entries ordered as shown above.
%
% This 6x6 matrix thus represents state-transition probabilities. Most of
% these matrices are sparse.
%
% The computation of these matrices is also performed separately for each
% of the six force axis of the robot; that is, the force in the x,y,z
% directions as well as the moment:
% {Fx Fy Fz Mx My Mz}.
%
% Finally, these transition computations are also performed for each of the three automata states that use fore data 
% in the Pivot/Side Approach: Rotation, Snap, and Mating.
%
% Hence, the output is organized in SIX 6x6 matrices for each of the THREE
% automata state, for a total of 18 matrices. 
% To simplify the output, the six force matrices will be encoded as part of
% a structure within the automata states. That is to say, expect the
% following matrix structures:
%   struct Rot{Fx...Mz}; 
%   struct Snap{Fx...Mz};
%   struct Mat{Fx...Mz};
function [ROT SNAP MAT] = loadTrainingSystemModel

%% Define Path

    % General Path
    Path = 'C:\\Documents and Settings\\suarezjl\\My Documents\\MATLAB\\Active Sensing\\Probability\\20120525-TrainingData\\Transitions';
    
    % Rotation Subfolder
    Rot_Path = '\\Rotation';
    Snap_Path= '\\Snap';
    Mat_Path = '\\Mating';
    
%% Load Rotation Data    

    TRot_Fx = load(strcat(Path,Rot_Path,'\\Fx-Rot-Transitions.mat')); % When loading data is saved to a structure. 
    TRot_Fx = TRot_Fx.Sheet1;  
    
    TRot_Fy = load(strcat(Path,Rot_Path,'\\Fy-Rot-Transitions.mat')); % When loading data is saved to a structure. 
    TRot_Fy = TRot_Fy.Sheet1;
    
    TRot_Fz = load(strcat(Path,Rot_Path,'\\Fz-Rot-Transitions.mat')); % When loading data is saved to a structure. 
    TRot_Fz = TRot_Fz.Sheet1;
    
    TRot_Mx = load(strcat(Path,Rot_Path,'\\Mx-Rot-Transitions.mat')); % When loading data is saved to a structure. 
    TRot_Mx = TRot_Mx.Sheet1;

    TRot_My = load(strcat(Path,Rot_Path,'\\My-Rot-Transitions.mat')); % When loading data is saved to a structure. 
    TRot_My = TRot_My.Sheet1;
    
    TRot_Mz = load(strcat(Path,Rot_Path,'\\Mz-Rot-Transitions.mat')); % When loading data is saved to a structure. 
    TRot_Mz = TRot_Mz.Sheet1;
    
    ROT = struct('Fx',TRot_Fx,'Fy',TRot_Fy,'Fz',TRot_Fz,'Mx',TRot_Mx,'My',TRot_My,'Mz',TRot_Mz);
    
%% Load Snap Data  

    TSnap_Fx = load(strcat(Path,Snap_Path,'\\Fx-Snap-Transitions.mat')); % When loading data is saved to a structure. 
    TSnap_Fx = TSnap_Fx.Sheet1;
    
    TSnap_Fy = load(strcat(Path,Snap_Path,'\\Fy-Snap-Transitions.mat')); % When loading data is saved to a structure. 
    TSnap_Fy = TSnap_Fy.Sheet1;
    
    TSnap_Fz = load(strcat(Path,Snap_Path,'\\Fz-Snap-Transitions.mat')); % When loading data is saved to a structure. 
    TSnap_Fz = TSnap_Fz.Sheet1;
    
    TSnap_Mx = load(strcat(Path,Snap_Path,'\\Mx-Snap-Transitions.mat')); % When loading data is saved to a structure. 
    TSnap_Mx = TSnap_Mx.Sheet1;

    TSnap_My = load(strcat(Path,Snap_Path,'\\My-Snap-Transitions.mat')); % When loading data is saved to a structure. 
    TSnap_My = TSnap_My.Sheet1;
    
    TSnap_Mz = load(strcat(Path,Snap_Path,'\\Mz-Snap-Transitions.mat')); % When loading data is saved to a structure. 
    TSnap_Mz = TSnap_Mz.Sheet1;
    
    SNAP = struct('Fx',TSnap_Fx,'Fy',TSnap_Fy,'Fz',TSnap_Fz,'Mx',TSnap_Mx,'My',TSnap_My,'Mz',TSnap_Mz);
    
%% Mating

    TMat_Fx = load(strcat(Path,Mat_Path,'\\Fx-Mat-Transitions.mat')); % When loading data is saved to a structure. 
    TMat_Fx = TMat_Fx.Sheet1;
    
    TMat_Fy = load(strcat(Path,Mat_Path,'\\Fy-Mat-Transitions.mat')); % When loading data is saved to a structure. 
    TMat_Fy = TMat_Fy.Sheet1;
    
    TMat_Fz = load(strcat(Path,Mat_Path,'\\Fz-Mat-Transitions.mat')); % When loading data is saved to a structure. 
    TMat_Fz = TMat_Fz.Sheet1;
    
    TMat_Mx = load(strcat(Path,Mat_Path,'\\Mx-Mat-Transitions.mat')); % When loading data is saved to a structure. 
    TMat_Mx = TMat_Mx.Sheet1;

    TMat_My = load(strcat(Path,Mat_Path,'\\My-Mat-Transitions.mat')); % When loading data is saved to a structure. 
    TMat_My = TMat_My.Sheet1;
    
    TMat_Mz = load(strcat(Path,Mat_Path,'\\Mz-Mat-Transitions.mat')); % When loading data is saved to a structure. 
    TMat_Mz = TMat_Mz.Sheet1;
    
    MAT = struct('Fx',TMat_Fx,'Fy',TMat_Fy,'Fz',TMat_Fz,'Mx',TMat_Mx,'My',TMat_My,'Mz',TMat_Mz);
    
end