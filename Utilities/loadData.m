% Load Data
% Function modified last: Nov. 26, 2012
%
% To prepare for codegen
%
% Arguments removed. Codegen does not support strcat, ispc, 
% Solution: 
%   Assign a hardcoded folder for results to come in.
%       If simulation select your folder of choice.
%       If Hiro robot select: \\home\\grxuser\\src\\OpenHRP3-0\\Controller\\IOserver\\HRP2STEP1\\bin)
%
% CodeGen does not recognize:
% strcat commands
% if(ispc) remove
%--------------------------------------------------------------------------
function [AD,FD,CP,SD] = loadData(fPath,StratTypeFolder,FolderName)

    %% Global Functions
    global DB_DEBUG;
    
    % If manually loading adjust here and comment out later
    %AngleData       ='/home/grxuser/Documents/School/Research/AIST/Results/ForceControl/ErrorCharac/Angles.dat';
    %ForceData       ='/home/grxuser/Documents/School/Research/AIST/Results/ForceControl/ErrorCharac/Torques.dat';
    %CartPos         ='/home/grxuser/Documents/School/Research/AIST/Results/ForceControl/ErrorCharac/CartPos.dat';
    %StateData       ='/home/grxuser/Documents/School/Research/AIST/Results/ForceControl/ErrorCharac/State.dat';
    
    % If running HIRO Online Experiments use:
    %AngleData       ='\\home\\grxuser\\src\\OpenHRP3-0\\Controller\\IOserver\\HRP2STEP1\\bin\\Angles.dat';
    %ForceData       ='\\home\\grxuser\\src\\OpenHRP3-0\\Controller\\IOserver\\HRP2STEP1\\bin\\Torques.dat';
    %CartPos         ='\\home\\grxuser\\src\\OpenHRP3-0\\Controller\\IOserver\\HRP2STEP1\\bin\CartPos.dat';
    %StateData       ='\\home\\grxuser\\src\\OpenHRP3-0\\Controller\\IOserver\\HRP2STEP1\\bin\\State.dat';

    %% Init
    jointAnglesFlag = 0;    % If we want to load these data, set flag to true
    cartPosFlag = 0;        

    %% Assign the right folder name
    ForceData       =strcat(fPath,StratTypeFolder,FolderName,'/Torques.dat');
    StateData       =strcat(fPath,StratTypeFolder,FolderName,'/State.dat');
    if(jointAnglesFlag && cartPosFlag)
        AngleData   =strcat(fPath,StratTypeFolder,FolderName,'/Angles.dat');
        CartPos     =strcat(fPath,StratTypeFolder,FolderName,'/CartPos.dat');
    else
        AD=0;
        CP=0;
    end
   
    %% Load the data
    FD=load(ForceData);
    SD=load(StateData);
    if(jointAnglesFlag && cartPosFlag)
        AD=load(AngleData);       
        CP=load(CartPos);     
    end
    
    % Adjust the data length so that it finishes when mating is finished. 
    [rSD,~] = size(SD);
    if(rSD==5)
        endTime = SD(5,1);
    
        % There are 2 cases to check: (1) If state endTime is less than actual data, and if it is more.  
        if(FD(end,1)>endTime)

            % Note that SD(5,1) is hardcoded as some time k later thatn SD(4,1). 
            endTime = floor(endTime/0.005)+1; % The Angles/Torques data is comprised of steps of magnitude 0.0005. Then we round down.

            % Time will be from 1:to the entry denoted by the State Vector in it's 5th entry. 
            FD = FD(1:endTime,:);
            if(jointAnglesFlag && cartPosFlag)            
                AD = AD(1:endTime,:);                
                CP = CP(1:endTime,:);
            end

        else
            SD(5,1) = FD(end,1);
        end
        
    %% Insert an end state for failed assemblies that have 4 entries
    else
        if(rSD<5)
            SD(rSD+1,1) = FD(end,1);  % Enter a new row in SD which includes the last time value contained in any of the other data vecs.
        end
        
    end
    %% Check to make sure that StateData has a finishing time included
    if(DB_DEBUG)
        if(strcmp(StratTypeFolder,'ForceControl/SideApproach/') || strcmp(StratTypeFolder,'ForceControl/ErrorCharac/'))
            if(rSD<5)
                fprintf('StateData does not have 5 entries. You probably need to include the finishing time of the Assembly task in this vector.\n');
            end
        end
    end
end