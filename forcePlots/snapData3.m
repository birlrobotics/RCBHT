%%************************* Documentation *********************************
% snapData3:
% 1) Loads the force-torque data from file for right arm by default, for
% left arm if included.
% 2) Optionally it can include cartesian position and joint angle position.
% 3) Not in online implementation: Plots the data in a single plot if plotOptions = 0, or subplots if
% plotOptions = 1. 
% All plots are ajusted for best viewing peformance:
% - TOP & BOTTOM max limits
% - Duration of plots
%
% Input Parameters:
% StrategyType:     - Changes code according to strategy type, ie. 'HSA'
% FolderName:       - Folder where data is saved
% plotOptions:      - tells whether plots should be graphed in subplots or
%                     not.
% rarmHandle:       - handle for plot for right arm. 
% larmHandle:       - same for left arm
%
% Output Parameters:
% fPath:            - Path to results folder
% StratTypeFolder:  - Folder name for given strategy
% ForceData(L):     - Matrix with force data over time
% angleData(L):     - Matrix with robot joint angle data
% cartPosData(L):   - Matrix with cartesian pose information
% stateData:        - vector of times for different states of the task
% handles:          - vector of handles for six force plots for right hand
% handles:          - same but for left arm
% TOP_LIMIT:        - vector holding upper plot (+y) limits for 6 right arm
%                     force.
% TOP_LIMIT_L:      - same but for left arm.  
% BOTTOM_LIMIT:     - same as above but for lower plot limits
% BOTTOM_LIMIT_L:   - same for left arm.
%
% TODO: we will need to expand plot options to know how to plot angleData,
% cartesian position data, left arm data, etc. This may become a structure
% in the future.
%**************************************************************************
function [fPath,StratTypeFolder,...
          ForceData,...
          angleData,...
          cartPosData,...
          stateData,...
          handles,...
          TOP_LIMIT,BOTTOM_LIMIT]=snapData3(StrategyType,FolderName,plotOptions)

%% INTIALIZATION
    % These globals are declared in snapVerification.
    global DB_PLOT;                         % Enables plotting.
    
    % Paths
    global hiroPath;                        % Sets the global path for results
    global baxterPath;
    
    % Data
    % global anglesDataFlag;                % Enable loading/printing of current joint angles
    % global cartposDataFlag;               % Same for cartesian position of end effector
    % global local0_world1_coords;          % Sets wrench data to load/plot wrt end-effector or world coordinates
    
    % Arm Side Detection
    global armSide;                         % Indicates which arms are available.
    global currentArm;                      % Indicates which are is currently being used.
    global rarmHandle;                      % handles to right/left arm
    global larmHandle;
    
    % Switch Flag
    SWITCH = 1;                             % Used to determine whether to turn on margin's around plots for extra space when adjusting.     
    
        
%% Assing appropriate directoy based on Ctrl Strategy to read data files
    StratTypeFolder = AssignDir(StrategyType);
    hiroPath='/home/vmrguser/research/AIST/Results/'; % The path at which you want to save the main body of results. Folders will be created within this folder for different strategyTypes.
    baxterPath='/home/vmrguser/ros/indigo/baxter_ws/src/birl_baxter/birl_demos/pivotApproach/pa_demo/bags/';    
    if(strategySelector('hiro',StrategyType))
        fPath = hiroPath;
    elseif(strategySelector('baxter',StrategyType))
        fPath=baxterPath;
    end       
    % QNX  fPath='\\home\\hrpuser\forceSensorPlugin_Pivot\Results/'; 
  
%% Load the data
    % Has 4 variables for each arm starting with the right arm:
    % Angle data, cartesian data, force data (local or world depending on flag),
    % Then it has two final variables: joint spring data (snap part angle), state time vector data
    
    [angleData,cartPosData,ForceData,jointsnapData,stateData] = loadData(fPath,StrategyType,StratTypeFolder,FolderName);%anglesDataFlag,cartposDataFlag,local0_world1_coords,leftArmDataFlag);
   
    %----------------------------------------------------------------------
    % The following code plots the data in the Torques.dat file. If running
    % an online system, do not print.
    %---------------------------------------------------------------------- 
    %% Plots
    if(strategySelector('PA',StrategyType))
        % Different plots may have different durations. The duration in seconds
        % is hard-coded in this function for specific trials. 
        % A percentage is returned to use in scaling the plot axis
        % for PA10 experiments.
        [TIME_LIMIT_PERC, SIGNAL_THRESHOLD] = CustomizePlotLength(StrategyType,FolderName,ForceData);   
    else
        TIME_LIMIT_PERC =1;
        SIGNAL_THRESHOLD=50;
    end
    
    %% For PA10 performing PA/SA include spring joint angles
    if(strategySelector('pa10',StrategyType))

        %% Plot Rotation Spring Joint Position
        if(DB_PLOT)
            if(plotOptions)
                pSJ1=subplot(4,2,1); plot(jointsnapData(:,1),jointsnapData(:,2:3) );
            else
                figure(1); plot(jointsnapData(:,1),jointsnapData(:,2:3) );
                pSJ1 = gca;
            end
            title('Snap Joint Position'); xlabel('Time (secs)'); ylabel('Joint Angle'); 
        else
            pSJ1=-1;
        end

        % Adjust Axes
        MARGIN = SWITCH;    
        AVERAGE = 0;
        [TOP_LIMIT_S1, BOTTOM_LIMIT_S1] = adjustAxes('Rotation Spring',jointsnapData,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);         

        %%  Repeat
        if(DB_PLOT)
            if(plotOptions)
                pSJ2=subplot(4,2,2); plot(jointsnapData(:,1),jointsnapData(:,2:3) );
            else
                figure(2); plot(jointsnapData(:,1),jointsnapData(:,2:3) );
                pSJ2=gca;
            end
            title('Snap Joint Position'); xlabel('Time (secs)'); ylabel('Joint Angle'); 
        else
            psJ2=-1;
        end

        % Adjust Axes
        MARGIN = SWITCH;
        AVERAGE = 0;
        [TOP_LIMIT_S2, BOTTOM_LIMIT_S2] = adjustAxes('Rotation Spring',jointsnapData,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);  
    end

    if(strategySelector('hiro',StrategyType) || strategySelector('baxter',StrategyType))
        %% For HIRO|BAXTER no spring joint angles in the camera: Right Arm
        %  Create plots for right arm and if necessary for left arm as well.
        if(armSide(1,2) && currentArm==2) % Right arm

            if(DB_PLOT)
                figure(rarmHandle);  % Refocus plot for right arm.
                %% Plot Fx
                if(plotOptions==1)
                    pFx=subplot(3,2,1); plot(ForceData(:,1),ForceData(:,2));
                else
                    pFx=plot(ForceData(:,1),ForceData(:,2));
                end
                title('Fx Plot for the Right Arm'); xlabel('Time (secs)'); ylabel('Force (N)');
            else
                pFx=-1;
            end

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;	% uses the average value of data to compute the axis limits. useful for data with big impulses
            [TOP_LIMIT_Fx, BOTTOM_LIMIT_Fx] = adjustAxes('Fx',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);    

            %% Plot Fy
            if(DB_PLOT)
                if(plotOptions==1)
                    pFy=subplot(3,2,3); plot(ForceData(:,1),ForceData(:,3));
                else
                    pFy=plot(ForceData(:,1),ForceData(:,3));
                end
                title('Fy Plot for the Right Arm'); xlabel('Time (secs)'); ylabel('Force (N)');
            else
                pFy=-1;
            end

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;        
            [TOP_LIMIT_Fy, BOTTOM_LIMIT_Fy] = adjustAxes('Fy',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);    

            %% Plot Fz
            if(DB_PLOT)
                if(plotOptions==1)    
                    pFz=subplot(3,2,5); plot(ForceData(:,1),ForceData(:,4));
                else
                    pFz=plot(ForceData(:,1),ForceData(:,4));
                end
                title('Fz Plot for the Right Arm'); xlabel('Time (secs)'); ylabel('Force (N)');
            else
                pFz=-1;
            end

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;    
            [TOP_LIMIT_Fz, BOTTOM_LIMIT_Fz] = adjustAxes('Fz',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);

            %% Plot Mx
            if(DB_PLOT)
                if(plotOptions==1)    
                    pMx=subplot(3,2,2); plot(ForceData(:,1),ForceData(:,5));
                else
                    pMx=plot(ForceData(:,1),ForceData(:,5));
                end
                title('Mx Plot for the Right Arm'); xlabel('Time (secs)'); ylabel('Moment (N-m)');
            else
                pMx=-1;
            end

            % Adjust Axes
            MARGIN = SWITCH;     % If you want to insert a margin into the plots, set true.
            AVERAGE = 0;    % If you want to average the signal value
            [TOP_LIMIT_Mx, BOTTOM_LIMIT_Mx] = adjustAxes('Mx',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);


            %% Plot My
            if(DB_PLOT)
                if(plotOptions==1)    
                    pMy=subplot(3,2,4); plot(ForceData(:,1),ForceData(:,6));
                else
                    pMy=plot(ForceData(:,1),ForceData(:,6));
                end
                title('My Plot for the Right Arm'); xlabel('Time (secs)'); ylabel('Moment (N-m)');
            else
                pMy=-1;
            end
            
            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;    
            [TOP_LIMIT_My, BOTTOM_LIMIT_My] = adjustAxes('My',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);

            %% Plot Mz
            if(DB_PLOT)
                if(plotOptions==1)    
                    pMz=subplot(3,2,6); plot(ForceData(:,1),ForceData(:,7));
                else
                    pMz=plot(ForceData(:,1),ForceData(:,7));
                end
                title('Mz Plot for the Right Arm'); xlabel('Time (secs)'); ylabel('Moment (N-m)');
            else
                pMz=-1;
            end

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;
            [TOP_LIMIT_Mz, BOTTOM_LIMIT_Mz] = adjustAxes('Mz',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);

            %% Insert State Lines
            handles         = [pFx pFy pFz pMx pMy pMz];

            % 8 axes for PA10
            if(strategySelector('PA',StrategyType))         % 'PA' stands for PivotApproach. This strat uses 5 states. The function will be set to true for a number of strategy types that belong to this category.
                TOP_LIMIT       = [TOP_LIMIT_S1 TOP_LIMIT_S2 TOP_LIMIT_Fx TOP_LIMIT_Fy TOP_LIMIT_Fz TOP_LIMIT_Mx TOP_LIMIT_My TOP_LIMIT_Mz];
                BOTTOM_LIMIT    = [BOTTOM_LIMIT_S1 BOTTOM_LIMIT_S2 BOTTOM_LIMIT_Fx BOTTOM_LIMIT_Fy BOTTOM_LIMIT_Fz BOTTOM_LIMIT_Mx BOTTOM_LIMIT_My BOTTOM_LIMIT_Mz];
            % 6 axes for HIRO
            else
                TOP_LIMIT       = [TOP_LIMIT_Fx TOP_LIMIT_Fy TOP_LIMIT_Fz TOP_LIMIT_Mx TOP_LIMIT_My TOP_LIMIT_Mz];
                BOTTOM_LIMIT    = [BOTTOM_LIMIT_Fx BOTTOM_LIMIT_Fy BOTTOM_LIMIT_Fz BOTTOM_LIMIT_Mx BOTTOM_LIMIT_My BOTTOM_LIMIT_Mz];
            end
        end   

        %% Print for left Arm
        if(armSide(1,1) && currentArm==1)

            if(DB_PLOT)
                % Refocus the left arm figure      
                figure(larmHandle);         

                %% Plot Fx
                if(plotOptions==1)
                    pFxL=subplot(3,2,1); plot(ForceData(:,1),ForceData(:,2));
                else
                    pFxL=plot(ForceData(:,1),ForceData(:,2));
                end
                title('Fx Plot for the Left Arm'); xlabel('Time (secs)'); ylabel('Force (N)');
            else
                pFxL=-1;
            end

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;	% uses the average value of data to compute the axis limits. useful for data with big impulses
            [TOP_LIMIT_Fx_L, BOTTOM_LIMIT_Fx_L] = adjustAxes('Fx',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);    

            %% Plot Fy
            if(DB_PLOT)
                if(plotOptions==1)
                    pFyL=subplot(3,2,3); plot(ForceData(:,1),ForceData(:,3));
                else
                    pFyL=plot(ForceData(:,1),ForceData(:,3));
                end
                title('Fy Plot for the Left Arm'); xlabel('Time (secs)'); ylabel('Force (N)');
            else
                pFyL=-1;
            end

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;        
            [TOP_LIMIT_Fy_L, BOTTOM_LIMIT_Fy_L] = adjustAxes('Fy',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);    

            %% Plot Fz
            if(DB_PLOT)
                if(plotOptions==1)    
                    pFzL=subplot(3,2,5); plot(ForceData(:,1),ForceData(:,4));
                else
                    pFzL=plot(ForceData(:,1),ForceData(:,4));
                end
                title('Fz Plot for the Left Arm'); xlabel('Time (secs)'); ylabel('Force (N)');
            else
                pFzL=-1;
            end

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;    
            [TOP_LIMIT_Fz_L, BOTTOM_LIMIT_Fz_L] = adjustAxes('Fz',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);

            %% Plot Mx
            if(DB_PLOT)
                if(plotOptions==1)    
                    pMxL=subplot(3,2,2); plot(ForceData(:,1),ForceData(:,5));
                else
                    pMxL=plot(ForceData(:,1),ForceData(:,5));
                end
                title('Mx Plot for the Left Arm'); xlabel('Time (secs)'); ylabel('Moment (N-m)');
            else
                pMxL=-1;
            end

            % Adjust Axes
            MARGIN = SWITCH;     % If you want to insert a margin into the plots, set true.
            AVERAGE = 0;    % If you want to average the signal value
            [TOP_LIMIT_Mx_L, BOTTOM_LIMIT_Mx_L] = adjustAxes('Mx',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);


            %% Plot My
            if(DB_PLOT)
                if(plotOptions==1)    
                    pMyL=subplot(3,2,4); plot(ForceData(:,1),ForceData(:,6));
                else
                    pMyL=plot(ForceData(:,1),ForceData(:,6));
                end
                title('My Plot for the Left Arm'); xlabel('Time (secs)'); ylabel('Moment (N-m)');
            else
                pMyL=-1;
            end

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;    
            [TOP_LIMIT_My_L, BOTTOM_LIMIT_My_L] = adjustAxes('My',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);

            %% Plot Mz
            if(DB_PLOT)
                if(plotOptions==1)    
                    pMzL=subplot(3,2,6); plot(ForceData(:,1),ForceData(:,7));
                else
                    pMzL=plot(ForceData(:,1),ForceData(:,7));
                end
                title('Mz Plot for the Left Arm'); xlabel('Time (secs)'); ylabel('Moment (N-m)');
            else
                pMzL=-1;
            end

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;
            [TOP_LIMIT_Mz_L, BOTTOM_LIMIT_Mz_L] = adjustAxes('Mz',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);
            
            %% Insert State Lines
            handles         = [pFxL pFyL pFzL pMxL pMyL pMzL];

            % 8 axes for PA10
            if(strategySelector('PA',StrategyType))         % 'PA' stands for PivotApproach. This strat uses 5 states. The function will be set to true for a number of strategy types that belong to this category.
                TOP_LIMIT       = [TOP_LIMIT_S1,      TOP_LIMIT_S2,   TOP_LIMIT_Fx_L,    TOP_LIMIT_Fy_L,     TOP_LIMIT_Fz_L,     TOP_LIMIT_Mx_L,     TOP_LIMIT_My_L,     TOP_LIMIT_Mz_L];
                BOTTOM_LIMIT    = [BOTTOM_LIMIT_S1,   BOTTOM_LIMIT_S2,BOTTOM_LIMIT_Fx_L, BOTTOM_LIMIT_Fy_L,  BOTTOM_LIMIT_Fz_L,  BOTTOM_LIMIT_Mx_L,  BOTTOM_LIMIT_My_L,  BOTTOM_LIMIT_Mz_L];

            % 6 axes for HIRO/BAXTER
            else
                TOP_LIMIT       = [TOP_LIMIT_Fx_L,    TOP_LIMIT_Fy_L,     TOP_LIMIT_Fz_L,     TOP_LIMIT_Mx_L,     TOP_LIMIT_My_L,     TOP_LIMIT_Mz_L];
                BOTTOM_LIMIT    = [BOTTOM_LIMIT_Fx_L, BOTTOM_LIMIT_Fy_L,  BOTTOM_LIMIT_Fz_L,  BOTTOM_LIMIT_Mx_L,  BOTTOM_LIMIT_My_L,  BOTTOM_LIMIT_Mz_L];
            end           
        end % Left Arm Printing    
        
        if(DB_PLOT)
             % Call insertStates
            EndTime = ForceData(length(ForceData),1);   % Pass the last time element of task as endtime.
            insertStates3(StrategyType,stateData,EndTime,handles,TOP_LIMIT,BOTTOM_LIMIT);    

            %% Save plot to file
            mfilename='snapData3';            
            savePlot(fPath,StratTypeFolder,FolderName,handles(1),mfilename);
        end
    end     % HIRO/BAXTER
end             % End the function
