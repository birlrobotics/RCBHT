function changeRatePlots(StrategyType,FolderName)

%% Debug Enable Commands
    %debug_on_warning(1);
    %debug_on_error(1);

%% Assing appropriate directoy based on Ctrl Strategy 
    StratTypeFolder = AssignDir(StrategyType);
    Path = 'C:\\Documents and Settings\\suarezjl\\My Documents\\School\\Research\\AIST\\Results';

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
    P1=subplot(3,1,1); plot(jointsnapData(:,1),jointsnapData(:,2:3) );
    title('Snap Joint Position'); xlabel('Time (secs)'); ylabel('Joint Angle'); 
        
    % Adjust Axes
    MARGIN = 0;    
    AVERAGE = 0;
    [TOP_LIMIT, BOTTOM_LIMIT] = adjustAxes('Rotation Spring',jointsnapData,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);
       
    % Insert state lines
    FillFlag = 1; % Fill states with color
    set(P1);                        % Activate the appropriate subplot
    insertStates(stateData,TOP_LIMIT,BOTTOM_LIMIT,FillFlag);       
%% Plot Filtered Force
    P2=subplot(3,1,2); plot(dF(:,1),dF(:,2:4));
    title('Differential Force Plot'); xlabel('Time (secs)'); ylabel('Diff Force (N)');
    
    % Adjust Axes
    MARGIN = 0;
    AVERAGE = 0;        
    [TOP_LIMIT, BOTTOM_LIMIT] = adjustAxes('Force Plot',dF,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);    
    
    % Insert state lines
    set(P2);                        % Activate the appropriate subplot
    insertStates(stateData,TOP_LIMIT,BOTTOM_LIMIT,FillFlag);    
%% Plot Filtered Moment
    P3=subplot(3,1,3); plot(dF(:,1),dF(:,5:7));
    title('Filtered Moment Plot'); xlabel('Time (secs)'); ylabel('Moment (N-m)');

    % Adjust Axes
    MARGIN = 0;
    AVERAGE = 0;        
    [TOP_LIMIT, BOTTOM_LIMIT] = adjustAxes('Moment Plot',dF,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);        
    
    % Insert state lines
    set(P3);                        % Activate the appropriate subplot
    insertStates(stateData,TOP_LIMIT,BOTTOM_LIMIT,FillFlag);    
%% Save plot to file
	savePlot(Path,StratTypeFolder,FolderName,P1,'RateChangePlot')
end    