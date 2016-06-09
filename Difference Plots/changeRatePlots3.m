function [Path,StratTypeFolder,forceData,handles]=changeRatePlots3(StrategyType,FolderName)

%% Debug Enable Commands
    if(ispc)
        dbstop if error
    elseif(unix)
        %debug_on_warning(1);
        debug_on_error(1);
    end
    
%% Assing appropriate directoy based on Ctrl Strategy 
    StratTypeFolder = AssignDir(StrategyType);
    if(ispc)
        Path = 'C:\\Documents and Settings\\suarezjl\\My Documents\\School\\Research\\AIST\\Results';
    else
       Path = '\\home\\juan\\Documents\\Results\\ForceControl\\PivotApproach'; 
    end

%% Load the data
    % Angle data, force data, joint spring data, state data
    [angleData,forceData,jointsnapData,stateData] = loadData(Path,StratTypeFolder,FolderName);
    
%% Plots
    % Different plots may have different durations. The duration in seconds
    % is hard-coded in this function. A percentage is returned to use in
    % scaling the plot axis. 
    [TIME_LIMIT_PERC, SIGNAL_THRESHOLD] = CustomizePlotLength(FolderName,forceData);
   
%% Computing rates of change for each of the data sets   
[dP dF] = computeDataDifference(angleData,forceData);
        
%% Plot Rotation Spring Joint Position
    P1=subplot(4,2,1); plot(jointsnapData(:,1),jointsnapData(:,2:3) );
    title('Snap Joint Position'); xlabel('Time (secs)'); ylabel('Joint Angle'); 
        
    % Adjust Axes
    MARGIN = 0;    
    AVERAGE = 0;
    [TOP_LIMIT, BOTTOM_LIMIT] = adjustAxes('Rotation Spring',jointsnapData,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);
   
    % Insert state lines
    FillFlag = 1; % fill states with color
    axes(P1);                        % Activate the appropriate subplot
    insertStates(stateData,TOP_LIMIT,BOTTOM_LIMIT,FillFlag);       
    
%%  Repeat
    P2=subplot(4,2,2); plot(jointsnapData(:,1),jointsnapData(:,2:3) );
    title('Snap Joint Position'); xlabel('Time (secs)'); ylabel('Joint Angle'); 
        
    % Adjust Axes
    MARGIN = 0;
    AVERAGE = 0;
    [TOP_LIMIT, BOTTOM_LIMIT] = adjustAxes('Rotation Spring',jointsnapData,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);
    
    % Insert state lines
    axes(P2);                        % Activate the appropriate subplot
    insertStates(stateData,TOP_LIMIT,BOTTOM_LIMIT,FillFlag);    
%% Plot Filtered Fx
    P3=subplot(4,2,3); plot(dF(:,1),dF(:,2));
    title('Differential Fx Plot'); xlabel('Time (secs)'); ylabel('Diff Force (N)');
    
    % Adjust Axes
    MARGIN = 0;
    AVERAGE = 0;        
    [TOP_LIMIT, BOTTOM_LIMIT] = adjustAxes('Fx',dF,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);    
    
    % Insert state lines
    axes(P3);                        % Activate the appropriate subplot
    insertStates(stateData,TOP_LIMIT,BOTTOM_LIMIT,FillFlag);    

%% Plot Filtered Fy
    P5=subplot(4,2,5); plot(dF(:,1),dF(:,3));
    title('Differential Fy Plot'); xlabel('Time (secs)'); ylabel('Diff Force (N)');
    
    % Adjust Axes
    MARGIN = 0;
    AVERAGE = 0;        
    [TOP_LIMIT, BOTTOM_LIMIT] = adjustAxes('Fy',dF,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);    
    
    % Insert state lines
    axes(P5);                        % Activate the appropriate subplot
    insertStates(stateData,TOP_LIMIT,BOTTOM_LIMIT,FillFlag);     
    
%% Plot Filtered Fz
    P7=subplot(4,2,7); plot(dF(:,1),dF(:,4));
    title('Differential Fz Plot'); xlabel('Time (secs)'); ylabel('Diff Force (N)');

    % Adjust Axes
    MARGIN = 0;
    AVERAGE = 0;    
    [TOP_LIMIT, BOTTOM_LIMIT] = adjustAxes('Fz',dF,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);
    
    % Insert state lines
    axes(P7);                        % Activate the appropriate subplot
    insertStates(stateData,TOP_LIMIT,BOTTOM_LIMIT,FillFlag);         
    
%% Plot Filtered Mx
    P4=subplot(4,2,4); plot(dF(:,1),dF(:,5));
    title('Differential Mx Plot'); xlabel('Time (secs)'); ylabel('Moment (N-m)');
   
    % Adjust Axes
    MARGIN = 0;
    AVERAGE = 1;    
    [TOP_LIMIT, BOTTOM_LIMIT] = adjustAxes('Mx',dF,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);

    % Insert state lines
    axes(P4);                        % Activate the appropriate subplot
    insertStates(stateData,TOP_LIMIT,BOTTOM_LIMIT,FillFlag);    
    
%% Plot Filtered My
    P6=subplot(4,2,6); plot(dF(:,1),dF(:,6));
    title('Differential My Plot'); xlabel('Time (secs)'); ylabel('Moment (N-m)');
   
    % Adjust Axes
    MARGIN = 0;
    AVERAGE = 1;    
    [TOP_LIMIT, BOTTOM_LIMIT] = adjustAxes('My',dF,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);

    % Insert state lines
    axes(P6);                        % Activate the appropriate subplot
    insertStates(stateData,TOP_LIMIT,BOTTOM_LIMIT,FillFlag);        
    
%% Plot Filtered Mz
    P8=subplot(4,2,8); plot(dF(:,1),dF(:,7));
    title('Differential Mz Plot'); xlabel('Time (secs)'); ylabel('Moment (N-m)');

    % Adjust Axes
    MARGIN = 0;
    AVERAGE = 1;
    [TOP_LIMIT, BOTTOM_LIMIT] = adjustAxes('Mz',dF,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);
   
    % Insert state lines
    axes(P8);                        % Activate the appropriate subplot
    insertStates(stateData,TOP_LIMIT,BOTTOM_LIMIT,FillFlag);        

%% Create Plot Handles Structure
    handles = [pFx pFy pFz pMx pMy pMz pSJ];
    
%% Save plot to file
	savePlot(Path,StratTypeFolder,FolderName,P1,mfilename)
end    