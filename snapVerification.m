%*************************** Documentation *******************************
% StrategyType  : HIRO - Online Snap Verification for Side Approach
% FolderName    : Name of folder where results are stored, user based.
% first         : which plot do you want to segment first
% last          : which plot do you want to segment last
%                 where first:last is a vector list.
%**************************************************************************
function  [hlbBelief,llbBelief,stateTimes,hlbehStruc] = snapVerification(StrategyType,FolderName,first,last)
%  function snapVerification()
%  StrategyType = 'HSA';
%  FolderName='20120426-1844-SideApproach-S';
%  first=1;last=6;

%% Global Variables
%-----------------------------------------------------------------------------------------
    %opengl software;       % If matlab crashes make sure to enable this command as matlab cannot render the state colors in hardware. 
    global Optimization;    % The Optimization variable is used to extract gradient classifications from a first trial. Normally should have a zero value.
    Optimization = 0;       % If you want to calibrate gradient values turn this to 1 and make sure that all calibration files found in:
                            % C:\Documents and Settings\suarezjl\My Documents\School\Research\AIST\Results\ForceControl\SideApproach\gradClassFolder
                            % are deleted. 
                            % After one run, turn the switch off. The routine will used the saved values to file. 
                            
%------------------------------------------------------------------------------------------
    
    global DB_PLOT;         % To plot graphs
    global DB_PRINT;        % To print console messages
    global DB_WRITE;        % To write data to file
    global DB_DEBUG;        % To enable debugging capabilities
    
    DB_PLOT=1;
    DB_PRINT=0; 
    DB_WRITE=1;
    DB_DEBUG=0;
    
%------------------------------------------------------------------------------------------    

    global MC_COMPS_CLEANUP_CYCLES;
    global LLB_REFINEMENT_CYCLES;  
    
    MC_COMPS_CLEANUP_CYCLES         = 2;    % Originally 3    
    LLB_REFINEMENT_CYCLES           = 4;    % Originally 4
    
%------------------------------------------------------------------------------------------

    % Variables - to run or not to run layers
    PRIM_LAYER  = 1;    % Compute the primitives layer
    MC_LAYER    = 1;    % Compute the  motion compositions and clean up cycle
    LLB_LAYER   = 1;    % Compute the low-level behavior and refinement cycle
    HLB_LAYER   = 1;    % Compute the higher-level behavior
    pRCBHT      = 0;    % Compute the llb and hlb Beliefs  
%------------------------------------------------------------------------------------------
%% Debug Enable Commands
% Not supported for cplusplus code generation
%     if(DB_DEBUG)
%         dbstop if error
%     end
    
%% Initialization/Preprocessing
    % Create a CELL of strings to capture the types of possible force-torque data plots
    plotType = ['Fx';'Fy';'Fz';'Mx';'My';'Mz'];
    stateTimes=-1;
%% A) Plot Forces
    plotOptions=1;  % plotOptions=0: plot separate figures. =1, plot in subplots
    [fPath,StratTypeFolder,forceData,stateData,axesHandles,TL,BL]=snapData3(StrategyType,FolderName,plotOptions);

%% B) Perform regression curves for force moment reasoning          
    % Iterate through each of the six force-moment plots Fx Fy Fz Mx My Mz
    % generated in snapData3 and superimpose regressionfit lines in each of
    % the diagrams. 
    for axisIndex=first:last
        if(PRIM_LAYER)
            wStart  = 1;                            % Initialize index for starting analysis

            % Determine how many handles
            if(last-first==0)
                pHandle = 0;
            else
                pHandle = axesHandles(axisIndex);           % Retrieve the handle for each of the force curves
            end

            % Determine the type of the plot
            pType   = plotType(axisIndex,:);                  % Use curly brackets to retrieve the plotType out of the cell

            % Compute regression curves for each force curve
            [statData,curHandle,gradLabels]=fitRegressionCurves(fPath,StrategyType,StratTypeFolder,FolderName,pType,forceData,stateData,wStart,pHandle,TL,BL,axisIndex);        

            if(Optimization==1)
               gradientCalibration(fPath,StratTypeFolder,stateData,statData,axisIndex);

               llbBelief=-1;
               hlbBelief=-1; % Dummy variables for this segment
            end
        end     % End PRIMITIVES_LAYER
        
%% Do the following only if (gradient classification) optimization is turned off
        if(Optimization==0) 
            
            
%% C)       Generate the compound motion compositions for each of the six force elements

            if(MC_LAYER)
                % If you want to save the .mat of motComps, set saveData to 1. 
                saveData = 0;
                motComps = CompoundMotionComposition(StrategyType,statData,saveData,gradLabels,curHandle,TL(axisIndex),BL(axisIndex),fPath,StratTypeFolder,FolderName,pType,stateData); %TL(axisIndex+2) skips limits for the first two snapJoint suplots    
            end

%% D)       Generate the low-level behaviors
        
            if(LLB_LAYER)
                % Combine motion compositions to produce low-level behaviors
                [llbehStruc,llbehLbl] = llbehComposition(StrategyType,motComps,curHandle,TL(axisIndex),BL(axisIndex),fPath,StratTypeFolder,FolderName,pType);
                
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
            end
        end                                
    end % End all axes
%%  F) After all axes are finished computing the LLB layer, generate and plot labels for high-level behaviors.
    if(HLB_LAYER)                        
        % Save all llbeh strucs in a structure. One field for each llbeh. This is an
        % update from the previous cell array. July 2013. Each of these
        % structures are mx17, so they can be separated in this way.                
        [llbehFM,numElems] = zeroFill(llbehFx,llbehFy,llbehFz,llbehMx,llbehMy,llbehMz);
        
        % Generate the high level behaviors
        hlbehStruc=hlbehComposition_new(llbehFM,numElems,llbehLbl,stateData,axesHandles,TL,BL,fPath,StratTypeFolder,FolderName);    
    end
    
%% G) Compute the Bayesian Filter for the HLB
    if(Optimization==0)
        if(pRCBHT==1)
            Status = 'Offline'; % Can be online as well. 
            [hlbBelief, llbBelief, stateTimes] = SnapBayesFiltering(StrategyType,FolderName,Status);
        else
            % Place dummy variables in output when Optimization is running
            hlbBelief=-1;
            llbBelief=-1;            
            stateTimes=-1;
        end
    end   
end