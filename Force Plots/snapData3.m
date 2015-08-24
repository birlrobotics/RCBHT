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
% plotOptions       - tells whether plots should be graphed in subplots or
%                     not.
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
% TOP_LIMIT         - vector holding upper plot (+y) limits for 6 right arm
%                     force plots
% BOTTOM_LIMIT:     - same as above but for lower plot limits
%
%
% TODO: we will need to expand plot options to know how to plot angleData,
% cartesian position data, left arm data, etc. This may become a structure
% in the future.
%**************************************************************************
function [fPath,StratTypeFolder,...
          ForceData,ForceDataL,...
          angleData,angleDataL,...
          cartPosData,cartPosDataL,...
          stateData,handles,handlesL,...
          TOP_LIMIT,BOTTOM_LIMIT]=snapData3(StrategyType,FolderName,plotOptions)

%% INTIALIZATION
    % These globals are declared in snapVerification.
    global DB_PLOT;                         % Enables plotting.
    
    % Data
    % global anglesDataFlag;                % Enable loading/printing of current joint angles
    % global cartposDataFlag;               % Same for cartesian position of end effector
    % global local0_world1_coords;          % Sets wrench data to load/plot wrt end-effector or world coordinates
    
    % Left Arm
    global leftArmDataFlag;                 % Enables to load/plot left arm data. 
    global armSide;                         % Tells us whether we are working with the right or left arm. Useful to plot the right figures and save data to the right file.
    
    % Figure Handles
    %global rarmHandle;
    global larmHandle;                      % Used to get left arm plots handle. Needed to make sure we plot data to the write place.
    
    % Switch Flag
    SWITCH = 1;                             % Used to determine whether to turn on margin's around plots for extra space when adjusting.     
    
%% Assing appropriate directoy based on Ctrl Strategy to read data files
    StratTypeFolder = AssignDir(StrategyType);
    
    if(ispc)
        fPath = 'C:\\Documents and Settings\\suarezjl\\My Documents\\School\\Research\\AIST\\Results';
    else
        fPath = '/home/grxuser/Documents/School/Research/AIST/Results/';
        % QNX    % '\\home\\hrpuser\forceSensorPlugin_Pivot\Results'; 
    end

%% Load the data
    % Has 4 variables for each arm starting with the right arm:
    % Angle data, cartesian data, force data (local or world depending on flag),
    % Then it has two final variables: joint spring data (snap part angle), state time vector data
    % For one arm, default right:
    if ~strcmp(StrategyType,'SIM_SA_DualArm')
        [angleData,cartPosData,ForceData,~,~,~,~,jointsnapData,stateData] = loadData(fPath,StratTypeFolder,FolderName);%,...
                                                                                     %anglesDataFlag,cartposDataFlag,local0_world1_coords,leftArmDataFlag);
    
    % For two arms, left and right.
    else
         [angleData, cartPosData, ForceData, ...
          angleDataL,cartPosDataL,ForceDataL,...
                                  jointsnapData,stateData] = loadData(fPath,StratTypeFolder,FolderName);%,...
                                                                      %anglesDataFlag,cartposDataFlag,local0_world1_coords,leftArmDataFlag);
    end
    %----------------------------------------------------------------------
    % The following code plots the data in the Torques.dat file. If running
    % an online system, do not print.
    %----------------------------------------------------------------------
    if(DB_PLOT)    
        %% Plots
        if(DB_PLOT)
            % Different plots may have different durations. The duration in seconds
            % is hard-coded in this function for specific trials. 
            % A percentage is returned to use in scaling the plot axis
            % for PA10 experiments.
            [TIME_LIMIT_PERC, SIGNAL_THRESHOLD] = CustomizePlotLength(StrategyType,FolderName,ForceData);   
        else
            TIME_LIMIT_PERC = -1; SIGNAL_THRESHOLD = -1;
        end

        %% For PA10 include spring joint angles
        if(~strcmp(StrategyType,'SIM_SideApproach') && ~strcmp(StrategyType(1:12),'SIM_SA_Error') && ~strcmp(StrategyType,'SIM_SA_DualArm'))

        %% Plot Rotation Spring Joint Position
            if(plotOptions)
                pSJ1=subplot(4,2,1); plot(jointsnapData(:,1),jointsnapData(:,2:3) );
            else
                figure(1); plot(jointsnapData(:,1),jointsnapData(:,2:3) );
                pSJ1 = gca;
            end
            title('Snap Joint Position'); xlabel('Time (secs)'); ylabel('Joint Angle'); 

            % Adjust Axes
            MARGIN = SWITCH;    
            AVERAGE = 0;
            if(DB_PLOT)
                [TOP_LIMIT_S1, BOTTOM_LIMIT_S1] = adjustAxes('Rotation Spring',jointsnapData,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);         
            else
                TOP_LIMIT_S1 = -1; BOTTOM_LIMIT_S1 = -1;
            end

        %%  Repeat
            if(plotOptions)
                pSJ2=subplot(4,2,2); plot(jointsnapData(:,1),jointsnapData(:,2:3) );
            else
                figure(2); plot(jointsnapData(:,1),jointsnapData(:,2:3) );
                pSJ2=gca;
            end
            title('Snap Joint Position'); xlabel('Time (secs)'); ylabel('Joint Angle'); 

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;
            [TOP_LIMIT_S2, BOTTOM_LIMIT_S2] = adjustAxes('Rotation Spring',jointsnapData,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);  
        end

%% For HIRO no spring joint angles in the camera: Right Arm
        %  Create plots for right arm and if necessary for left arm as well.
        %% Plot Fx
        if(plotOptions==1)
            pFx=subplot(3,2,1); plot(ForceData(:,1),ForceData(:,2));
        else
            pFx=plot(ForceData(:,1),ForceData(:,2));
        end
        title('Fx Plot for the Right Arm'); xlabel('Time (secs)'); ylabel('Force (N)');

        % Adjust Axes
        MARGIN = SWITCH;
        AVERAGE = 0;	% uses the average value of data to compute the axis limits. useful for data with big impulses
        [TOP_LIMIT_Fx, BOTTOM_LIMIT_Fx] = adjustAxes('Fx',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);    

        %% Plot Fy
        if(plotOptions==1)
            pFy=subplot(3,2,3); plot(ForceData(:,1),ForceData(:,3));
        else
            pFy=plot(ForceData(:,1),ForceData(:,3));
        end
        title('Fy Plot for the Right Arm'); xlabel('Time (secs)'); ylabel('Force (N)');

        % Adjust Axes
        MARGIN = SWITCH;
        AVERAGE = 0;        
        [TOP_LIMIT_Fy, BOTTOM_LIMIT_Fy] = adjustAxes('Fy',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);    

        %% Plot Fz
        if(plotOptions==1)    
            pFz=subplot(3,2,5); plot(ForceData(:,1),ForceData(:,4));
        else
            pFz=plot(ForceData(:,1),ForceData(:,4));
        end
        title('Fz Plot for the Right Arm'); xlabel('Time (secs)'); ylabel('Force (N)');

        % Adjust Axes
        MARGIN = SWITCH;
        AVERAGE = 0;    
        [TOP_LIMIT_Fz, BOTTOM_LIMIT_Fz] = adjustAxes('Fz',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);

        %% Plot Mx
        if(plotOptions==1)    
            pMx=subplot(3,2,2); plot(ForceData(:,1),ForceData(:,5));
        else
            pMx=plot(ForceData(:,1),ForceData(:,5));
        end
        title('Mx Plot for the Right Arm'); xlabel('Time (secs)'); ylabel('Moment (N-m)');

        % Adjust Axes
        MARGIN = SWITCH;     % If you want to insert a margin into the plots, set true.
        AVERAGE = 0;    % If you want to average the signal value
        [TOP_LIMIT_Mx, BOTTOM_LIMIT_Mx] = adjustAxes('Mx',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);


        %% Plot My
        if(plotOptions==1)    
            pMy=subplot(3,2,4); plot(ForceData(:,1),ForceData(:,6));
        else
            pMy=plot(ForceData(:,1),ForceData(:,6));
        end
        title('My Plot for the Right Arm'); xlabel('Time (secs)'); ylabel('Moment (N-m)');

        % Adjust Axes
        MARGIN = SWITCH;
        AVERAGE = 0;    
        [TOP_LIMIT_My, BOTTOM_LIMIT_My] = adjustAxes('My',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);

        %% Plot Mz
        if(plotOptions==1)    
            pMz=subplot(3,2,6); plot(ForceData(:,1),ForceData(:,7));
        else
            pMz=plot(ForceData(:,1),ForceData(:,7));
        end
        title('Mz Plot for the Right Arm'); xlabel('Time (secs)'); ylabel('Moment (N-m)');

        % Adjust Axes
        MARGIN = SWITCH;
        AVERAGE = 0;
        [TOP_LIMIT_Mz, BOTTOM_LIMIT_Mz] = adjustAxes('Mz',ForceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);

        %% Insert State Lines
        handles         = [pFx pFy pFz pMx pMy pMz];

        % 8 axes for PA10
        if(~strcmp(StrategyType,'SIM_SideApproach') && ~strcmp(StrategyType(1:12),'SIM_SA_Error') && ~strcmp(StrategyType,'SIM_SA_DualArm')) % Include limits for the rotational spring
            TOP_LIMIT       = [TOP_LIMIT_S1 TOP_LIMIT_S2 TOP_LIMIT_Fx TOP_LIMIT_Fy TOP_LIMIT_Fz TOP_LIMIT_Mx TOP_LIMIT_My TOP_LIMIT_Mz];
            BOTTOM_LIMIT    = [BOTTOM_LIMIT_S1 BOTTOM_LIMIT_S2 BOTTOM_LIMIT_Fx BOTTOM_LIMIT_Fy BOTTOM_LIMIT_Fz BOTTOM_LIMIT_Mx BOTTOM_LIMIT_My BOTTOM_LIMIT_Mz];
        % 6 axes for HIRO
        else
            TOP_LIMIT       = [TOP_LIMIT_Fx TOP_LIMIT_Fy TOP_LIMIT_Fz TOP_LIMIT_Mx TOP_LIMIT_My TOP_LIMIT_Mz];
            BOTTOM_LIMIT    = [BOTTOM_LIMIT_Fx BOTTOM_LIMIT_Fy BOTTOM_LIMIT_Fz BOTTOM_LIMIT_Mx BOTTOM_LIMIT_My BOTTOM_LIMIT_Mz];
        end
        % Call insertStates
        EndTime = ForceData(length(ForceData),1);   % Pass the last time element of task as endtime.
        insertStates3(StrategyType,stateData,EndTime,handles,TOP_LIMIT,BOTTOM_LIMIT);    

        %% Save plot to file
        mfilename='snapData3';
        savePlot(fPath,StratTypeFolder,FolderName,handles(1),mfilename);

        %% Print for left Arm    
        % Open a figure used to plot data on the left arm.      
        figure(larmHandle); 
        
        if(leftArmDataFlag)
            %% Plot Fx
            if(plotOptions==1)
                pFxL=subplot(3,2,1); plot(ForceDataL(:,1),ForceDataL(:,2));
            else
                pFxL=plot(ForceData(:,1),ForceData(:,2));
            end
            title('Fx Plot for the Left Arm'); xlabel('Time (secs)'); ylabel('Force (N)');

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;	% uses the average value of data to compute the axis limits. useful for data with big impulses
            [TOP_LIMIT_Fx_L, BOTTOM_LIMIT_Fx_L] = adjustAxes('Fx',ForceDataL,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);    

            %% Plot Fy
            if(plotOptions==1)
                pFyL=subplot(3,2,3); plot(ForceDataL(:,1),ForceDataL(:,3));
            else
                pFyL=plot(ForceDataL(:,1),ForceDataL(:,3));
            end
            title('Fy Plot for the Left Arm'); xlabel('Time (secs)'); ylabel('Force (N)');

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;        
            [TOP_LIMIT_Fy_L, BOTTOM_LIMIT_Fy_L] = adjustAxes('Fy',ForceDataL,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);    

            %% Plot Fz
            if(plotOptions==1)    
                pFzL=subplot(3,2,5); plot(ForceDataL(:,1),ForceDataL(:,4));
            else
                pFzL=plot(ForceDataL(:,1),ForceDataL(:,4));
            end
            title('Fz Plot for the Left Arm'); xlabel('Time (secs)'); ylabel('Force (N)');

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;    
            [TOP_LIMIT_Fz_L, BOTTOM_LIMIT_Fz_L] = adjustAxes('Fz',ForceDataL,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);

            %% Plot Mx
            if(plotOptions==1)    
                pMxL=subplot(3,2,2); plot(ForceDataL(:,1),ForceDataL(:,5));
            else
                pMxL=plot(ForceDataL(:,1),ForceDataL(:,5));
            end
            title('Mx Plot for the Left Arm'); xlabel('Time (secs)'); ylabel('Moment (N-m)');

            % Adjust Axes
            MARGIN = SWITCH;     % If you want to insert a margin into the plots, set true.
            AVERAGE = 0;    % If you want to average the signal value
            [TOP_LIMIT_Mx_L, BOTTOM_LIMIT_Mx_L] = adjustAxes('Mx',ForceDataL,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);


            %% Plot My
            if(plotOptions==1)    
                pMyL=subplot(3,2,4); plot(ForceDataL(:,1),ForceDataL(:,6));
            else
                pMyL=plot(ForceDataL(:,1),ForceDataL(:,6));
            end
            title('My Plot for the Left Arm'); xlabel('Time (secs)'); ylabel('Moment (N-m)');

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;    
            [TOP_LIMIT_My_L, BOTTOM_LIMIT_My_L] = adjustAxes('My',ForceDataL,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);

            %% Plot Mz
            if(plotOptions==1)    
                pMzL=subplot(3,2,6); plot(ForceDataL(:,1),ForceDataL(:,7));
            else
                pMzL=plot(ForceDataL(:,1),ForceDataL(:,7));
            end
            title('Mz Plot for the Left Arm'); xlabel('Time (secs)'); ylabel('Moment (N-m)');

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;
            [TOP_LIMIT_Mz_L, BOTTOM_LIMIT_Mz_L] = adjustAxes('Mz',ForceDataL,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);

            %% Insert State Lines
            handlesL         = [pFxL pFyL pFzL pMxL pMyL pMzL];

            % 8 axes for PA10
            if(~strcmp(StrategyType,'SIM_SideApproach') && ~strcmp(StrategyType(1:12),'SIM_SA_Error') && ~strcmp(StrategyType,'SIM_SA_DualArm')) % Include limits for the rotational spring
                TOP_LIMIT_L       = [TOP_LIMIT_S1,      TOP_LIMIT_S2,   TOP_LIMIT_Fx_L,    TOP_LIMIT_Fy_L,     TOP_LIMIT_Fz_L,     TOP_LIMIT_Mx_L,     TOP_LIMIT_My_L,     TOP_LIMIT_Mz_L];
                BOTTOM_LIMIT_L    = [BOTTOM_LIMIT_S1,   BOTTOM_LIMIT_S2,BOTTOM_LIMIT_Fx_L, BOTTOM_LIMIT_Fy_L,  BOTTOM_LIMIT_Fz_L,  BOTTOM_LIMIT_Mx_L,  BOTTOM_LIMIT_My_L,  BOTTOM_LIMIT_Mz_L];
            % 6 axes for HIRO
            else
                TOP_LIMIT_L       = [TOP_LIMIT_Fx_L,    TOP_LIMIT_Fy_L,     TOP_LIMIT_Fz_L,     TOP_LIMIT_Mx_L,     TOP_LIMIT_My_L,     TOP_LIMIT_Mz_L];
                BOTTOM_LIMIT_L    = [BOTTOM_LIMIT_Fx_L, BOTTOM_LIMIT_Fy_L,  BOTTOM_LIMIT_Fz_L,  BOTTOM_LIMIT_Mx_L,  BOTTOM_LIMIT_My_L,  BOTTOM_LIMIT_Mz_L];
            end
            
            % Call insertStates
            EndTime = ForceDataL(length(ForceDataL),1);   % Pass the last time element of task as endtime.
            insertStates3(StrategyType,stateData,EndTime,handlesL,TOP_LIMIT_L,BOTTOM_LIMIT_L);    

            %% Save plot to file
            mfilename='snapData3';
            armSide = 2;    % armSide normally changes in the snapVerification.m::for loop. So to avoid further changes to savePlot we modify 
                            % armSide as a global variable to save the plot with the right name for the left arm. armSide will be reset in the for loop. 
            savePlot(fPath,StratTypeFolder,FolderName,handlesL(1),mfilename);
        end % Left Arm Printing
    end % END DB_PRINT. 
end     % End the function