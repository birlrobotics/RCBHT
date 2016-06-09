%%*************************** Documentation *******************************
% StrategyType  : HIRO - Online Snap Verification for Side Approach
% FolderName    : Name of folder where results are stored, user based.
%**************************************************************************
function [postRot, postSnap, postMat] = BayesianFiltering(StrategyType,FolderName)

%% Initialize Data

    % Force axis
    forceAxis = ['Fx' 'Fy' 'Fz' 'Mx' 'My' 'Mz'];
    
    % LLB's Encoding: Generate variables that represent LLBs as int's:
    FX = 11; CT = 22; PS = 33; PL = 44; SH = 55; AL = 66;

    % Create a vector to only store tag and duration (columns 1 and 2) information from the original LLB structure. Extend the vector to six
    % dimensions to store this information across all six force axes.
    llbStruc  = zeros(1,2,6);

    % Create copies for Rotation, Snap, and Mating
    llbRot  = llbStruc; %struct('Fx',llbStruc,'Fy',llbStruc,'Fz',llbStruc,'Mx',llbStruc,'My',llbStruc,'Mz',llbStruc);
    llbSnap = llbStruc; %struct('Fx',llbStruc,'Fy',llbStruc,'Fz',llbStruc,'Mx',llbStruc,'My',llbStruc,'Mz',llbStruc);
    llbMat  = llbStruc; %struct('Fx',llbStruc,'Fy',llbStruc,'Fz',llbStruc,'Mx',llbStruc,'My',llbStruc,'Mz',llbStruc);

%% Load Data: 

    % Set Path
    StratTypeFolder = AssignDir(StrategyType); %i.e. Hiro Side Approach = 'HSA'
    % Assing appropriate directoy based on Ctrl Strategy to read data files
    if(ispc)
        Path = 'C:\\Documents and Settings\\suarezjl\\My Documents\\School\\Research\\AIST\\Results';
    else
       Path = '\\home\\juan\\Documents\\Results'; 
       % QNX
       % '\\home\\vmrguser\\Documents\\Results'; 
    end  

%% For EACH STATE: Rotation, Snap, and Mating compute the posterior probability. 

%% Load states and time data

    % 1) Get state times. Vector starts with 0 for start time, three sequential times, and an ending time. 
    stateTimes = load(strcat(Path,StratTypeFolder,'\\State.dat'));
    
    % 2) Task serial time vector
    time = load(strcat(Path,StratTypeFolder,'\\Torques.dat'));
    time = time(:,1); % Just keep the time column
    
%% For all Axes
    for axes = 1:6
        
       %% Existing LLBs (since we want to separate them by state)
        % Load the LLB.Fx
        LLB = load(strcat(Path,StratTypeFolder,'\\llBehaviors','llBehaviors_',forceAxis(axes),'.mat'));LLB = LLB.Sheet1; 
        [elements c] = size(LLB);

        % Go through each llb and look at their time. If ending time less than end of state make a copy to the respective state.
        % Check for all three states. 
        for i = 1:elements

            % 1. Rotation States
            % 1.1 - Only Rotation
            if(LLB(i,c-1)<stateTimes(3,1)) % End of Rotation time 
                % 1.2 - Rotation and Snap
                if(LLB(i,c-1)<stateTimes(4,1)) % End of Snap time
                    % 1.3 - Rotation and Snap and Mating
                    if(LLB(i,c-1)<stateTimes(5,1)) % End of Mating time

                        % Copy tag and duration across rotation, snap, and mating respectively.

                        % 1.3.1 - ROTATION
                        % If the LLB ends after the end of the Rotation state, trunk at the end.
                        if(LLB(i,16)>stateTimes(3,1))
                            EndTime = stateTimes(3,1);
                        else
                            EndTime = LLB(i,16);
                        end

                        % If the LLB starts before the start of the Rotation state, trunk at the beginning
                        if(LLB(i,13)<stateTimes(2,1))
                            StartTime = stateTimes(2,1);
                        else
                            StartTime = LLB(i,13);
                        end
                        %-------------------------------------------------------------------------------------------------------------------------------------
                        llbRot(i,1,axes) = LLB(i,1);   llbRot(i,2,axes) = EndTime-StartTime;    % i.e. duration = the end of the rotation state - where it started
                        %-------------------------------------------------------------------------------------------------------------------------------------

                        % 1.3.2 - SNAP
                        % If the LLB ends after the end of the Snap state, trunk at the end.
                        if(LLB(i,16)>stateTimes(4,1))
                            EndTime = stateTimes(4,1);
                        else
                            EndTime = LLB(i,16);
                        end

                        % If the LLB starts before the start of the Snap state, trunk at the beginning
                        if(LLB(i,13)<stateTimes(3,1))
                            StartTime = stateTimes(3,1);
                        else
                            StartTime = LLB(i,13);
                        end         
                        %-------------------------------------------------------------------------------------------------------------------------------------
                        llbSnap(i,1,axes) = LLB(i,1);   llbSnap(i,2,axes) = EndTime-StartTime; % i.e. duration = the end of the rotation state - where it started
                        %-------------------------------------------------------------------------------------------------------------------------------------

                        % 1.3.3 - Mating
                        % Set end time regardless
                        EndTime = LLB(i,16);

                        % If the LLB starts before the start of the Mating state, trunk at the beginning
                        if(LLB(i,13)<stateTimes(4,1))
                            StartTime = stateTimes(4,1);
                        else
                            StartTime = LLB(i,13);
                        end     
                        %-------------------------------------------------------------------------------------------------------------------------------------
                        llbMat(i,1,axes) = LLB(i,1);   llbMat(i,2,axes) = EndTime-StartTime; % i.e. duration = the end of the rotation state - where it started                    
                        %-------------------------------------------------------------------------------------------------------------------------------------
                    end               

                    %1.2 - Crosses Rotation and Snap states                
                    % 1.2.1 - ROTATION
                    % If the LLB ends after the end of the Rotation state, trunk at the end.
                    if(LLB(i,16)>stateTimes(3,1))
                        EndTime = stateTimes(3,1);
                    else
                        EndTime = LLB(i,16);
                    end

                    % If the LLB starts before the start of the Rotation state, trunk at the beginning
                    if(LLB(i,13)<stateTimes(2,1))
                        StartTime = stateTimes(2,1);
                    else
                        StartTime = LLB(i,13);
                    end
                    %-------------------------------------------------------------------------------------------------------------------------------------
                    llbRot(i,1,axes) = LLB(i,1);   llbRot(i,2,axes) = EndTime-StartTime;    % i.e. duration = the end of the rotation state - where it started
                    %-------------------------------------------------------------------------------------------------------------------------------------

                    % 1.2.2 - SNAP
                    % Set end time regardless
                    EndTime = LLB(i,16);

                    % If the LLB starts before the start of the Snap state, trunk at the beginning
                    if(LLB(i,13)<stateTimes(3,1))
                        StartTime = stateTimes(3,1);
                    else
                        StartTime = LLB(i,13);
                    end         
                    %-------------------------------------------------------------------------------------------------------------------------------------
                    llbSnap(i,1,axes) = LLB(i,1);   llbSnap(i,2,axes) = EndTime-StartTime; % i.e. duration = the end of the rotation state - where it started
                    %-------------------------------------------------------------------------------------------------------------------------------------                    
                end

                % 1.1.1 - ROTATION
                % Set end time regardless
                EndTime = LLB(i,16);

                % If the LLB starts before the start of the Rotation state, trunk at the beginning
                if(LLB(i,13)<stateTimes(2,1))
                    StartTime = stateTimes(2,1);
                else
                    StartTime = LLB(i,13);
                end         
                %-------------------------------------------------------------------------------------------------------------------------------------
                llbRot(i,1,axes) = LLB(i,1);   llbRot(i,2,axes) = EndTime-StartTime; % i.e. duration = the end of the rotation state - where it started
                %-------------------------------------------------------------------------------------------------------------------------------------
            end % End of Rotation States 
            
            % 2. Snap States
            % 2.1 - Snap
             if(LLB(i,c-1)<stateTimes(4,1)) % End of Snap time
                    % 2.2 - Snap and Mating
                    if(LLB(i,c-1)<stateTimes(5,1)) % End of Mating time

                        % Copy tag and duration across rotation, snap, and mating respectively.

                        % 2.2.1 - SNAP
                        % If the LLB ends after the end of the Snap state, trunk at the end.
                        if(LLB(i,16)>stateTimes(4,1))
                            EndTime = stateTimes(4,1);
                        else
                            EndTime = LLB(i,16);
                        end

                        % If the LLB starts before the start of the Snap state, trunk at the beginning
                        if(LLB(i,13)<stateTimes(3,1))
                            StartTime = stateTimes(3,1);
                        else
                            StartTime = LLB(i,13);
                        end         
                        %-------------------------------------------------------------------------------------------------------------------------------------
                        llbSnap(i,1,axes) = LLB(i,1);   llbSnap(i,2,axes) = EndTime-StartTime; % i.e. duration = the end of the rotation state - where it started
                        %-------------------------------------------------------------------------------------------------------------------------------------

                        % 2.2.2 - Mating
                        % Set end time regardless
                        EndTime = LLB(i,16);

                        % If the LLB starts before the start of the Mating state, trunk at the beginning
                        if(LLB(i,13)<stateTimes(4,1))
                            StartTime = stateTimes(4,1);
                        else
                            StartTime = LLB(i,13);
                        end     
                        %-------------------------------------------------------------------------------------------------------------------------------------
                        llbMat(i,1,axes) = LLB(i,1);   llbMat(i,2,axes) = EndTime-StartTime; % i.e. duration = the end of the rotation state - where it started                    
                        %-------------------------------------------------------------------------------------------------------------------------------------                    
                    end               

                % 2.1 - Does not cross Snap state             
                % 2.1.1 - SNAP

                % Set end time regardless
                EndTime = LLB(i,16);

                % If the LLB starts before the start of the Snap state, trunk at the beginning
                if(LLB(i,13)<stateTimes(3,1))
                    StartTime = stateTimes(3,1);
                else
                    StartTime = LLB(i,13);
                end         
                %-------------------------------------------------------------------------------------------------------------------------------------
                llbSnap(i,1,axes) = LLB(i,1);   llbSnap(i,2,axes) = EndTime-StartTime; % i.e. duration = the end of the rotation state - where it started
                %-------------------------------------------------------------------------------------------------------------------------------------                    
             end
        
            
            % 3. Mating States
            % 3.1 - Mating
                    
            % Set end time regardless
            EndTime = LLB(i,16);

            % If the LLB starts before the start of the Mating state, trunk at the beginning
            if(LLB(i,13)<stateTimes(4,1))
                StartTime = stateTimes(4,1);
            else
                StartTime = LLB(i,13);
            end         
            %-------------------------------------------------------------------------------------------------------------------------------------
            llbSnap(i,1,axes) = LLB(i,1);   llbSnap(i,2,axes) = EndTime-StartTime; % i.e. duration = the end of the rotation state - where it started
            %-------------------------------------------------------------------------------------------------------------------------------------                                    
            
        end
        
        % Clear memory
        clear LLB;
    end
    
%% Compute the a posterior Recursively
% We will need to study the llb that corresponds to a given time step

%% Load Probabilistic Data: Priors, System, Measurement Models
    % PRIOR/BELIEF: 3 6x6 matrices in a struct corresponding to prior's over LLBs for Rotation, Snap, Mating.
    % SYSTEM: 3 strucs each containing 6 matrices. Each matrix is a 6x6 matrix.
    % MEASUREMENT: 3 6x6 matrices containing average mean values for selected LLBs.
    [BELIEF SYSTEM MEASUREMENT]= loadProbabilisticTrainingData;
    
    % Initialize Variables
    initialFlag = 1;
    duration = size(time);
    
    
%% Bayesian filtering model for a recursive function: bel = normalizing coeff * Measurement Model * State Model * bel'; 

% Run the following algorithm for all three separate states:
    
%% Rotation 
    llbCounter=1;
    % Per time step    
    for k = 1:duration(1);
        % Per Axes
        for axes = 1:6
            
            % While a given LLB's duration is within the time step:
            if( llbRot(llbCounter,2)time(k) )
                
                % not just duration but time as well
            end

        end
    end
    
%% Snap


%% Mating
    
        
end
    





