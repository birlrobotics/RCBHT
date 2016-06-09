%% DivideLLB2States
% The goal of this function is to take the LLB structure that spans all states 
% and assign llbs to states according to their time presence.
%
% LLB Structure is {n x 17} struc. In the original development of the
% Change-Based-Hierarchical Taxonomy, LLBs were not separated by state, but
% rather from beginning to end. 
%
% Here we discern which LLBs are in which HLB states. If they cross state
% borders, the respective LLB will be copied to the respective state. The
% copy of the LLB will only be of four parameters:
% 1) LLB name tag
% 2) Starting time for LLB
% 3) Ending time for LLB, and
% 4) Duration
%
% Inputs:
% Path              - Main folder path trunk for results
% StratTypeFolder   - Folder for specific strategy (PivApp, SideApp)
% FolderName        - Trial folder Name
% ForceAxes         - 1x6 stringed column vector with names of force axis Fx...Mz
% stateTimes        - state vector including the following elements: 
%                     {EndApproach,EndRot,EndSnap,EndMat}. EndMat is also the end of the trial.
%                     Note that the starting time is not included in this vector.
%
% Ouputs:
% Three outputs. The new llb struc's for each of the states:
% llbRot    - nx3 struc
% llbSnap   - same
% llbMat    - same

%%
function [llbRot llbSnap llbMat] = DivideLLB2States(Path,StratTypeFolder,FolderName,forceAxes,stateTimes)

%% Global Variables

    % TIME ENCODING
    % Based on the LLB structure (17 parameters), the starting time and ending time are as follows:
    tStart = 13;
    tEnd   = 16;
    
    % State Encoding
    % Based on the SideApproch/Pivot Approach (4 snaps): State 1 = start; State 2 = EndApproach, State3 = EndRot; State4 = EndSnap; State5 = EndMating; 
    % The stateTimes vector has been stripped off the starting time, so the EndApproach is the first index. 
    EndApproach = 1;
    EndRot      = 2; 
    EndSnap     = 3;
    EndMating   = 4;
    
    % Minimalized llb structures
    % Create a vector to only store tag and duration (columns 1 and 2) information from the original LLB structure. Extend the vector to six
    % dimensions to store this information across all six force axes.
    dims = 4;
    NumAxes = 6;
    llbStruc  = zeros(1,dims,NumAxes);

    % Create copies for Rotation, Snap, and Mating. 
    llbRot  = llbStruc; %struct('Fx',llbStruc,'Fy',llbStruc,'Fz',llbStruc,'Mx',llbStruc,'My',llbStruc,'Mz',llbStruc);
    llbSnap = llbStruc; %struct('Fx',llbStruc,'Fy',llbStruc,'Fz',llbStruc,'Mx',llbStruc,'My',llbStruc,'Mz',llbStruc);
    llbMat  = llbStruc; %struct('Fx',llbStruc,'Fy',llbStruc,'Fz',llbStruc,'Mx',llbStruc,'My',llbStruc,'Mz',llbStruc);
    clear llbStruc;

%% Divide to States
%% For all Axes
    llbRotCtr  = 1;
    llbSnapCtr = 1;
    llbMatCtr  = 1;
    
    %InclueApproachStateFlag = false;  % Flag used to identify Approach llb in previous automata state
    IncludeRotStateFlag     = false;   % Flag used to identify Rotation llb in previous automata state
    IncludeSnapStateFlag    = false;   % Flag used to identify Snap     llb in previous automata state
    %IncludeMagStateFlag     = false;  % Flag used to identify Mating   llb in previous automata state
    for axes = 1:NumAxes
        
       %% Load LLB by Axes (you will retrieve a CELL struc)
        LLB = load(strcat(Path,StratTypeFolder,FolderName,'\\llBehaviors','\\llBehaviors_',forceAxes(axes,:),'.mat'));LLB = LLB.data; 
        elements = size(LLB);

        % Copy LLBs to minimalized llb strucs according to state presence.
        for i = 1:elements(1)

            % 1. Rotation States
            % 1.1 - Rotation and Snap and Mating
            if(LLB{i,tEnd}<=stateTimes(EndMating,1))      % End of Mating time 
                % 1.2 - Rotation and Snap
                if(LLB{i,tEnd}<=stateTimes(EndSnap,1))    % End of Snap time
                    % 1.3 - Only Rotation
                    if(LLB{i,tEnd}<=stateTimes(EndRot,1)) % End of Rotation time  
                        % Is not exclusively in the Approach stage
                        if(LLB{i,tEnd}<stateTimes(EndApproach,1))
                            continue; % skipp this iteration
                        else
                            % 1.3.1 - Rotation
                            % This end-time is before the end of Rotation. 
                            EndTime = LLB{i,tEnd};

                            % If LLB starts before the start of the Rotation state, trunk at the beginning
                            if(LLB{i,tStart}<stateTimes(EndApproach,1))
                                StartTime = stateTimes(EndApproach,1);
                            else
                                StartTime = LLB{i,tStart};
                            end     
                            %-------------------------------------------------------------------------------------------------------------------------------------
                            llbRot(llbRotCtr,1,axes) = convertLLB2int(LLB{i,1});   % Numerical Tag. 1-6 = FX CT PS PL SH AL
                            llbRot(llbRotCtr,2,axes) = StartTime;                  % Start time - maybe truncated
                            llbRot(llbRotCtr,3,axes) = EndTime;                    % End time 
                            llbRot(llbRotCtr,4,axes) = EndTime-StartTime;          % Duration
                            llbRotCtr = llbRotCtr + 1;
                            %-------------------------------------------------------------------------------------------------------------------------------------                        
                        
                            % Now go to the next iteration
                            continue;
                        end
                    end

                    % 1.2 - Not solely contained by rotation. Two state assignments: (a) for the Rotation state, (b) for the Snap state.
                    
                    % 1.2.1 - SNAP STATE ADDITION
                    % Set End-time for snap state
                    EndSnapTime = LLB{i,tEnd};                    
                        
                    % If the LLB starts before the start of the Snap state, trunk at the beginning
                    if(LLB{i,tStart}<stateTimes(EndRot,1))
                        IncludeRotStateFlag = true;
                        
                        StartSnapTime  = stateTimes(EndRot,1);
                        EndRotTime     = stateTimes(EndRot,1);
                        
                        % 1.2.2 - Does the llb also exist in APPROACH
                        if(LLB{i,tStart}<stateTimes(EndApproach,1))                                                                                    
                            %IncludeApproachStateFlag = true;
                            
                            StartRotTime  = stateTimes(EndApproach,1);
                            %EndApproachTime = stateTimes(EndApproach,1);
                            %StartApproachTime = LLB{i,tStart};                            
                        else
                            StartRotTime = LLB{i,tStart};
                        end                                                   
                    else
                        StartSnapTime = LLB{i,tStart};
                    end         
                    %-------------------------------------------------------------------------------------------------------------------------------------
                    llbSnap(llbSnapCtr,1,axes) = convertLLB2int(LLB{i,1});   % Numerical Tag. 1-6 = FX CT PS PL SH AL
                    llbSnap(llbSnapCtr,2,axes) = StartSnapTime;              % Start time - maybe truncated
                    llbSnap(llbSnapCtr,3,axes) = EndSnapTime;                % End time                                         
                    llbSnap(llbSnapCtr,4,axes) = EndSnapTime-StartSnapTime;  % Duration
                    llbSnapCtr = llbSnapCtr + 1;
                    %-------------------------------------------------------------------------------------------------------------------------------------                                   
                    
                    
                    % 1.2.2 - ROTATION STATE: only call if IncludePrevStateFlag = true    
                    if(IncludeRotStateFlag)
                        %-------------------------------------------------------------------------------------------------------------------------------------
                        llbRot(llbRotCtr,1,axes) = convertLLB2int(LLB{i,1});   % Numerical Tag. 1-6 = FX CT PS PL SH AL
                        llbRot(llbRotCtr,2,axes) = StartRotTime;               % Start time - maybe truncated
                        llbRot(llbRotCtr,3,axes) = EndRotTime;                 % End time 
                        llbRot(llbRotCtr,4,axes) = EndRotTime-StartRotTime;    % Duration
                        llbRotCtr = llbRotCtr + 1;
                        IncludeRotStateFlag = false;
                        %-------------------------------------------------------------------------------------------------------------------------------------
                    end
                    continue; % Now go to the next iteration
                end
                
                % 1.1 - Not solely contained by snap. Three state assignments: (a) Mating state, (b) Snap state, and (c) Rotation State
                
                % 1.1.1 - Mating
                % Set end time for the mating state
                EndMatTime = LLB{i,tEnd};

                %% Test for two conditions: does the state start before mating AND does it start before Snap?
                
                % 1.1.2 - Does the llb also exist in SNAP
                if(LLB{i,tStart}<stateTimes(EndSnap,1))
                    IncludeSnapStateFlag = true;
                    
                    StartMatTime    = stateTimes(EndSnap,1);
                    EndSnapTime     = stateTimes(EndSnap,1);
                    
                    % 1.1.3 - Does the llb also exist in ROTATION
                    if(LLB{i,tStart}<stateTimes(EndRot,1))
                        IncludeRotStateFlag = true;
                        
                        StartSnapTime  = stateTimes(EndRot,1);
                        EndRotTime     = stateTimes(EndRot,1);
                        
                        % 1.1.4 - Does the llb also exist in APPROACH
                        if(LLB{i,tStart}<stateTimes(EndApproach,1))                                                                                    
                            %IncludeApproachStateFlag = true;
                            
                            StartRotTime  = stateTimes(EndApproach,1);
                            %EndApproachTime = stateTimes(EndApproach,1);
                            %StartApproachTime = LLB{i,tStart};                            
                        else
                            StartRotTime = LLB{i,tStart};
                        end                           
                    else
                        StartSnapTime = LLB{i,tStart};
                    end                      
                else
                    StartMatTime = LLB{i,tStart};
                end                     
                
                % MAT Computation
                %-------------------------------------------------------------------------------------------------------------------------------------
                llbMat(llbMatCtr,1,axes) = convertLLB2int(LLB{i,1});        % Numerical Tag. 1-6 = FX CT PS PL SH AL
                llbMat(llbMatCtr,2,axes) = StartMatTime;                    % Start time - maybe truncated
                llbMat(llbMatCtr,3,axes) = EndMatTime;                      % End time                                         
                llbMat(llbMatCtr,4,axes) = EndMatTime-StartMatTime;         % Duration
                llbMatCtr = llbMatCtr + 1;
                %-------------------------------------------------------------------------------------------------------------------------------------  

                % 1.1.2 - SNAP  
                if(IncludeSnapStateFlag)
                    %-------------------------------------------------------------------------------------------------------------------------------------
                    llbSnap(llbSnapCtr,1,axes) = convertLLB2int(LLB{i,1});      % Numerical Tag. 1-6 = FX CT PS PL SH AL
                    llbSnap(llbSnapCtr,2,axes) = StartSnapTime;                 % Start time - maybe truncated
                    llbSnap(llbSnapCtr,3,axes) = EndSnapTime;                   % End time                                         
                    llbSnap(llbSnapCtr,4,axes) = EndSnapTime-StartSnapTime;     % Duration
                    llbSnapCtr = llbSnapCtr + 1;
                    IncludeSnapStateFlag = false;
                    %-------------------------------------------------------------------------------------------------------------------------------------
                    
                    % 1.1.3 - ROTATION   
                    if(IncludeRotStateFlag)
                        %-------------------------------------------------------------------------------------------------------------------------------------
                        llbRot(llbRotCtr,1,axes) = convertLLB2int(LLB{i,1});   % Numerical Tag. 1-6 = FX CT PS PL SH AL
                        llbRot(llbRotCtr,2,axes) = StartRotTime;               % Start time - maybe truncated
                        llbRot(llbRotCtr,3,axes) = EndRotTime;                 % End time                                         
                        llbRot(llbRotCtr,4,axes) = EndRotTime-StartRotTime;    % Duration
                        llbRotCtr = llbRotCtr + 1;
                        IncludeRotStateFlag= false;
                        %-------------------------------------------------------------------------------------------------------------------------------------                      
                    end
                end                                                                                   
            end  % End of Mating time                  
        end     % End of LLB elements                    
        clear LLB;                      % Clear memory
        %  Reset the index for minimized llb structures.       
        llbRotCtr  = 1;
        llbSnapCtr = 1;
        llbMatCtr  = 1;
    end         % End of NumAxes
end