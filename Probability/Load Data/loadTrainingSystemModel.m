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
%
% Inputs:
% dataTypeFlag  - if 0 load a .mat file. 
%               - if 1 load a .xls file.
function [ROT SNAP MAT] = loadTrainingSystemModel(dataTypeFlag)

%% Define Path

    % General Path
    Path = 'C:\\Documents and Settings\\suarezjl\\My Documents\\MATLAB\\Active Sensing\\Probability\\20120525-TrainingData\\Transitions';
    
    % Rotation Subfolder
    Rot_Path = '\\Rotation';
    Snap_Path= '\\Snap';
    Mat_Path = '\\Mating';
    
    NumAxes = 6;
   
%% Load Rotation Data    

    if(dataTypeFlag==0)
    %% Rot Fx
        TRot_Fx = load(strcat(Path,Rot_Path,'\\Fx-Rot-Transitions.xls')); % When loading data is saved to a structure. 
        TRot_Fx = TRot_Fx.Sheet1;  

        % Get general size for all structures:
        [r c]   = size(TRot_Fx);

        % For each automata state (Rotation, Snap, Mating) create a six dimensional container (one for each force axis) for the system probabilities.
        ROT = zeros(r,c,NumAxes);	

        % Copy to buffer
        ROT(:,:,1) = TRot_Fx;

    %% Rot Fy    
        TRot_Fy = load(strcat(Path,Rot_Path,'\\Fy-Rot-Transitions.mat')); % When loading data is saved to a structure. 
        TRot_Fy = TRot_Fy.Sheet1;

        % Copy to buffer
        ROT(:,:,2) = TRot_Fy;    

    %% Rot Fz    
        TRot_Fz = load(strcat(Path,Rot_Path,'\\Fz-Rot-Transitions.mat')); % When loading data is saved to a structure. 
        TRot_Fz = TRot_Fz.Sheet1;    

        % Copy to buffer
        ROT(:,:,3) = TRot_Fz;    
    %% Rot Mx    
        TRot_Mx = load(strcat(Path,Rot_Path,'\\Mx-Rot-Transitions.mat')); % When loading data is saved to a structure. 
        TRot_Mx = TRot_Mx.Sheet1;    

        % Copy to buffer
        ROT(:,:,4) = TRot_Mx;    
    %% Rot My    
        TRot_My = load(strcat(Path,Rot_Path,'\\My-Rot-Transitions.mat')); % When loading data is saved to a structure. 
        TRot_My = TRot_My.Sheet1;

        % Copy to buffer
        ROT(:,:,5) = TRot_My;    
    %% Rot Mz    

        TRot_Mz = load(strcat(Path,Rot_Path,'\\Mz-Rot-Transitions.mat')); % When loading data is saved to a structure. 
        TRot_Mz = TRot_Mz.Sheet1;

        % Copy to buffer
        ROT(:,:,6) = TRot_Mz;    


    %% ----------------------------Load Snap Data-------------------------------

    %% Snap FX
        TSnap_Fx = load(strcat(Path,Snap_Path,'\\Fx-Snap-Transitions.mat')); % When loading data is saved to a structure. 
        TSnap_Fx = TSnap_Fx.Sheet1;

        % Get general size for all structures:
        [r c]   = size(TRot_Fx);

        % For each automata state (Rotation, Snap, Mating) create a six dimensional container (one for each force axis) for the system probabilities.
        SNAP = zeros(r,c,NumAxes);	

        % Copy to buffer
        SNAP(:,:,1) = TSnap_Fx;  

    %% Snap Fy
        TSnap_Fy = load(strcat(Path,Snap_Path,'\\Fy-Snap-Transitions.mat')); % When loading data is saved to a structure. 
        TSnap_Fy = TSnap_Fy.Sheet1;

        % Copy to buffer
        SNAP(:,:,2) = TSnap_Fy;    

    %% Snap Fz    
        TSnap_Fz = load(strcat(Path,Snap_Path,'\\Fz-Snap-Transitions.mat')); % When loading data is saved to a structure. 
        TSnap_Fz = TSnap_Fz.Sheet1;

        % Copy to buffer
        SNAP(:,:,3) = TSnap_Fz;     

    %% Snap Mx    
        TSnap_Mx = load(strcat(Path,Snap_Path,'\\Mx-Snap-Transitions.mat')); % When loading data is saved to a structure. 
        TSnap_Mx = TSnap_Mx.Sheet1;

        % Copy to buffer
        SNAP(:,:,4) = TSnap_Mx; 
    %% Snap My     
        TSnap_My = load(strcat(Path,Snap_Path,'\\My-Snap-Transitions.mat')); % When loading data is saved to a structure. 
        TSnap_My = TSnap_My.Sheet1;

        % Copy to buffer
        SNAP(:,:,5) = TSnap_My;     

    %% Snap Mz    
        TSnap_Mz = load(strcat(Path,Snap_Path,'\\Mz-Snap-Transitions.mat')); % When loading data is saved to a structure. 
        TSnap_Mz = TSnap_Mz.Sheet1;

        % Copy to buffer
        SNAP(:,:,6) = TSnap_Mz; 
    %% Mating

    %% Mat Fx
        TMat_Fx = load(strcat(Path,Mat_Path,'\\Fx-Mat-Transitions.mat')); % When loading data is saved to a structure. 
        TMat_Fx = TMat_Fx.Sheet1;

        % Get size
        [r c] = size(TMat_Fx);

        % For each automata state (Rotation, Snap, Mating) create a six dimensional container (one for each force axis) for the system probabilities.
        MAT = zeros(r,c,NumAxes);	

        % Copy to buffer
        MAT(:,:,1) = TMat_Fx;     

    %% Mat Fy    
        TMat_Fy = load(strcat(Path,Mat_Path,'\\Fy-Mat-Transitions.mat')); % When loading data is saved to a structure. 
        TMat_Fy = TMat_Fy.Sheet1;

        % Copy to buffer
        MAT(:,:,2) = TMat_Fy;     

    %% Mat Fz    
        TMat_Fz = load(strcat(Path,Mat_Path,'\\Fz-Mat-Transitions.mat')); % When loading data is saved to a structure. 
        TMat_Fz = TMat_Fz.Sheet1;

        % Copy to buffer
        MAT(:,:,3) = TMat_Fz;     

    %% Mat Mx    
        TMat_Mx = load(strcat(Path,Mat_Path,'\\Mx-Mat-Transitions.mat')); % When loading data is saved to a structure. 
        TMat_Mx = TMat_Mx.Sheet1;

        % Copy to buffer
        MAT(:,:,4) = TMat_Mx;     
    %% Mat My    
        TMat_My = load(strcat(Path,Mat_Path,'\\My-Mat-Transitions.mat')); % When loading data is saved to a structure. 
        TMat_My = TMat_My.Sheet1;

        % Copy to buffer
        MAT(:,:,5) = TMat_My;     

    %% Mat Mz    
        TMat_Mz = load(strcat(Path,Mat_Path,'\\Mz-Mat-Transitions.mat')); % When loading data is saved to a structure. 
        TMat_Mz = TMat_Mz.Sheet1;

        % Copy to buffer
        MAT(:,:,6) = TMat_Mz;   
        
%% LOAD XLS        
    else
    %% Rot Fx
        TRot_Fx = xlsread(strcat(Path,Rot_Path,'\\Fx-Rot-Transitions.xls')); % When loading data is saved to a structure. 
          
        % Get general size for all structures:
        [r c]   = size(TRot_Fx);

        % For each automata state (Rotation, Snap, Mating) create a six dimensional container (one for each force axis) for the system probabilities.
        ROT = zeros(r,c,NumAxes);	

        % Copy to buffer
        ROT(:,:,1) = TRot_Fx;

    %% Rot Fy    
        TRot_Fy = xlsread(strcat(Path,Rot_Path,'\\Fy-Rot-Transitions.xls')); % When loading data is saved to a structure. 

        % Copy to buffer
        ROT(:,:,2) = TRot_Fy;    

    %% Rot Fz    
        TRot_Fz = xlsread(strcat(Path,Rot_Path,'\\Fz-Rot-Transitions.xls')); % When loading data is saved to a structure. 

        % Copy to buffer
        ROT(:,:,3) = TRot_Fz;    
    %% Rot Mx    
        TRot_Mx = xlsread(strcat(Path,Rot_Path,'\\Mx-Rot-Transitions.xls')); % When loading data is saved to a structure. 

        % Copy to buffer
        ROT(:,:,4) = TRot_Mx;    
    %% Rot My    
        TRot_My = xlsread(strcat(Path,Rot_Path,'\\My-Rot-Transitions.xls')); % When loading data is saved to a structure. 

        % Copy to buffer
        ROT(:,:,5) = TRot_My;    
    %% Rot Mz    

        TRot_Mz = xlsread(strcat(Path,Rot_Path,'\\Mz-Rot-Transitions.xls')); % When loading data is saved to a structure. 

        % Copy to buffer
        ROT(:,:,6) = TRot_Mz;    


%% ----------------------------Load Snap Data-------------------------------

    %% Snap FX
        TSnap_Fx = xlsread(strcat(Path,Snap_Path,'\\Fx-Snap-Transitions.xls')); % When loading data is saved to a structure. 

        % Get general size for all structures:
        [r c]   = size(TRot_Fx);

        % For each automata state (Rotation, Snap, Mating) create a six dimensional container (one for each force axis) for the system probabilities.
        SNAP = zeros(r,c,NumAxes);	

        % Copy to buffer
        SNAP(:,:,1) = TSnap_Fx;  

    %% Snap Fy
        TSnap_Fy = xlsread(strcat(Path,Snap_Path,'\\Fy-Snap-Transitions.xls')); % When loading data is saved to a structure. 

        % Copy to buffer
        SNAP(:,:,2) = TSnap_Fy;    

    %% Snap Fz    
        TSnap_Fz = xlsread(strcat(Path,Snap_Path,'\\Fz-Snap-Transitions.xls')); % When loading data is saved to a structure. 

        % Copy to buffer
        SNAP(:,:,3) = TSnap_Fz;     

    %% Snap Mx    
        TSnap_Mx = xlsread(strcat(Path,Snap_Path,'\\Mx-Snap-Transitions.xls')); % When loading data is saved to a structure. 

        % Copy to buffer
        SNAP(:,:,4) = TSnap_Mx; 
    %% Snap My     
        TSnap_My = xlsread(strcat(Path,Snap_Path,'\\My-Snap-Transitions.xls')); % When loading data is saved to a structure. 

        % Copy to buffer
        SNAP(:,:,5) = TSnap_My;     

    %% Snap Mz    
        TSnap_Mz = xlsread(strcat(Path,Snap_Path,'\\Mz-Snap-Transitions.xls')); % When loading data is saved to a structure. 

        % Copy to buffer
        SNAP(:,:,6) = TSnap_Mz; 
%% -------------------------------Mating-----------------------------------

    %% Mat Fx
        TMat_Fx = xlsread(strcat(Path,Mat_Path,'\\Fx-Mat-Transitions.xls')); % When loading data is saved to a structure. 

        % Get size
        [r c] = size(TMat_Fx);

        % For each automata state (Rotation, Snap, Mating) create a six dimensional container (one for each force axis) for the system probabilities.
        MAT = zeros(r,c,NumAxes);	

        % Copy to buffer
        MAT(:,:,1) = TMat_Fx;     

    %% Mat Fy    
        TMat_Fy = xlsread(strcat(Path,Mat_Path,'\\Fy-Mat-Transitions.xls')); % When loading data is saved to a structure. 

        % Copy to buffer
        MAT(:,:,2) = TMat_Fy;     

    %% Mat Fz    
        TMat_Fz = xlsread(strcat(Path,Mat_Path,'\\Fz-Mat-Transitions.xls')); % When loading data is saved to a structure. 

        % Copy to buffer
        MAT(:,:,3) = TMat_Fz;     

    %% Mat Mx    
        TMat_Mx = xlsread(strcat(Path,Mat_Path,'\\Mx-Mat-Transitions.xls')); % When loading data is saved to a structure. 

        % Copy to buffer
        MAT(:,:,4) = TMat_Mx;     
    %% Mat My    
        TMat_My = xlsread(strcat(Path,Mat_Path,'\\My-Mat-Transitions.xls')); % When loading data is saved to a structure. 

        % Copy to buffer
        MAT(:,:,5) = TMat_My;     

    %% Mat Mz    
        TMat_Mz = xlsread(strcat(Path,Mat_Path,'\\Mz-Mat-Transitions.xls')); % When loading data is saved to a structure. 

        % Copy to buffer
        MAT(:,:,6) = TMat_Mz;     
    end
end