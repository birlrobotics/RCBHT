% Load Data
% This function loads and outputs data associated with robot data like
% joint angles, cartesian position, wrench data in local and world
% coordinates, and state time information for the assembly task. 
%
% Currently we are not reading gravity compensated force. This would need
% the addition of L_GC_Torques.dat and R_GC_Torques.dat wrt to the
% end-effector and their world counterparts. 
%
% Reads right or left arm data according to global flags armSide and
% currentArm. armSide(1,1) or (1,2) indicates the availability of the
% left/right arm respectively. currentArm==1,==2 indicates which arm is
% currently being used.
%
% File Name formatting for HIRO is set in the PivotApproach code available at:
% rojas70.github.io/PivotApproach. 
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
% AD:               AngleData. Current joint angle data
% CP:               Current cartesian Position 
% FD:               Wrench data with respect to the end-effector 
% worldFD:          Wrench data with respect to the world.
% jointSnapData:    IF snap elastic rotation takes place, this holds the
%                   angle data for that.
%--------------------------------------------------------------------------
function [AD, CP, FD,  ...                           % Sensor Data          
          JSD,SD]= loadData(fPath,StrategyType,StratTypeFolder,FolderName) %,...
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
    
    % Flags
    global DB_WRITE;
  
    % Data
    global anglesDataFlag;              % Enable loading/printing of current joint angles
    global cartposDataFlag;             % Same for cartesian position of end effector
    global local0_world1_coords;        % Sets wrench data to load/plot wrt end-effector or world coordinates
    global gravityCompensated;          % % If you want to plot torques that have used gravity compensation
    
    % Arm Side Information
    global armSide;                     % Indicates which arm is available
    global currentArm;                  % Indicates which arm is currently in use
    % Loop Rate
    loopRate = 0.005;                   % Default rate. Modified later.
    
    % Initialize variables
    AD=0; CP=0; FD=0;
    
    %% (1) Assign folder names     
   
    %------------------------ HIRO-----------------------------------------
    if(strategySelector('hiro',StrategyType))
        %% Left Arm
        if(armSide(1,1) && currentArm==1)
            T='/L_Torques.dat';
            wT='/L_worldTorques.dat';
            gT='/L_GC_Torques.dat';
            gwT='/L_GC_worldTorques.dat';
            S='/L_State.dat';
            A='/L_Angles.dat';
            C='/L_CartPos.dat';
        % Right Arm
        elseif(armSide(1,2) && currentArm==2)
            T='/R_Torques.dat';
            wT='/R_worldTorques.dat';
            gT='/R_GC_Torques.dat';
            gwT='/R_GC_worldTorques.dat';
            S='/R_State.dat';
            A='/R_Angles.dat';      
            C='/R_CartPos.dat';
        end
            
        % Force Related Data
        if(gravityCompensated==0 && local0_world1_coords==0)
            ForceData  =strcat(fPath,StratTypeFolder,FolderName,T);
        elseif(gravityCompensated==0 && local0_world1_coords==1)
            ForceData  =strcat(fPath,StratTypeFolder,FolderName,wT);
        elseif(gravityCompensated==1 && local0_world1_coords==0)
            ForceData  =strcat(fPath,StratTypeFolder,FolderName,gT);    
        elseif(gravityCompensated==1 && local0_world1_coords==1)
            ForceData  =strcat(fPath,StratTypeFolder,FolderName,gwT);  
        end

        % State Data
        StateData=strcat(fPath,StratTypeFolder,FolderName,S);

        % Joint Angle Data
        if(anglesDataFlag); AngleData=strcat(fPath,StratTypeFolder,FolderName,A);
        else AngleData=0; end

        % Cartesian Data
        if(cartposDataFlag); CartPos=strcat(fPath,StratTypeFolder,FolderName,C);      
        else CartPos=0; end    
        

        %% (2) Load the data
        % Snap Joints: Was used with PA10, not now.

        JSD=-1;

        %% Load the Data
        FD = load(ForceData);
        SD = load(StateData);
        if (length(FD)>1); loopRate=FD(2,1); end;

        % Joint Angle Data
        if(anglesDataFlag); AD=load(AngleData);
        else AD=-1; end

        % Cartesian Position
        if(cartposDataFlag); CP=load(CartPos);
        else CP=-1; end  
 
    %------------------------- BAXTER -------------------------------------
    elseif(strategySelector('baxter',StrategyType)) 
        % Snap Joints: Was used with PA10, not now.
        JSD=-1;

        if(armSide(1,2) && currentArm==2) % Right
            TopicName='__robot_limb_right_endpoint_state.mat';        
        elseif(armSide(1,1) && currentArm==1) % Left
            TopicName='__robot_limb_left_endpoint_state.mat';  
        else
            if(DB_WRITE)
                fprintf('loadData::ROS Topic Name not assigned.\n');                
            end
        end
        
        % Load the MAT Files
        rosData=load(strcat(baxterPath,FolderName,TopicName));

        % Separate the Data and store
        % Pre-allocation
        [r,~]=size(rosData.data);
        FD=zeros(r,7);
        if(anglesDataFlag);  AD=zeros(r,8); else AD=0; end;
        if(cartposDataFlag); CP=FD;        else CP=0; end;

        % Copy data locally
        for i=1:r
            % Time: all elems - first index as offset. Convert from nsec to sec
            FD(i,1)=( (rosData.data(i,2)+(rosData.data(i,3)*1e-09)) - (rosData.data(1,2)+(rosData.data(1,3)*1e-09)) );
            round(FD(i,1),4,'significant'); % Round to 4sf

            % Copy wrench data
            FD(i,2:7)=rosData.data(i,18:23);

            % End-effector Cartesian Pose
            if(cartposDataFlag)
                % Time
                CP(:,1)=FD(:,1);
                % Pose
                CP(i,2:4)=rosData.data(i,5:7);
                % Convert Quaternions to ZYX Euler and then adjust as RPY or XYZ
                CP(i,5:7)=fliplr(quat2eul(rosData.data(i,8:11)));
            else
                CP=0;
            end        

            % Joint Angles Data
            if(anglesDataFlag)
                % Time
                AD(:,1)=FD(:,1);
            else
                AD=0;
            end                

        end     % for loop                    
    
       % Get the State Transition Vector    
       if(armSide(1,1) && currentArm==1);     SD =load(strcat(fPath,'L_State.dat'));    % Left
       elseif(armSide(1,2) && currentArm==2); SD =load(strcat(fPath,'State.dat')); end  % Right
    end % ROBOT TYPE
    
    %% State Vector Length Verification
    
    % Adjust the data length so that it finishes when mating is finished.            
    r = size(SD);
    if(r(1)==5)
        endTime = SD(5,1);
        
        if(FD(end,1)~=endTime)
            SD(5,1)=FD(end,1);        
        end
        % There are 2 cases to check: (1) If state endTime is less than actual data, and if it is more.  
%         if(FD(end,1)>endTime)
%             % Note that SDR(5,1) is hardcoded as some time k later thatn SDR(4,1). 
%             endTime = floor(endTime/loopRate)+1; % The Angles/Torques data is comprised of steps of magnitude 0.005. Then we round down.
% 
%             % Time will be from 1:to the entry denoted by the State Vector in it's 5th entry. 
%             FD = FD(1:endTime,:);
%             if(anglesDataFlag && cartposDataFlag)            
%                 AD = AD(1:endTime,:);                
%                 CP = CP(1:endTime,:);
%             end
% 
%         else
%             SD(5,1) = FD(end,1);
%         end

    %% Insert an end state for failed assemblies that have less than the 5 entries
    else
        SD(r(1)+1,1) = FD(end,1);  % Enter a new row in SDR which includes the last time value contained in any of the other data vecs.

    end  
    %% Check to make sure that StateData has a finishing time included
    if(DB_WRITE)
        if(strategySelector('SA',StrategyType))
            if(length(SD)<5 && currentArm==2)
                fprintf('StateData does not have 5 entries for the Right Arm. You probably need to include the finishing time of the Assembly task in this vector.\n');
            elseif(length(SD)<5 && currentArm==1)
                fprintf('StateData does not have 5 entries for the left Arm. You probably need to include the finishing time of the Assembly task in this vector.\n');
            end
        end
    end
end
