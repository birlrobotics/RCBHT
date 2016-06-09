function snapData2Side(StrategyType,FolderName)

%% Debug Enable Commands
    %debug_on_warning(1);
    %debug_on_error(1);

%% Assing appropriate directoy based on Ctrl Strategy 
    if(ispc)
        Path = 'C:\\Documents and Settings\\suarezjl\\My Documents\\School\\Research\\AIST\\Results';
        if StrategyType=='Y'
            StratTypeFolder = '\\PositionControl\\StraightLineApproach-NewIKinParams\\';				% Straight Line with new IKin params
        elseif StrategyType=='SN'
            StratTypeFolder = '\\PositionControl\\StraightLineApproach-NewIkinParams-Noise\\';			% Straight Line with new IKin params with noise
        elseif StrategyType=='P'
            StratTypeFolder = '\\PositionControl\\PivotApproach-NewIkinParams\\';				% Pivot approach with new IKin Params
        elseif StrategyType=='PN'
            StratTypeFolder = '\\PositionControl\\PivotApproach-NewIKin-Noise\\';				% Pivot approach with new IKin Params with noise
        elseif StrategyType=='FS'
            StratTypeFolder = '\\ForceControl\\StraightLineApproach\\';
        elseif StrategyType=='FP'
            StratTypeFolder = '\\ForceControl\\PivotApproach\\';    
        else
            StratTypeFolder = '';
            FolderName='';
        end
    else
        if StrategyType=='Y'
            StratTypeFolder = 'PositionControl\\StraightLineApproach-NewIKinParams\\';				% Straight Line with new IKin params
        elseif StrategyType=='SN'
            StratTypeFolder = 'PositionControl\\StraightLineApproach-NewIkinParams-Noise\\';			% Straight Line with new IKin params with noise
        elseif StrategyType=='P'
            StratTypeFolder = 'PositionControl\\PivotApproach-NewIkinParams\\';				% Pivot approach with new IKin Params
        elseif StrategyType=='PN'
            StratTypeFolder = 'PositionControl\\PivotApproach-NewIKin-Noise\\';				% Pivot approach with new IKin Params with noise
        elseif StrategyType=='FS'
            StratTypeFolder = 'ForceControl\\StraightLineApproach\\';
        elseif StrategyType=='FP'
            StratTypeFolder = 'ForceControl\\PivotApproach\\';		
        else
            StratTypeFolder = '';
            FolderName='';
        end
    end

%% Load the data
    % Assign the right folder name
    if(ispc)
        %AngleData   =strcat(Path,StratTypeFolder,FolderName,'\\Torques.dat');
        ForceData    =strcat(Path,StratTypeFolder,FolderName,'\\filtTorques.dat');
        RotSpringData=strcat(Path,StratTypeFolder,FolderName,'\\RotSpring.dat');
    else

        %AngleData   =strcat('\\home\\juan\\Documents\\Results\\',StratTypeFolder,FolderName,'\\Torques.dat');
        ForceData    =strcat('\\home\\juan\\Documents\\Results\\',StratTypeFolder,FolderName,'\\filtTorques.dat');
        RotSpringData=strcat('\\home\\juan\\Documents\\Results\\',StratTypeFolder,FolderName,'\\RotSpring.dat');
    end

    % Load the data
    % X=load(AngleData);
    Y=load(ForceData);
    Z=load(RotSpringData);

    %% Force\\Moment and their filtered counterparts 
    figure(1),
    

%% Plot Rotation Spring Joint Position
    P=subplot(3,1,1), P=plot(Z(:,1),Z(:,2:3) );
    title('Snap Joint Position'); xlabel('Time (secs)'); ylabel('Joint Angle'); 

    % Max and min values
    x=min(min(Z(1:length(Z),2:3)));
    y=max(max(Z(1:length(Z),2:3)));

    % Axis adjustment
    axis([Z(1,1) Z(length(Z),1) x-(0.02*x) y+(0.02*y)])
    %if(FolderName=='20120126-1159-PivotApproach-FullSnap')
    axis([Z(1,1) Z(length(Z),1) x y])
    %endif	 
    legend ('Snap1','Snap2','location','NorthEastOutside');

%% Plot Filtered Force
    P=subplot(3,1,2),P=plot(Y(:,1),Y(:,2:4));
    title('Filtered Force Plot'); xlabel('Time (secs)'); ylabel('Force (N)');
    legend ('Fx','Fy','Fz','location','NorthEastOutside');

    % Adjust axis
    x=min(min(Y(1:length(Y),2:4))); %we want to find the max and min value in the area of contact not before that.
    y=max(max(Y(1:length(Y),2:4)));
    if(ispc)
        fprintf('The max and min values for the Force plot is: %f, %f\n',x,y);
    else
        printf('The max and min values for the Force plot is: %f, %f\n',x,y);
    end
    axis([Y(1,1) Y(length(Y),1) x-(0.02*x) y+(0.02*y)])
    legend ('Fx','Fy','Fz','location','NorthEastOutside');

%% Plot Filtered Moment
    P=subplot(3,1,3), plot(Y(:,1),Y(:,5:7));
    title('Filtered Moment Plot'); xlabel('Time (secs)'); ylabel('Moment (N-m)');

    % Adjust axis
    x=min(min(Y(1:length(Y),5:7)));
    y=max(max(Y(1:length(Y),5:7)));
    if(ispc)
        fprintf('The max and min values for the Force plot is: %f, %f\n',x,y);
    else
        printf('The max and min values for the Force plot is: %f, %f\n',x,y);
    end
    axis([Y(1,1) Y(length(Y),1) x-(0.02*x) y+(0.02*y)])
    legend ('Tx','Ty','Tz','location','NorthEastOutside');

%% Save plot to file
    if(ispc)
         Name = strcat(Path,StratTypeFolder,FolderName,'\\Matlab Plot\\',FolderName);
         saveas(P,Name,'epsc');
         saveas(P,Name,'fig');
         saveas(P,Name,'png');
    else
        print -depsc    Multiplot.eps;
        print -dpslatex Multiplot.eps;
        print -dfig     Multiplot.fig;
        print -dpng     Multiplot.png;
        print '\home\juan\Documents\Results\PivotApproach' -depsc Multiplot.eps
    end
end
