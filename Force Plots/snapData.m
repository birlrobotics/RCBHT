function snapData(StrategyType,FolderName,fPath)

%% Debug Enable Commands
    %debug_on_warning(1);
    %debug_on_error(1);

%% Assing appropriate directoy based on Ctrl Strategy 
    StratTypeFolder = AssignDir(StrategyType);

%% Load the data
    % Assign the right folder name
    %AngleData   =strcat(fPath,StratTypeFolder,FolderName,'\\Torques.dat');
    ForceData    =strcat(fPath,StratTypeFolder,FolderName,'\\filtTorques.dat');
    RotSpringData=strcat(fPath,StratTypeFolder,FolderName,'\\RotSpring.dat');

    % Load the data
    % X=load(AngleData);
    Y=load(ForceData);
    Z=load(RotSpringData);

%% Plots
   figure(1),
   
   % Customize the length of axis per result
    secs             = 10.0;       % Standard length for simulation 
    SIGNAL_THRESHOLD = 50;         % Threshold used to select max and min values
    
    % If simulation lasted more or less, change the time
    if(strcmp(FolderName,'20120201-1752-StraightLineApproach-S')) 
        secs=6.3;
    elseif(strcmp(FolderName,'20120126-1710-PivotApproach-FullSnap-S')) 
        secs=8.3;
    end

    % Calculate the appropriate time percentage equivalent to duration based on signals length. 
    TIME_LIMIT_PERC=(secs * 1000)/length(Y);           
%% Plot Rotation Spring Joint Position
    P1=subplot(3,1,1); plot(Z(:,1),Z(:,2:3) );
    title('Snap Joint Position'); xlabel('Time (secs)'); ylabel('Joint Angle'); 
        
    % Max and min values
    x=min(min(Z(1:length(Z)*TIME_LIMIT_PERC,2:3))); %we want to find the max and min value in the area of contact not before that.
    y=max(max(Z(1:length(Z)*TIME_LIMIT_PERC,2:3)));
    
    % Axis adjustment
    axis([Z(1,1) (Z(length(Y),1)*TIME_LIMIT_PERC) x y]);
    legend('Snap1','Snap2','location','NorthWest');

%% Plot Filtered Force
    P2=subplot(3,1,2); plot(Y(:,1),Y(:,2:4));
    title('Filtered Force Plot'); xlabel('Time (secs)'); ylabel('Force (N)');
    legend ('Fx','Fy','Fz','location','NorthWest');
    
    % Max and min values
    x=min(Y(1:length(Y)*TIME_LIMIT_PERC,2:4)); %we want to find the max and min value in the area of contact not before that.
    y=max(Y(1:length(Y)*TIME_LIMIT_PERC,2:4));
    
    % Max/min value adjustment
    x = sort(x);            % sort in ascending order for 1x3.
    y = sort(y);
    
    if(min(x)<-1*SIGNAL_THRESHOLD) % Check the smallest value
        x=x(2);                 % We have a 1x3 array. If the min value of lhs x is less than 100, then choose the next largest value.
    else
        x=x(1);                 % The value is not less than 100, so it's okay to choose the smaller value.
    end
    if(max(y)>SIGNAL_THRESHOLD) % Check the max value
        y=y(2);                 % We have a 1x3 array. If the max value of lhs y is greater than 100, then choose the next smallest value.
    else
        y=y(3);                 % The value is not greater than 100, so it's okay to choose the larger value.
    end        
    
    % Print max/min values
    if(ispc)
        fprintf('The max and min values for the Force plot is: %f, %f\n',x,y);
    else
        printf('The max and min values for the Force plot is: %f, %f\n',x,y);
    end    
    
    % Axis adjustment
    axis([Z(1,1) (Z(length(Y),1)*TIME_LIMIT_PERC) x-(0.02*x) y+(0.02*y)]);
    legend('Fx','Fy','Fz','location','NorthWest');

%% Plot Filtered Moment
    P3=subplot(3,1,3); plot(Y(:,1),Y(:,5:7));
    title('Filtered Moment Plot'); xlabel('Time (secs)'); ylabel('Moment (N-m)');
   
    % Max and min values]
    start = 1;
    if(strcmp(StrategyType,'P')||strcmp(StrategyType,'PN')||strcmp(StrategyType,'FP'))
        start = 2500;
    end
    x=min(Y(start:length(Y)*TIME_LIMIT_PERC,5:7)); %we want to find the max and min value in the area of contact not before that.
    y=max(Y(start:length(Y)*TIME_LIMIT_PERC,5:7));

    % Max/min value adjustment
    x = sort(x);            % sort in ascending order for 1x3.
    y = sort(y);
    
    if(min(x)<-1*SIGNAL_THRESHOLD)
        x=x(2);           % We have a 1x3 array. If the min value of lhs x is less than 100, then choose the next largest value.
    else
        x=x(1);   %       The value is not less than 100, so it's okay to choose the smaller value.
    end
    if(max(y)>SIGNAL_THRESHOLD)
        y=y(2);   % We have a 1x3 array. If the max value of lhs y is greater than 100, then choose the next smallest value.
    else
        y=y(3);   % The value is not greater than 100, so it's okay to choose the larger value.
    end 
    
    % Print max/min values
    if(ispc)
        fprintf('The max and min values for the Force plot is: %f, %f\n',x,y);
    else
        printf('The max and min values for the Force plot is: %f, %f\n',x,y);
    end    
    
    % Axis adjustment
    axis([Z(1,1) (Z(length(Y),1)*TIME_LIMIT_PERC) x-(0.02*x) y+(0.02*y)]);
    legend ('Tx','Ty','Tz','location','NorthWest');

%% Save plot to file
    if(ispc)
        % Make matlab folder
        dir = strcat(fPath,StratTypeFolder,FolderName);
        mkdir(dir,'MatlabPlot');
        Name = strcat(fPath,StratTypeFolder,FolderName,'\\MatlabPlot\\',FolderName);
        saveas(P1,Name,'epsc');
        saveas(P1,Name,'png');         
        saveas(P1,Name,'fig');
    else
        print -depsc    Multiplot.eps;
        print -dpslatex Multiplot.eps;
        print -dfig     Multiplot.fig;
        print -dpng     Multiplot.png;
        print '\home\juan\Documents\Results\PivotApproach' -depsc Multiplot.eps
    end
end