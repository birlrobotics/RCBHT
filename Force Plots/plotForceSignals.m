% Plots force and moment profiles for SnapAssemblies. 
% Selects appropriate directories based on the kind of snap assembly
% strategy assumed.
% 
% Read data from different files:
% Torques data from: Torques.dat
% Low-pass filtered torques from: filtTorques.da
%**************************************************************************
function plotForceSignals(StrategyType,FolderName)

%%  Debug Enable Commands
    PRINT = 0; % Used to indicated wheter to pring info to screen or not
    global armSide; 
    StratTypeFolder = AssignDir(StrategyType);

%% Folder Name    
 %% (1) Assign folder names     
    %% Right Arm
    localForceData  =strcat(fPath,StratTypeFolder,FolderName,'/R_Torques.dat');
    worldForceData  =strcat(fPath,StratTypeFolder,FolderName,'/R_worldTorques.dat');
    StateData       =strcat(fPath,StratTypeFolder,FolderName,'/R_State.dat');
    
    % Joint Angle Data
    if(jointAnglesFlag)
        AngleData   =strcat(fPath,StratTypeFolder,FolderName,'/R_Angles.dat');
    else 
        AngleData=0;        
    end
    
    % Cartesian Data
    if(cartPosFlag)
        CartPos     =strcat(fPath,StratTypeFolder,FolderName,'/R_CartPos.dat');      
    else
        CartPos=0;
    end

    %% Left Arm
    if(armSide(1,1))
        localForceDataL  =strcat(fPath,StratTypeFolder,FolderName,'/L_Torques.dat');
        worldForceDataL  =strcat(fPath,StratTypeFolder,FolderName,'/L_worldTorques.dat');
        %StateDataL      =strcat(fPath,StratTypeFolder,FolderName,'/L_State.dat');

        % Joint Angle Data
        if(jointAnglesFlag)
            AngleDataL   =strcat(fPath,StratTypeFolder,FolderName,'/L_Angles.dat');
        else 
            AngleDataL=0;        
        end

        % Cartesian Data
        if(cartPosFlag)
            CartPosL     =strcat(fPath,StratTypeFolder,FolderName,'/L_CartPos.dat');      
        else
            CartPosL=0;
        end    
    end
   
    %% (2) Load the data    
    %% Right Arm
    localFD = load(localForceData);
    worldFD = load(worldForceData);
    SD      = load(StateData);
    
    % Joint Angle Data
    if(jointAnglesFlag)
        AD  = load(AngleData);                    
    end
    
    % Cartesian Position
    if(cartPosFlag)
        CP  = load(CartPos);
    end
    
    %% Left Arm 
    localFDL = load(localForceData);
    worldFDL = load(worldForceData);
    %SD      = load(StateData);
    
    % Joint Angle Data
    if(jointAnglesFlag)
        ADL  = load(AngleData);                    
    end
    
    % Cartesian Position
    if(cartPosFlag)
        CPL  = load(CartPos);
    end

%%  Plot Force
    % Force/Moment and their filtered counterparts 
    figure(1),

    %% Plot Force
    subplot(2,2,1),F1=plot(localForceData(:,1),localForceData(:,11:13));
    title('Force Plot'); xlabel('Time (secs)'); ylabel('Force (N)');

    % Adjust axis
    [y, ~]=min(min(localForceData(1:length(localForceData),11:13))); %we want to find the max and min value in the area of contact not before that.
    [x, ~]=max(max(localForceData(1:length(localForceData),11:13)));

    if(PRINT)
        if(ISPC)
            fprintf('The max and min values for the Force plot is: %f, %f\n',x,y);
        else
            printf('The max and min values for the Force plot is: %f, %f\n',x,y);
        end
    end
    axis([localForceData(1,1) localForceData(length(localForceData),1) y-(0.02*y) x+(0.02*y)])

%% Plot Filtered Force
    subplot(2,2,2),F2=plot(localForceData(:,1),localForceData(:,2:4));
    title('Filtered Force Plot'); xlabel('Time (secs)'); ylabel('Force (N)');
    legend ('Fx','Fy','Fz','location','NorthEastOutside');

    % Adjust axis
    [y, ~]=min(min(localForceData(1:length(localForceData),2:4))); %we want to find the max and min value in the area of contact not before that.
    [x, ~]=max(max(localForceData(1:length(localForceData),2:4)));

    if(PRINT)
        if(ISPC)
            fprintf('The max and min values for the Force plot is: %f, %f\n',x,y);
        else
            printf('The max and min values for the Force plot is: %f, %f\n',x,y);
        end
    end
    axis([localForceData(1,1) localForceData(length(localForceData),1) y-(0.02*y) x+(0.02*y)])
    legend ('Fx','Fy','Fz','location','NorthEastOutside');

%% Plot Moment
    subplot(2,2,3), M1=plot(localForceData(:,1),localForceData(:,14:16));
    title('Moment Plot'); xlabel('Time (secs)'); ylabel('Moment (N-m)');

    % Adjust axis
    [y, ~]=min(min(localForceData(1:length(localForceData),14:16)));
    [x, ~]=max(max(localForceData(1:length(localForceData),14:16)));
    if(PRINT)
        if(ISPC)
            fprintf('The max and min values for the Force plot is: %f, %f\n',x,y);
        else
            printf('The max and min values for the Force plot is: %f, %f\n',x,y);
        end
    end
    axis([localForceData(1,1) localForceData(length(localForceData),1) y-(0.02*y) x+(0.02*x)]);
    legend ('Tx','Ty','Tz','location','NorthEastOutside');

%% Plot Filtered Moment
    subplot(2,2,4), M2=plot(localForceData(:,1),localForceData(:,5:7));
    title('Filtered Moment Plot'); xlabel('Time (secs)'); ylabel('Moment (N-m)');

    % Adjust axis
    [y, ~]=min(min(localForceData(1:length(localForceData),5:7)));
    [x, ~]=max(max(localForceData(1:length(localForceData),5:7)));
    if(PRINT)
        if(ISPC)
            fprintf('The max and min values for the Force plot is: %f, %f\n',x,y);
        else
            printf('The max and min values for the Force plot is: %f, %f\n',x,y);
        end
    end
    axis([localForceData(1,1) localForceData(length(localForceData),1) y-(0.02*y) x+(0.02*y)]);
    legend ('Tx','Ty','Tz','location','NorthEastOutside');

%%  Save plot to file
    if(ISPC)
         Name = strcat(P,FolderName,Diagonal,FolderName);
         saveas(F,Name,'epsc');
         saveas(F,Name,'fig');
         saveas(F,Name,'png');
    else
        print -deps Multiplot.eps;
        print -dfig   Multiplot.fig;
        print -dpng Multiplot.png;
    end
end
