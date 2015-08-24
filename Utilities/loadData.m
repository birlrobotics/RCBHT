% Load Data
% This function loads and outputs data associated with robot data like
% joint angles, cartesian position, wrench data in local and world
% coordinates, and state time information for the assembly task. 
%
% Currently we are not reading gravity compensated force. This would need
% the addition of L_GC_Torques.dat and R_GC_Torques.dat wrt to the
% end-effector and their world counterparts. 
% 
% Codegen improvements:
% Arguments were removed. Codegen does not support strcat, ispc, 
% Solution: 
%   Assign a hardcoded folder for results to come in.
%       If simulation select your folder of choice.
%       If Hiro robot select: \\home\\grxuser\\src\\OpenHRP3-0\\Controller\\IOserver\\HRP2STEP1\\bin)
%
% CodeGen does not recognize:
% strcat commands
% if(ispc) remove
%
% As of Aug 2015, data for both arms was introduced.
% Inputs:
% fPath:            Path to results for data
% StratTypeFolder:  Folder for a given type of strategy
% FolderName:       Name of foler where data actually resides
% anglesDataFlag,cartposDataFlag,local0_world1_coords,leftArmDataFlag);
% 
% Outputs:
% AD:               AngleData. Current joint angle data for right arm.
% ADL:              AngleData for left arm.
% CP:               Current cartesian Position for the right arm. 
% CPL:              For left arm.
% FD:               Wrench data with respect to the end-effector for right arm.
% FDL:              For left arm.
% worldFD:          Wrench data with respect to the world.
% worldFDL:         For left arm.
% jointSnapData:    IF snap elastic rotation takes place, this holds the
%                   angle data for that.
%--------------------------------------------------------------------------
function [AD,  CP,  FD,  ...                           % Right Arm Data
          ADL, CPL, FDL, ...                          % Left Arm Data
          JSD,SD]= loadData(fPath,StratTypeFolder,FolderName) %,...
                               %anglesDataFlag,cartposDataFlag,local0_world1_coords,leftArmDataFlag)

    % If manually loading adjust here and comment out later
    % AngleData       ='/home/grxuser/Documents/School/Research/AIST/Results/ForceControl/ErrorCharac/Angles.dat';
    % ForceData       ='/home/grxuser/Documents/School/Research/AIST/Results/ForceControl/ErrorCharac/Torques.dat';
    % CartPos         ='/home/grxuser/Documents/School/Research/AIST/Results/ForceControl/ErrorCharac/CartPos.dat';
    % StateData       ='/home/grxuser/Documents/School/Research/AIST/Results/ForceControl/ErrorCharac/State.dat';
    
    % If running HIRO Online Experiments use:
    % AngleData       ='\\home\\grxuser\\src\\OpenHRP3-0\\Controller\\IOserver\\HRP2STEP1\\bin\\Angles.dat';
    % ForceData       ='\\home\\grxuser\\src\\OpenHRP3-0\\Controller\\IOserver\\HRP2STEP1\\bin\\Torques.dat';
    % CartPos         ='\\home\\grxuser\\src\\OpenHRP3-0\\Controller\\IOserver\\HRP2STEP1\\bin\CartPos.dat';
    % StateData       ='\\home\\grxuser\\src\\OpenHRP3-0\\Controller\\IOserver\\HRP2STEP1\\bin\\State.dat';
    
    %% Global Variables
    % Data
    global anglesDataFlag;              % Enable loading/printing of current joint angles
    global cartposDataFlag;             % Same for cartesian position of end effector
    global local0_world1_coords;        % Sets wrench data to load/plot wrt end-effector or world coordinates
    global gravityCompensated;          % % If you want to plot torques that have used gravity compensation
    
    % Left Arm
    global leftArmDataFlag;             % Enables to load/plot left arm data.    
    
    %% (1) Assign folder names     
    %% Right Arm: Always load this data
    if(gravityCompensated==0 && local0_world1_coords==0)
        ForceData  =strcat(fPath,StratTypeFolder,FolderName,'/R_Torques.dat');
    elseif(gravityCompensated==0 && local0_world1_coords==1)
        ForceData  =strcat(fPath,StratTypeFolder,FolderName,'/R_worldTorques.dat');
    elseif(gravityCompensated==1 && local0_world1_coords==0)
        ForceData  =strcat(fPath,StratTypeFolder,FolderName,'/R_GC_Torques.dat');    
    elseif(gravityCompensated==1 && local0_world1_coords==0)
        ForceData  =strcat(fPath,StratTypeFolder,FolderName,'/R_GC_worldTorques.dat');  
    end
    StateData       =strcat(fPath,StratTypeFolder,FolderName,'/R_State.dat');
    
    % Joint Angle Data
    if(anglesDataFlag)
        AngleData   =strcat(fPath,StratTypeFolder,FolderName,'/R_Angles.dat');
    else 
        AngleData=0;        
    end
    
    % Cartesian Data
    if(cartposDataFlag)
        CartPos     =strcat(fPath,StratTypeFolder,FolderName,'/R_CartPos.dat');      
    else
        CartPos=0;
    end

    %% Left Arm
    if(leftArmDataFlag)
        if(gravityCompensated==0 && local0_world1_coords==0)
            ForceDataL  =strcat(fPath,StratTypeFolder,FolderName,'/L_Torques.dat');
        elseif(gravityCompensated==0 && local0_world1_coords==1)
            ForceDataL  =strcat(fPath,StratTypeFolder,FolderName,'/L_worldTorques.dat');
        elseif(gravityCompensated==1 && local0_world1_coords==0)
            ForceDataL  =strcat(fPath,StratTypeFolder,FolderName,'/L_GC_Torques.dat');    
        elseif(gravityCompensated==1 && local0_world1_coords==0)
            ForceDataL  =strcat(fPath,StratTypeFolder,FolderName,'/L_GC_worldTorques.dat');  
        end
        %StateDataL      =strcat(fPath,StratTypeFolder,FolderName,'/L_State.dat');

        % Joint Angle Data
        if(anglesDataFlag)
            AngleDataL   =strcat(fPath,StratTypeFolder,FolderName,'/L_Angles.dat');
        else 
            AngleDataL=0;        
        end

        % Cartesian Data
        if(cartposDataFlag)
            CartPosL     =strcat(fPath,StratTypeFolder,FolderName,'/L_CartPos.dat');      
        else
            CartPosL=0;
        end    
    end
   
    %% (2) Load the data    
    % Snap Joints: Was used with PA10, not now.
    JSD=-1;
    
    %% Right Arm
    FD = load(ForceData);
    SD = load(StateData);
    
    % Joint Angle Data
    if(anglesDataFlag)
        AD  = load(AngleData);    
    else
        AD=-1;
    end
    
    % Cartesian Position
    if(cartposDataFlag)
        CP  = load(CartPos);
    else
        CP=-1;
    end
    
    %% Left Arm 
    FDL = load(ForceDataL);
    %SD      = load(StateDataL);
    
    % Joint Angle Data
    if(anglesDataFlag)
        ADL  = load(AngleDataL);     
    else
        ADL=-1;
    end
    
    % Cartesian Position
    if(cartposDataFlag)
        CPL  = load(CartPosL);
    else
        CPL=-1;
    end
    
    %% State Vector Length Verification
    % Adjust the data length so that it finishes when mating is finished. 
    r = size(SD);
    if(r(1)==5)
        endTime = SD(5,1);
    
        % There are 2 cases to check: (1) If state endTime is less than actual data, and if it is more.  
        if(FD(end,1)>endTime)

            % Note that SD(5,1) is hardcoded as some time k later thatn SD(4,1). 
            endTime = floor(endTime/0.005)+1; % The Angles/Torques data is comprised of steps of magnitude 0.0005. Then we round down.

            % Time will be from 1:to the entry denoted by the State Vector in it's 5th entry. 
            FD = FD(1:endTime,:);
            if(anglesDataFlag && cartposDataFlag)            
                AD = AD(1:endTime,:);                
                CP = CP(1:endTime,:);
            end

        else
            SD(5,1) = FD(end,1);
        end
        
    %% Insert an end state for failed assemblies that have less than the 5 entries
    else
        SD(r(1)+1,1) = FD(end,1);  % Enter a new row in SD which includes the last time value contained in any of the other data vecs.
        
    end
    %% Check to make sure that StateData has a finishing time included
    if(strcmp(StratTypeFolder,'ForceControl/SIM_SideApproach/')         || ... 
       strcmp(StratTypeFolder,'ForceControl/SIM_SA_ErrorCharac_001/')   || ...
       strcmp(StratTypeFolder,'ForceControl/SIM_SA_ErrorCharac_002/')   || ...
       strcmp(StratTypeFolder,'ForceControl/SIM_SA_ErrorCharac_003/')   || ...
       strcmp(StratTypeFolder,'ForceControl/SIM_SA_ErrorCharac_004/')   || ...
       strcmp(StratTypeFolder,'ForceControl/SIM_SA_DualArm/')           || ...
       strcmp(StratTypeFolder,'ForceControl/HIRO_SideApproach/'))
        if(length(SD)<5)
            fprintf('StateData does not have 5 entries. You probably need to include the finishing time of the Assembly task in this vector.\n');
        end
    end
end