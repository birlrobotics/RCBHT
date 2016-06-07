%% Documentation
% This program is intended to be used with the Bayesian Filter on the
% Change-Based Hierarchical Taxonomy (CBHT). For the Bayesian Filter we
% need two statistical measurements:
% 
% 1) The intial priors found in each force axis for each state of the automata
% 2) The transition count from one low-level behavior (LLB) to another for
% each force axis for each state of the automata
% 3) The average time of key LLBs that are selected to represent successful
% HLB behaviors like Rotation, Snap, and Mating for the Pivot Approach with
% 4 cantilever-snaps.
% 
% This program will automatically load:
% 
% 1) the LLBs found in the Results folder and use them to compute these parameters as part of the training data.
% 2) the state.dat file to identify when states start and finish.
%
% After loading these files it will compute the statistical parameters:
% 
% 1) Priors: these are counted as the agregate duration of a LLB in a state
% per axis over the total duration of that state.
%
% 2) It counts the number of transitions between LLBs. To do so we count
% the transition and place it in the corresponding element of a 6x6 matrix
% that correspond to the transition lines of this graph.
%
% 3) Compute the average time of key selected behaviors per force axis per
% state
%
% Inputs:
% ResultsFolder: stringed path-destination that contains folders with the
% results of each trial for the pivot approach. The structure for such
% files is as follows:
%   Name: year/month/day-time-SideApproach_result, where result is either: S or F
% The file structure inside each of the results is:
%   - Composites
%   - Figures
%   - llBehaviors
%   - Segments
%   - snapData3
%   Storage of all the .dat files are found in the top folder of the trial.
%
% Outputs:
% Priors: is a 6x3 matrix. The six rows represent the Fx-Mz force axis
% whilst the 3 columsn represent the 3 automata states: rotation, snap, and
% mating of the pivot approach.
%%
function [Priors, Transition, SelectedStateDuration] = probParameterExtraction(ResultsFolder)

%% Initializing Local Variables
    AXIS    = 6;    % Number of Axis (Fx, Fy, Fz, Mx, My, Mz)
    NoLLBs  = 6;    % Number of LLBS (FX,CT,PS,PL,AL,SH)
    STATES  = 3;    % Automata states for Pivot Approach (Side Approach - corresponds to 5 cantilever snaps): Rotation/Snap/Mating

    % Priors
    % Define for each state and then one aggregate matrix for all
    Priors_ROT  = zeros(AXIS,1);
    Priors_SNAP = zeros(AXIS,1);
    Priors_MAT  = zeros(AXIS,1);
    Priors = [Priors_ROT Priors_SNAP Priors_MAT];

    % Transitions
    % Define for each state and then one aggregate matrix for all
    Trans_ROT   = zeros(NoLLBs,NoLLBs);
    Trans_SNAP  = zeros(NoLLBs,NoLLBs);
    Trans_MAT   = zeros(NoLLBs,NoLLBs);
    Transition  = [Trans_ROT Trans_SNAP Trans_MAT];

    %% Loading Data

    % 1) Define computer path
    if(ispc)
        Path = 'C:\Documents and Settings\suarezjl\My Documents\School\Research\AIST\Results\ForceControl\'; 
        TOP  = 'SideApproach';
    % Linux
    else
       Path = '\\home\\juan\\Documents\\Results'; 
       % QNX
       % '\\home\\vmrguser\\Documents\\Results'; 
    end

    % Folder Name (stringed) array. 
    % Use the command dir on the top folder to get a struc for each file/folder
    % in the top folder.
    % First two elements are to be ignored, then use a loop and check the
    % 'isdir' property to check if it is a folder. If so, store the name if the
    % FolderName array. Note that this can stringed array can be easily be
    % implemented because all names have the same length.

    FolderNames = cell(1,1);
    
    % Save the folder structure into listing
    listing = dir(strcat(Path,TOP));

    % Get the size
    r = size(listing);
    
    % Iterate through listing struc and save names of directories. Start at i=3.
    for i=3:r(1)
       % If we have a directry
       if(listing(i,1).isdir == 1)
           % If successful attempt
           temp = listing(i,1).name;
           if(strcmp(temp(1,28),'S'))
               % Store the name
               FolderNames{i-2,1} = temp;
           end
       end
    end

    % Get thesize of FolderNames
    r = size(FolderNames);
    
    
    % Load .mat files and states 
    
%% Priors

%% Transitions

%% Means
end