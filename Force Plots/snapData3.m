%%************************* Documentation *********************************
% snapData3:
% 1) Loads the force-torque data from file. 
% 2) Not in online implementation: Plots the data in a single plot if plotOptions = 0, or subplots if
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
%**************************************************************************
function [fPath,StratTypeFolder,forceData,stateData,handles,TOP_LIMIT,BOTTOM_LIMIT]...
                                        =snapData3(StrategyType,FolderName,plotOptions)

%% INTIALIZATION
    global DB_PLOT;         % Declared in snapVerification. Enables plotting.
    
    % Switch Flag
    SWITCH = 1;             % Used to determine whether to turn on margin's around plots for extra space when adjusting. 
    
%% Assing appropriate directoy based on Ctrl Strategy to read data files
    StratTypeFolder = AssignDir(StrategyType);
    
    if(ispc)
        fPath = 'C:\\Documents and Settings\\suarezjl\\My Documents\\School\\Research\\AIST\\Results';
    else
        fPath = '/home/grxuser/Documents/School/Research/AIST/Results/';
        % QNX    % '\\home\\hrpuser\forceSensorPlugin_Pivot\Results'; 
    end

%% Load the data
    % Angle data, force data, joint spring data, state data
    [angleData,forceData,jointsnapData,stateData] = loadData(fPath,StratTypeFolder,FolderName);
    
    %----------------------------------------------------------------------
    % The following code plots the data in the Torques.dat file. If running
    % an online system, do not print.
    %----------------------------------------------------------------------
    if(DB_PLOT)    
        %% Plots
        if(DB_PLOT)
            % Different plots may have different durations. The duration in seconds
            % is hard-coded in this function for specific trials. 
            % A percentage is returned to use in scaling the plot axis. 
            [TIME_LIMIT_PERC, SIGNAL_THRESHOLD] = CustomizePlotLength(StrategyType,FolderName,forceData);   
        else
            TIME_LIMIT_PERC = -1; SIGNAL_THRESHOLD = -1;
        end

        %% For PA10 include spring joint angles
        if(~strcmp(StrategyType,'HSA') && ~strcmp(StrategyType,'ErrorCharac'))

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
                [TOP_LIMIT_S1, BOTTOM_LIMIT_S1] = adjustAxes('Rotation Spring',jointsnapData,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE,plotOptions);         
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
            [TOP_LIMIT_S2, BOTTOM_LIMIT_S2] = adjustAxes('Rotation Spring',jointsnapData,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE,plotOptions);  
        end

%% For HIRO no spring joint angles in the camera
%% Plot Fx
        if(plotOptions==1)
            pFx=subplot(3,2,1); plot(forceData(:,1),forceData(:,2));

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;	% uses the average value of data to compute the axis limits. useful for data with big impulses
            [TOP_LIMIT_Fx, BOTTOM_LIMIT_Fx] = adjustAxes('Fx',forceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE,plotOptions);    

        else
            pFx=plot(forceData(:,1),forceData(:,2),'Color',[1 0 0]);
            hold on;
        end
        title('Fx Plot'); xlabel('Time (secs)'); ylabel('Force (N)');
        
%% Plot Fy
        if(plotOptions==1)
            pFy=subplot(3,2,3); plot(forceData(:,1),forceData(:,3));

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;        
            [TOP_LIMIT_Fy, BOTTOM_LIMIT_Fy] = adjustAxes('Fy',forceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE,plotOptions);    

        else
            pFy=plot(forceData(:,1),forceData(:,3),'Color',[0 1 0]);

        end
        title('Fy Plot'); xlabel('Time (secs)'); ylabel('Force (N)');
        
%% Plot Fz
        if(plotOptions==1)    
            pFz=subplot(3,2,5); plot(forceData(:,1),forceData(:,4));

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;    
            [TOP_LIMIT_Fz, BOTTOM_LIMIT_Fz] = adjustAxes('Fz',forceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE,plotOptions);

        else
            pFz=plot(forceData(:,1),forceData(:,4),'Color',[0 0 1]);

        end
        title('Fz Plot'); xlabel('Time (secs)'); ylabel('Force (N)');
        
%% Plot Mx
        if(plotOptions==1)    
            pMx=subplot(3,2,2); plot(forceData(:,1),forceData(:,5));

            % Adjust Axes
            MARGIN = SWITCH;     % If you want to insert a margin into the plots, set true.
            AVERAGE = 0;    % If you want to average the signal value
            [TOP_LIMIT_Mx, BOTTOM_LIMIT_Mx] = adjustAxes('Mx',forceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE,plotOptions);

        else
            pMx=plot(forceData(:,1),forceData(:,5),'Color',[1 1 0]);

        end
        title('Mx Plot'); xlabel('Time (secs)'); ylabel('Moment (N-m)');

%% Plot My
        if(plotOptions==1)    
            pMy=subplot(3,2,4); plot(forceData(:,1),forceData(:,6));

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;    
            [TOP_LIMIT_My, BOTTOM_LIMIT_My] = adjustAxes('My',forceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE,plotOptions);

        else
            pMy=plot(forceData(:,1),forceData(:,6),'Color',[1 0 1]);

        end
        title('My Plot'); xlabel('Time (secs)'); ylabel('Moment (N-m)');
        
%% Plot Mz
        if(plotOptions==1)    
            pMz=subplot(3,2,6); plot(forceData(:,1),forceData(:,7));

            % Adjust Axes
            MARGIN = SWITCH;
            AVERAGE = 0;
            [TOP_LIMIT_Mz, BOTTOM_LIMIT_Mz] = adjustAxes('Mz',forceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE,plotOptions);

        else
            pMz=plot(forceData(:,1),forceData(:,7),'Color',[0 1 1]);
            hold off;

            % Adjust Axes for all FT axes
            MARGIN  = 0;
            AVERAGE = 0;
            [TOP_LIMIT_ALL, BOTTOM_LIMIT_ALL] = adjustAxes('All',forceData,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE,plotOptions);

        end
        title('Mz Plot'); xlabel('Time (secs)'); ylabel('Moment (N-m)');
                        
%% Insert State Lines
        handles         = [pFx pFy pFz pMx pMy pMz];

        if(plotOptions==0)
            if(~strcmp(StrategyType,'HSA') && ~strcmp(StrategyType,'ErrorCharac')) % Include limits for the rotational spring
                TOP_LIMIT       = [TOP_LIMIT_S1     TOP_LIMIT_S2    TOP_LIMIT_ALL   ];
                BOTTOM_LIMIT    = [BOTTOM_LIMIT_S1  BOTTOM_LIMIT_S2 BOTTOM_LIMIT_ALL];
            else
                TOP_LIMIT       = TOP_LIMIT_ALL;
                BOTTOM_LIMIT    = BOTTOM_LIMIT_ALL;              
            end            
        else
            % 8 axes for PA10
            if(~strcmp(StrategyType,'HSA') && ~strcmp(StrategyType,'ErrorCharac')) % Include limits for the rotational spring
                TOP_LIMIT       = [TOP_LIMIT_S1     TOP_LIMIT_S2    TOP_LIMIT_Fx    TOP_LIMIT_Fy    TOP_LIMIT_Fz    TOP_LIMIT_Mx    TOP_LIMIT_My    TOP_LIMIT_Mz];
                BOTTOM_LIMIT    = [BOTTOM_LIMIT_S1  BOTTOM_LIMIT_S2 BOTTOM_LIMIT_Fx BOTTOM_LIMIT_Fy BOTTOM_LIMIT_Fz BOTTOM_LIMIT_Mx BOTTOM_LIMIT_My BOTTOM_LIMIT_Mz];
            % 6 axes for HIRO
            else
                TOP_LIMIT       = [TOP_LIMIT_Fx     TOP_LIMIT_Fy    TOP_LIMIT_Fz    TOP_LIMIT_Mx    TOP_LIMIT_My    TOP_LIMIT_Mz];
                BOTTOM_LIMIT    = [BOTTOM_LIMIT_Fx  BOTTOM_LIMIT_Fy BOTTOM_LIMIT_Fz BOTTOM_LIMIT_Mx BOTTOM_LIMIT_My BOTTOM_LIMIT_Mz];
            end
        end
        
        % Call insertStates
        EndTime = forceData(length(forceData),1);   % Pass the last time element of task as endtime.
        insertStates3(StrategyType,stateData,EndTime,handles,TOP_LIMIT,BOTTOM_LIMIT,plotOptions);    

%% Save plot to file
            savePlot(fPath,StratTypeFolder,FolderName,handles(1),mfilename,plotOptions);
    else
        handles     =-1;
        TOP_LIMIT   =-1;
        BOTTOM_LIMIT=-1;
        
    end % END DB_PRINT.
end     % End the function