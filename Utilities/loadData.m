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
% As of Aug 2015, data for both arms was introduced. June 2016 added Baxter
% support. Use node to convert bag_to_mat. Load the
% robot_limb_right_endpoint_state.mat with the following fields in data as
% columns:
%     header.seq        
%     header.stamp.secs 
%     header.stamp.nsecs
%     header.frame_id   
%     pose.position.x   
%     pose.position.y   
%     pose.position.z   
%     pose.orientation.x
%     pose.orientation.y
%     pose.orientation.z
%     pose.orientation.w
%     twist.linear.x    
%     twist.linear.y    
%     twist.linear.z    
%     twist.angular.x   
%     twist.angular.y   
%     twist.angular.z   
%     wrench.force.x    
%     wrench.force.y    
%     wrench.force.z    
%     wrench.torque.x   
%     wrench.torque.y   
%     wrench.torque.z   
% Inputs:
% fPath:            Path to results for data
% StrategyType:     Type of strategy. Specially encoded string.
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
function [ADR, CPR, FDR,  ...                           % Right Arm Data
          ADL, CPL, FDL, ...                            % Left Arm Data
          JSD,SDR]= loadData(fPath,StrategyType,StratTypeFolder,FolderName) %,...
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
    % Paths
    
    
    % Data
    global anglesDataFlag;              % Enable loading/printing of current joint angles
    global cartposDataFlag;             % Same for cartesian position of end effector
    global local0_world1_coords;        % Sets wrench data to load/plot wrt end-effector or world coordinates
    global gravityCompensated;          % % If you want to plot torques that have used gravity compensation
    
    % Arm Side Information
    global armSide;                     % Array with bools indicating whether using left/right arm. . 
    
    % Loop Rate
    loopRate = 0.005;                   % Default rate. Modified later.
    expectedTime=10;                    % for a trial
    samples=expectedTime*(1/loopRate);
    % CODER 
    % INIT
    coder.extrinsic('strcat');          % If machine that runs c, has matlab can use.
    SDR = zeros(5,1);                    % Initialize state transition matrix
    endTime=0.0;
   
    ADR=zeros(samples,8); CPR=zeros(samples,7); FDR=zeros(samples,7);
    ADL=zeros(samples,8); CPL=zeros(samples,7); FDL=zeros(samples,7);
    coder.varsize(ADR,ADL,CPR,CPL,FDR,FDL);
    
    %% (1) Assign folder names     
    %% Right Arm: Always load this data
    %------------------------ HIRO-----------------------------------------
    if(strategySelector('hiro',StrategyType))
        if(gravityCompensated==0 && local0_world1_coords==0)
            FD  =strcat(fPath,StratTypeFolder,FolderName,'/R_Torques.dat');
        elseif(gravityCompensated==0 && local0_world1_coords==1)
            FD  =strcat(fPath,StratTypeFolder,FolderName,'/R_worldTorques.dat');
        elseif(gravityCompensated==1 && local0_world1_coords==0)
            FD  =strcat(fPath,StratTypeFolder,FolderName,'/R_GC_Torques.dat');    
        elseif(gravityCompensated==1 && local0_world1_coords==1)
            FD  =strcat(fPath,StratTypeFolder,FolderName,'/R_GC_worldTorques.dat');  
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
            CP     =strcat(fPath,StratTypeFolder,FolderName,'/R_CartPos.dat');      
        else
            CP=0;
        end

        %% Left Arm
        if(armSide(1,1))
            if(gravityCompensated==0 && local0_world1_coords==0)
                ForceDataL  =strcat(fPath,StratTypeFolder,FolderName,'/L_Torques.dat');
            elseif(gravityCompensated==0 && local0_world1_coords==1)
                ForceDataL  =strcat(fPath,StratTypeFolder,FolderName,'/L_worldTorques.dat');
            elseif(gravityCompensated==1 && local0_world1_coords==0)
                ForceDataL  =strcat(fPath,StratTypeFolder,FolderName,'/L_GC_Torques.dat');    
            elseif(gravityCompensated==1 && local0_world1_coords==1)
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
        FDR = load(FD);
        SDR = load(StateData);
        if (length(FDR)>1); loopRate=FDR(2,1); end;
        
        % Joint Angle Data
        if(anglesDataFlag)
            ADR  = load(AngleData);
        else
            ADR=-1;
        end
        
        % Cartesian Position
        if(cartposDataFlag)
            CPR  = load(CP);
        else
            CPR=-1;
        end
        
        %% Left Arm
        FDL = load(ForceDataL);
        %SDR      = load(StateDataL);
        if (length(FDL)>1); loopRate=FDL(2,1); end;
        
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
 
    %------------------------- BAXTER -------------------------------------
    elseif(strategySelector('baxter',StrategyType)) 
        % Snap Joints: Was used with PA10, not now.
        JSD=-1;

        if(armSide(1,2)) % Right
            rTopicName='__robot_limb_right_endpoint_state.mat';
            rosDataRight=load(strcat(fPath,FolderName,rTopicName));

        elseif(armSide(1,1)) % Left
            lTopicName='__robot_limb_left_endpoint_state.mat';
            rosDataLeft=load(strcat(fPath,FolderName,lTopicName));            
        end
        
        % LEFT ARM
        % Load the MAT Files
        if(armSide(1,1)) % LEFT
            % Load the MAT Files
            rosDataLeft=load(strcat(baxterPath,FolderName,lTopicName));
        
            % Separate the Data and store
            % Pre-allocation
            [r,~]=size(rosDataLeft.data);
            FDL=zeros(r,7);
            if(anglesDataFlag);  ADL=zeros(r,8); else ADL=0; end;
            if(cartposDataFlag); CPL=FDL;        else CPL=0; end;
            
            % Copy data locally
            for i=1:r
                % Time: all elems - first index as offset. Convert from nsec to sec
                FDL(i,1)=( (rosDataLeft.data(i,2)+(rosDataLeft.data(i,3)*1e-09)) - (rosDataLeft.data(1,2)+(rosDataLeft.data(1,3)*1e-09)) );
                round(FDL(i,1),4,'significant'); % Round to 4sf
                
                % Copy wrench data
                FDL(i,2:7)=rosDataLeft.data(i,18:23);

                % End-effector Cartesian Pose
                if(cartposDataFlag)
                    % Time
                    CPL(:,1)=FDL(:,1);
                    % Pose
                    CPL(i,2:4)=rosDataLeft.data(i,5:7);
                    % Convert Quaternions to ZYX Euler and then adjust as RPY or XYZ
                    CPL(i,5:7)=fliplr(quat2eul(rosDataLeft.data(i,8:11)));
                else
                    CPL=0;
                end        
               
                % Joint Angles Data
                if(anglesDataFlag)
                  	% Time
                    ADL(:,1)=FDL(:,1);
                else
                    ADL=0;
                end                
               
         	end     % for loop
            
        % RIGHT ARM
        elseif(armSide(1,2)) % RIGHT_ARM           
           	% Pre-allocation
            [r,~]=size(rosDataRight.data);
            FDR=zeros(r,7);
            if(anglesDataFlag);  ADR=zeros(r,8); else ADR=0; end;
            if(cartposDataFlag); CPR=FDR;        else CPR=0; end;

            % Copy data locally
            for i=1:r
               % Time: all elems - first index as offset. Convert from nsec to sec
                FDR(i,1)=( (rosDataRight.data(i,2)+(rosDataRight.data(i,3)*1e-09)) - (rosDataRight.data(1,2)+(rosDataRight.data(1,3)*1e-09)) );
                round(FDR(i,1),4,'significant'); % Round to 4sf
                
                % Copy wrench data
                FDR(i,2:7)=rosDataRight.data(i,18:23);

                % End-effector Cartesian Pose
                if(cartposDataFlag)
                    % Time
                    CPR(:,1)=FDR(:,1);
                    % Pose
                    CPR(i,2:4)=rosDataRight.data(i,5:7);
                    % Convert Quaternions to ZYX Euler and then adjust as RPY or XYZ
                    CPR(i,5:7)=fliplr(quat2eul(rosDataRight.data(i,8:11)));
                else
                    CPR=0;
                end     
               
                % Joint Angles Data
                if(anglesDataFlag)
                    % Time
                    ADR(:,1)=FDR(:,1);
                else
                    ADR=0;
                end                 
               
            end     % for loop        
        end         % ARM SIDE
        
        if(armSide(1,1))
        	if (i>1); loopRate=FDL(2,1); end;
        elseif(armSide(1,2))
            if (i>1); loopRate=FDR(2,1); end;
        end
    end             % ROBOT TYPE
   % Get the State Transition Vector    
   SDR = load(strcat(fPath,'/State.dat'));
   
    
    %% State Vector Length Verification
    % Adjust the data length so that it finishes when mating is finished. 
    [r,c] = size(SDR);
    if(r==5)
        endTime = SDR(5,1);
    
        % There are 2 cases to check: (1) If state endTime is less than actual data, and if it is more.  
        if(FDR(end,1)>endTime)

            % Note that SDR(5,1) is hardcoded as some time k later thatn SDR(4,1). 
            endTime = floor(endTime/loopRate)+1; % The Angles/Torques data is comprised of steps of magnitude 0.005. Then we round down.

            % Time will be from 1:to the entry denoted by the State Vector in it's 5th entry. 
            FDR = FDR(1:endTime,:);
            if(anglesDataFlag && cartposDataFlag)            
                ADR = ADR(1:endTime,:);                
                CPR = CPR(1:endTime,:);
            end

        else
            SDR(5,1) = FDR(end,1);
        end
        
    %% Insert an end state for failed assemblies that have less than the 5 entries
    else
        SDR(r+1,1) = FDR(end,1);  % Enter a new row in SDR which includes the last time value contained in any of the other data vecs.
        
    end
    %% Check to make sure that StateData has a finishing time included
    if(strategySelector('SA',StrategyType))
        if(length(SDR)<5)
            fprintf('StateData does not have 5 entries. You probably need to include the finishing time of the Assembly task in this vector.\n');
        end
    end
end