%*************************** Documentation *******************************
% snapVerification()
%
% Is the main program to execute the relative-change-based hieararchical
% taxonomy (RCBHT). Also includes a probabilistic version called
% probabilistic RCBHT or pRCBHT. 
%
% This is currently done offline. 
%
% This function does the following:
% 1) Loads Force, Angles, Cartesian Positions, and State Transition
% information from either of the following experiments: 
% - PA10 Simulation Straight Line Approach
% - PA10 Simulation Pivot Approach
% - HIRO Simulation/Real Side Approach
% - HIRO Simulation/Real Error Characterization
% - Baxter Simulation/Real Side Approach
%
% Then, for each separate force axis do the following:
% 2) Primitives Level: 
% Perform a linear regression fit of the force data using a correlation
% parameter. Then, assign a "Primitive" label to each segment based on the
% magnitude of the gradent. There are 11 possible classifications. Then, do
% filtering at this level using primitivesCleanUp.
%
% Note:
% There is a possibility to run an optimization algorithm here by turning
% on the optimization flag. This routines optimizes the gradient thresholds
% used in the regressionFit that labels the segments based on gradient
% value. 
%
% 3) Motion Compositions (MCs) Level:
% Combine 2 neighboring primitives to abstract complexity and call these
% motion compositions. Motion compositions can be of 9 different
% types according to the types of primitives that are combined. There are
% rules to label according to primitive type. There is also a filtering
% stage here called cleanUp.m
%
% 4) Low-Level Behaviors (LLBs) Level:
% Combines neighboring compositions to abstract complexity. There are also
% 9 different types of LLBs according to the types of compositions
% combines. There is also a filtering stage here called Refinement.
%
% 5) High-Level Behaviors (HLBs) Level:
% This function is designed to study whether failure is likely in the
% Approach stage or if the whole assembly has been successful. To do so it
% looks for specific characteristics outlined in more detailed in those
% functions or in the documentation.
%
% 6) Bayes Filtering or pRCBHT
% This function converts data found in the MC/LLB/HLB layers into a
% probabilistic rendition and uses that information to study whether
% failure is likely or success has happened.
%
% 7) Save Learning Data
% After the analysis has finished, data that is required for probabilistic
% learning or for failure characterization is performed.
%
%--------------------------------------------------------------------------
% For Reference: Structures and Labels
%--------------------------------------------------------------------------
% Primitives = [bpos,mpos,spos,bneg,mneg,sneg,cons,pimp,nimp,none]      % Represented by integers: [1,2,3,4,5,6,7,8,9,10]  
% statData   = [dAvg dMax dMin dStart dFinish dGradient dLabel]
%--------------------------------------------------------------------------
% actionLbl  = ['a','i','d','k','pc','nc','c','u','n','z'];             % Represented by integers: [1,2,3,4,5,6,7,8,9,10]  
% motComps   = [nameLabel,avgVal,rmsVal,amplitudeVal,
%               p1lbl,p2lbl,
%               t1Start,t1End,t2Start,t2End,tAvgIndex]
%--------------------------------------------------------------------------
% llbehLbl   = ['FX' 'CT' 'PS' 'PL' 'AL' 'SH' 'U' 'N'];                 % Represented by integers: [1,2,3,4,5,6,7,8]
% llbehStruc:  [actnClass,...
%              avgMagVal1,avgMagVal2,AVG_MAG_VAL,
%              rmsVal1,rmsVal2,AVG_RMS_VAL,
%              ampVal1,ampVal2,AVG_AMP_VAL,
%              mc1,mc2,
%              T1S,T1_END,T2S,T2E,TAVG_INDEX]
%--------------------------------------------------------------------------
%
% Inputs:
% StrategyType  : the number of strategy types vary according to assembly
%                 technique, or robot used, or number of arms used. Below is
%                 a list of current strategies. These can be best
%                 organized/selected through the strategySelector.m func.
%                   - SLA ----------------------------
%                   SIM_HIRO_SLA
%                   SIM_HIRO_SLA_NOISE
%                   SIM_PA10_ONE_SL_SUCCESS
%                   - PA ----------------------------   
%                   SIM_HIRO_ONE_PA_SUCCESS,
%                   SIM_HIRO_ONE_PA_NOISE
%                   SIM_PA10_ONE_PA_SUCCESS,
%                   - SA ----------------------------
%                   % --- Simulated HIRO
%                   SIM_HIRO_ONE_SA_SUCCESS
%                   SIM_HIRO_ONE_SA_ERROR_CHARAC_LoopBack_x
%                   SIM_HIRO_ONE_SA_ERROR_CHARAC_LoopBack_y
%                   SIM_HIRO_ONE_SA_ERROR_CHARAC_Prob
%                   SIM_HIRO_ONE_SA_ERROR_CHARAC_SVM
%                   SIM_HIRO_TWO_SA_SUCCESS
%                   % --- Real HIRO
%                   REAL_HIRO_ONE_SA_SUCCESS
%                   % --- Real HIRO Error Charac
%                   REAL_HIRO_ONE_SA_ERROR_CHARAC
%                   % --- Simulated Baxter
%                   SIM_BAXTER_SA_SUCCES
%                   SIM_BAXTER_SA_DUAL
%                   % --- Real Baxter
%                   REAL_BAXTER_ONE_SA_SUCCESS
%                   REAL_BAXTER_TWO_SA_SUCCESS
% FolderName    : Name of folder where results are stored, user based.
% first         : which plot do you want to segment first
% last          : which plot do you want to segment last
%                 where first:last is a vector list.
%
% Outputs:
% hlbBelief     : the belief or posterior probability about the success
%                 rate of the task.
% llbBelief     : the belief about all the different LLBs found throughout
%                 the task
% stateTimes    : col vector of automata state transition times
% hlbehStruc    : boolean row vec containing one element per automata state
%                 indicating whether state was successful based on 
%                 pre-probabilistic analysis.
% fcAvgData     : contains the actual means or averages of all computed
%                 values in fc
% boolFCData    : boolean structure that contains data for each
%                 of the tests carried out. 
%**************************************************************************
function  [hlbBelief,llbBelief,...
           stateTimes,hlbehStruc,...
           fcAvgData,boolFCData] = snapVerification(StrategyType,FolderName,first,last)
%  function snapVerification()
%  StrategyType = 'HSA';
%  FolderName='20120426-1844-SideApproach-S';
%  first=1;last=6;

%% Global Variables

    % PLOT INDEX
    % Maintain global variables to identify which index (1 out of 6) of a wrench plot (FxFyFzMxMyMz) we would like to plot. 
    global axisIndex;
    global firstIndex;
    global lastIndex; 
    
    firstIndex=first;
    lastIndex= last;
    axisIndex=firstIndex; 
  
%-----------------------------------------------------------------------------------------
    % RESULTS PATH
    global hiroPath;
    global baxterPath;
    hiroPath='/media/vmrguser/DATA/Documents/School/Research/AIST/Results/'; % The path at which you want to save the main body of results. Folders will be created within this folder for different strategyTypes.
    baxterPath='/home/vmrguser/ros/indigo/baxter_ws/src/birl_baxter/birl_demos/pivotApproach/pa_demo/bags/';
    
%-----------------------------------------------------------------------------------------

    % Index to choose right and left arms in for loop
    global armSide;                     % Which are are you considering, right, left, or both. armSide will be a 1x2 vector of bools with 1st elem=right, 2nd_elem=right: armside[left,right]
    leftArmFlag =1;                     % Boolean values as flags. At least one arm must be true.
    rightArmFlag=1;    
    armSide=[leftArmFlag,rightArmFlag]; % This variable helps us to know whether we are working with the right or left. Useful to plot figures and save data to file.
    
    global currentArm;
    currentArm=2;                       % 1 for left arm, 2 for current arm. 
%-----------------------------------------------------------------------------------------
    % FIGURE HANDLE
    % Create figures for the right and left arms, and provide them the
    % right window focus

    global rarmHandle;
    global larmHandle; 

    if(armSide(1,1) && ~armSide(1,2))
        larmHandle=figure('Name','Left Arm Forces','NumberTitle','off','position', [0, 0, 970, 950]);
        movegui(larmHandle,'west');
        figure(larmHandle);
    elseif(~armSide(1,1) && armSide(1,2))
        rarmHandle=figure('Name','Right Arm Forces','NumberTitle','off','position', [990, 0, 970, 950]);
        movegui(rarmHandle,'east');
        figure(rarmHandle);
    else
        larmHandle=figure('Name','Left Arm Forces','NumberTitle','off','position', [0, 0, 970, 950]);
        movegui(larmHandle,'west');   
        rarmHandle=figure('Name','Right Arm Forces','NumberTitle','off','position', [990, 0, 970, 950]);
        movegui(rarmHandle,'east');
        figure(rarmHandle);
    end
    
%-----------------------------------------------------------------------------------------
    % GRADIENT OPTIMIZATION
    %opengl software;       % If matlab crashes make sure to enable this command as matlab may not be able to render the state colors in hardware. 
    global Optimization;    % The Optimization variable is used to extract gradient classifications from a first trial. Normally should have a zero value.
    Optimization    = 0;    % If you want to calibrate gradient values turn this to 1 and make sure that all calibration files found in:
                            % %{USER}\Documents\School\Research\AIST\Results\ForceControl\${StratTypeFolder}\gradClassFolder
                            % are deleted. 
                            % After one run, turn the switch off. The routine will used the saved values to file. 
                            
%------------------------------------------------------------------------------------------
    
    % DEBUGGING
    global DB_PLOT;         % To plot graphs
    global DB_PRINT;        % To print console messages
    global DB_WRITE;        % To write data to file
    global DB_DEBUG;        % To enable debugging capabilities
    
    DB_PLOT         = 1;
    DB_PRINT        = 0; 
    DB_WRITE        = 1;
    DB_DEBUG        = 0;
    
%------------------------------------------------------------------------------------------    
   
    % Helps to Check the Existence of files
    global initWriteToFileFlag;
    initWriteToFileFlag = 0;
    
%------------------------------------------------------------------------------------------    

    % FILTERING
    global MC_COMPS_CLEANUP_CYCLES;
    global LLB_REFINEMENT_CYCLES;  
    
    MC_COMPS_CLEANUP_CYCLES         = 4;    % Value for FailureCharac 0 % 2013Aug value for normal RCBHT is 4. Pre2013 value was 2    
    LLB_REFINEMENT_CYCLES           = 5;    % Value for FailureCharac 2 % 2013Aug value for normal RCBHT is 5. Pre2013 value was 4
    
%------------------------------------------------------------------------------------------

    % CAPTURED DATA
    global anglesDataFlag;
    global cartposDataFlag;
    global local0_world1_coords;
    global gravityCompensated;
    
    anglesDataFlag                  = 0; 	% If you want to current joint angle data for analysis set to true. 
    cartposDataFlag                 = 0;    % If you want to use cartesian coordinates wrt the wrst set to true.    
    local0_world1_coords            = 0;    % If you want to plot wrt end-eff set to false, wrt the world, set to true.
    gravityCompensated              = 0;    % If you want to plot torques that have used gravity compensation
    
%------------------------------------------------------------------------------------------

    % FAILURE CHARACTERIZATION TESTING FLAGS
    global xDirTest;
    global yDirTest;
    global xRollDirTest;
    
    xDirTest                        = 1;    % Normally set to true. Except when training specific cases of failure.
    yDirTest                        = 1;
    xRollDirTest                    = 1;
    
    % Training success flag
    successFlag                     = 0;

%------------------------------------------------------------------------------------------
    
    % Layer Flags - to run or not to run layers
    global FAILURE_CHARACTERIZATION;        % Flag checked in hlbehCompositions_new
    PRIM_LAYER                      = 1;    % Compute the primitives layer
    MC_LAYER                        = 1;    % Compute the  motion compositions and clean up cycle
    LLB_LAYER                       = 1;    % Compute the low-level behavior and refinement cycle
    HLB_LAYER                       = 1;    % Compute the higher-level behavior
    pRCBHT                          = 0;    % Compute the llb and hlb Beliefs  
    FAILURE_CHARACTERIZATION        = 0;    % Run failure characterization analysis
%------------------------------------------------------------------------------------------
%% Debug Enable Commands
% Not supported for cplusplus code generation
    if(DB_DEBUG)
        dbstop if error
    end
    
%% Initialization/Preprocessing
    % Create a CELL of strings to capture the types of possible force-torque data plots
    plotType = ['Fx';'Fy';'Fz';'Mx';'My';'Mz'];
    stateTimes=-1;
%% A) Load Data and Plot Forces
    plotOptions=1;  % plotOptions=0: plot separate figures. =1, plot in subplots
    
    % Consider single or dual arm case to output relevant data.    
    if(armSide(1,1))                % Left Arm
        currentArm=1;
        [fPath,StratTypeFolder,...
         ~,forceDataL,...
         ~,~,...                   %angleData,angleDataL,...
         ~,~,...                   %cartPosData,cartPosDataL,...
         stateData,~,axesHandlesLeft,...
         ~,~,TL_L,BL_L]=snapData3(StrategyType,FolderName,plotOptions);
    
    end
    if(armSide(1,2))            % Right Arm
        currentArm=2;
        [fPath,StratTypeFolder,...
         forceData,~,...
         ~,~,...                   %angleData,angleDataL,...
         ~,~,...                   %cartPosData,cartPosDataL,...
         stateData,axesHandlesRight,~,...
         TL,BL,~,~]=snapData3(StrategyType,FolderName,plotOptions);    
    end
 
%% B) Relative-Change Behavior Hierarchical Taxonomy: 
    % This taxonomy seeks to yield high-level estimates of what the robot
    % is doing. Currently assumes a SideApproach strategy. Data is
    % evaluated through the primitives, motion composition, LLB, HLB layer.
    % Optionally we can run a BayesianFilter to get a likelihood on the
    % result. Can also run a calibration routine to tune fitting parameters
    % to different environments.
   
    % Switch to the right arm figure    
    figure(rarmHandle);
    
%% B_Right_1) Perform regression curves for force moment reasoning for the right/left arm                  
        
    %% Set variables according to whether we are using the right arm, the left arm, or both.
    if(armSide(1,1) && armSide(1,2)); armIndex=2;
    else                              armIndex=1;
    end
    armFlag=false;          % Used to tell which arm has been executed
    
    for i=1:armIndex                                                    % Compute Right arm first, then left.
        if(armSide(1,2) && ~armFlag)        
            currentArm=2;
            % Create a matlab pointer struc to force structures, axis handles, to be used later in RCBHT analysis 
            forceData_p = libpointer('doublePtr',forceData);            % Data is extracted by calling forceData_p.Value
            axesHandles = axesHandlesRight;
            TL_p = libpointer('doublePtr',TL);
            BL_p = libpointer('doublePtr',BL);
            armFlag=true;
        else            
            currentArm=1;
            forceData_p = libpointer('doublePtr',forceDataL); % If want to extract array contents do: forceData_p.Value(index)
            axesHandles = axesHandlesLeft;
            TL_p= libpointer('doublePtr',TL_L);
            BL_p = libpointer('doublePtr',BL_L);
        end
        
        %% Iterate through each of the six force-moment plots Fx Fy Fz Mx My Mz
        % generated in snapData3 and superimpose regressionfit lines in each of
        % the diagrams.           
        for axisIndex=first:last   
            %% PRIMITIVES LAYER: First layer of the RCBHT. Perform fitting and gradient labels
            if(PRIM_LAYER)
                wStart  = 1;                                    % Initialize index for starting analysis

                % Determine how many handles
                if(last-first==0)
                    pHandle = 0;
                else
                    pHandle = axesHandles(axisIndex);           % Retrieve the handle for each of the force curves
                end

                % Determine the type of the plot
                pType   = plotType(axisIndex,:);                  % Use curly brackets to retrieve the plotType out of the cell

                % Compute regression curves for each force curve
                [statData,curHandle,gradLabels]=fitRegressionCurves(fPath,StrategyType,StratTypeFolder,FolderName,pType,forceData_p.Value,stateData,wStart,pHandle,TL_p.Value,BL_p.Value,axisIndex);                        
                
                if(Optimization==1)
                   gradientCalibration(fPath,StratTypeFolder,stateData,statData,axisIndex);

                   llbBelief=-1;
                   hlbBelief=-1; % Dummy variables for this segment
                end

                % Reset file flag to indicate first run for next axis
                initWriteToFileFlag=0; 
            end     % End PRIMITIVES_LAYER

    %% Do the following only if (gradient classification) optimization is turned off
            if(Optimization==0) 

    %% C)       Generate the compound motion compositions for each of the six force elements

                if(MC_LAYER)
                    % If you want to save the .mat of motComps, set saveData to 1. 
                    saveData = 0;
                    motComps = CompoundMotionComposition(StrategyType,statData,saveData,gradLabels,curHandle,TL_p.Value(axisIndex),BL_p.Value(axisIndex),fPath,StratTypeFolder,FolderName,pType,stateData); %TL(axisIndex+2) skips limits for the first two snapJoint suplots              

                    if(axisIndex==1)
                        MCFx = motComps;
                    elseif(axisIndex==2)
                        MCFy = motComps;
                    elseif(axisIndex==3)
                        MCFz = motComps;
                    elseif(axisIndex==4)
                        MCMx = motComps;
                    elseif(axisIndex==5)
                        MCMy = motComps;
                    elseif(axisIndex==6)
                        MCMz = motComps;
                    end     
                    
                    % Reset file flag to indicate first run for next axis
                    initWriteToFileFlag=0; 
                end

    %% D)       Generate the low-level behaviors

                if(LLB_LAYER)
                    % Combine motion compositions to produce low-level behaviors
                    [llbehStruc,llbehLbl] = llbehComposition(StrategyType,motComps,curHandle,TL_p.Value(axisIndex),BL_p.Value(axisIndex),fPath,StratTypeFolder,FolderName,pType);                          

    %% E)          Copy to a fixed structure for post-processing        
                    if(axisIndex==1)
                        llbehFx = llbehStruc;
                    elseif(axisIndex==2)
                        llbehFy = llbehStruc;
                    elseif(axisIndex==3)
                        llbehFz = llbehStruc;
                    elseif(axisIndex==4)
                        llbehMx = llbehStruc;
                    elseif(axisIndex==5)
                        llbehMy = llbehStruc;
                    elseif(axisIndex==6)
                        llbehMz = llbehStruc;
                    end
                    
                    % Reset file flag to indicate first run for next axis
                    initWriteToFileFlag=0; 
                end     % LLBs
            end         % Optimization==0       
        end             % End axis=first:last

    %%  F) After all axes are finished computing the LLB layer, generate and plot labels for high-level behaviors.
        if(HLB_LAYER)                        
            % Save all llbeh strucs in a structure. One field for each llbeh. This is an
            % update from the previous array. 
            % 2013July: 
            mcFlag=2; llbFlag=3;

            %% Right Arm          
            if(armSide(1,2) && currentArm==2) % Right Arm
                % Each of these structures are mx17, so they can be separated in this way.    
                [motCompsFM,MCnumElems]     = zeroFill(MCFx,MCFy,MCFz,MCMx,MCMy,MCMz,mcFlag);
                [llbehFM   ,LLBehNumElems]  = zeroFill(llbehFx,llbehFy,llbehFz,llbehMx,llbehMy,llbehMz,llbFlag);

                % Generate the high level behaviors for the right arm        
                [hlbehStruc,fcAvgData,successFlag,boolFCData]=hlbehComposition_new(motCompsFM,MCnumElems,llbehFM,LLBehNumElems,llbehLbl,stateData,axesHandlesRight,TL_p.Value,BL_p.Value,fPath,StrategyType,FolderName);    
            end
            
            %% Left Arm
            if(armSide(1,1) && currentArm==1) % LEft Arm

                % Each of these structures are mx17, so they can be separated in this way.    
                [motCompsFM_L,MCnumElems_L]    = zeroFill(MCFx,MCFy,MCFz,MCMx,MCMy,MCMz,mcFlag);
                [llbehFM_L ,LLBehNumElems_L]   = zeroFill(llbehFx,llbehFy,llbehFz,llbehMx,llbehMy,llbehMz,llbFlag);
                % Generate the high level behaviors for the left arm        
                [hlbehStrucL,fcAvgDataL,successFlagL,boolFCDataL]=hlbehComposition_new(motCompsFM_L,MCnumElems_L,llbehFM_L,LLBehNumElems_L,llbehLbl,stateData,axesHandlesLeft,TL_p.Value,BL_p.Value,fPath,StrategyType,FolderName);                
            end
        end
    end % End armSide for loop
%% G) Compute the Bayesian Filter for the HLB
    if(Optimization==0)
        if(pRCBHT==1)
            Status = 'Offline'; % Can be online as well. 
            [hlbBelief, llbBelief, stateTimes] = SnapBayesFiltering(fPath,StrategyType,FolderName,Status);
        else
            % Place dummy variables in output when Optimization is running
            hlbBelief=-1;
            llbBelief=-1;            
            stateTimes=-1;
        end
    end   
    
%% F) Save Learning Data To File

    %% Probabilistic Data
    
    %% Failure Characterization Data
    if(FAILURE_CHARACTERIZATION)
        % If the assembly was successful record its data
        if(successFlag)

            %% x-Dir
            if(xDirTest)
                % Do these if there was no failure, ie boolFCData is zero.
                if(boolFCData(1,1)==0)          % Order of indeces is connected to the specific names of variables.
                    % 1) Update Historically Averaged My.Rot.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(1,1);
                    updateHistData(fPath,StratTypeFolder,avgData,'s_histMyRotAvgMag.mat');
                end
                if(boolFCData(2,1)==0)
                    % 2) Update Historically Averaged Fz.Rot.AvgMag
                    avgData = fcAvgData(1,2);        
                    updateHistData(fPath,StratTypeFolder,avgData,'s_histFzRotAvgMag.mat');
                end
            end
            %% y-Dir
            if(yDirTest)
                if(boolFCData(3,1)==0)
                    % 1) Update Historically Averaged Mz.Rot.Pos.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(1,1);
                    updateHistData(fPath,StratTypeFolder,avgData,'s_histMzRotPosAvgMag.mat');
                end
                if(boolFCData(4,1)==0)
                    % 1) Update Historically Averaged Mz.Rot.Min.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(2,2);
                    updateHistData(fPath,StratTypeFolder,avgData,'s_histMzRotMinAvgMag.mat');            
                end
            end
           %% xRoll-DirPos
           if(xRollDirTest)
               if(boolFCData(5,1)==0)
                    % 1) Update Historically Averaged Fx.App.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(3,1);
                    updateHistData(fPath,StratTypeFolder,avgData,'s_histFxAppPosAvgMag.mat');
               end

               if(boolFCData(6,1)==0)
                    % 2) Update Historically Averaged Fz.App.AvgMag
                    avgData = fcAvgData(3,2);        
                    updateHistData(fPath,StratTypeFolder,avgData,'s_histFzAppPosAvgMag.mat');        
               end


               %% xRoll-DirMin
               if(boolFCData(7,1)==0)
                    % 1) Update Historically Averaged Fx.App.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(4,1);
                    updateHistData(fPath,StratTypeFolder,avgData,'s_histFxAppMinAvgMag.mat');
               end

               if(boolFCData(8,1)==0)
                    % 2) Update Historically Averaged Fz.App.AvgMag
                    avgData = fcAvgData(4,2);        
                    updateHistData(fPath,StratTypeFolder,avgData,'s_histFzAppMinAvgMag.mat');        
               end
           end           

        %% If the assembly was unsuccessful update the historical values for those key parameters of failure    
        else

            %% x-Dir
            if(xDirTest)
                % Do these if there was failure, ie fcbool is 1.
                if(boolFCData(1,1))
                    % 1) Update Historically Averaged My.Rot.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(1,1);
                    updateHistData(fPath,StratTypeFolder,avgData,'f_histMyRotAvgMag.mat');
                end
                if(boolFCData(2,1))
                    % 2) Update Historically Averaged Fz.Rot.AvgMag
                    avgData = fcAvgData(1,2);        
                    updateHistData(fPath,StratTypeFolder,avgData,'f_histFzRotAvgMag.mat');
                end
            end
            %% y-Dir
            if(yDirTest)
                if(boolFCData(3,1))
                    % 1) Update Historically Averaged Mz.Rot.Pos.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(2,1);
                    updateHistData(fPath,StratTypeFolder,avgData,'f_histMzRotPosAvgMag.mat');
                end
                if(boolFCData(4,1))
                    % 2) Update Historically Averaged Mz.Rot.Min.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(2,2);
                    updateHistData(fPath,StratTypeFolder,avgData,'f_histMzRotMinAvgMag.mat');            
                end
            end
            %% xRollDir-Pos       
            if(xRollDirTest)
                %% xRollDirPos
                if(boolFCData(5,1))
                    % 1) Update Historically Averaged Fx.App.Min.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(3,1);
                    updateHistData(fPath,StratTypeFolder,avgData,'f_histFxAppPosAvgMag.mat');
                end

                if(boolFCData(6,1))
                    % 2) Update Historically Averaged Fz.App.Min.AvgMag
                    avgData = fcAvgData(3,2);        
                    updateHistData(fPath,StratTypeFolder,avgData,'f_histFzAppPosAvgMag.mat');          
                end

                %% xRollDir-Min
                if(boolFCData(7,1))
                    % 1) Update Historically Averaged Fx.App.Min.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(4,1);
                    updateHistData(fPath,StratTypeFolder,avgData,'f_histFxAppMinAvgMag.mat');
                end

                if(boolFCData(8,1))
                    % 2) Update Historically Averaged Fz.App.Min.AvgMag
                    avgData = fcAvgData(4,2);        
                    updateHistData(fPath,StratTypeFolder,avgData,'f_histFzAppMinAvgMag.mat');          
                end            
            end
        end
          save(strcat(fpath,StratTypeFolder,FolderName,'/','MATs','/output.mat'),'fcAvgData','boolFCData');
    end % End FailureCharacterizationLayer
end