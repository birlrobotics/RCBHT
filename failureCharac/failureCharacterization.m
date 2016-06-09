%%---------------------- Documentation -------------------------------------
% failureCharacterization
%
% X-Direction Deviation Characteristics:
% i)  My magnitude is greater than average
% ii) 1st 1/3 of Fz.Rot exhibits more variation than normal.
%
% Inputs
% fpath:            - path of working directory
% StrategyType      - type of strategy/experiment
% stateData         - col vec to automata state transition times
% motCompsFM        - Motion composition structure: mx11x6 (Num of MCs, 11 elements, 6 axis) 
% mcNumElems        - 6x1 col vec with number of elements of mc's that are not ==-99. Recal that in HLB Layer, there was filling to create a single data structure.
% llbehFM           - Low-level Beh structure: mx17x6 (Num of LLBs, 17 data elements, 6 axis)
% llbehNumElems     - same as mcNumElems
% whichState        - indicates which automata state we want to analyze
%
% Output:
% bool_fcData       - boolean. [3x7 structure. 3: xDir, yDir, xRollDir. 7: first two, check whether 
%                     original categories for test show success/failure of task. If failure, a 0 will 
%                     appear in whichever parameter is correlated, implying whether failure comes from xDir,yDir,xRollDir or a comb. 
% avgData           - array of averaged values [mx2] for xDir, yDir, xRollDir
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
%-------------------------------------------------------------------------
function [bool_fcData,avgData]=failureCharacterization(fPath,StratTypeFolder,stateData,motCompsFM,mcNumElems,~,~,whichState)%(fPath,StratTypeFolder,stateData,motCompsFM,mcNumElems,llbehFM,llbehNumElems,whichState)

%% Global Variables
    % FAILURE CHARACTERIZATION TESTING FLAGS. They serve as masks.
    global xDirTest;                            % Enables analysis on xDir, yDir, xRoll.
    global yDirTest;
    global xRollDirTest;    

%% Local Variables

    % Automata State
    approachState=1; rotState=2; %snapState=3;matState=4;

    % Divergence Direction Analysis. 
    xDir=1;yDir=2;xRot=3;%yRotAnalysis=5;zRotAnalysis=6;
    
    % Standard indeces
    Fx=1; Fz=3; My=5; Mz=6;
    
    % DataStructures
    MCs=2;  % Flag to indicate we are using motion compositions
%    LLBs=3; % Flag to indicate we are using low-level behaviors
    
    % Data Types
    magnitudeType   = 1;
%   rmsType         = 2;
    amplitudeType   = 3;    
    
    % Create structure for avgData: 2 cols per axis
    % avgData = [MyRot,     FzRot
    %            MzRotPos,  MzRotMin;
    %            FxAppPos,  FzAppPos,
    %            FzAppPos,  FzAppMin]
    numSet      =4;
    numParams   =2;
    totParamSet =8;
    avgData = zeros(numSet,numParams);

%% Create outcome data structures for both success and failure: bool_fcData__Dir: [failed_condition1? FxAppAvgMag FzAppAvgMag MzRotPosAvgMag MzRotMinAvgMag FxAppPosAvgMag FzAppPosAvgMag FxAppMinAvgMag FzAppMinAvgMag;
%%                                                                                 failed_condition2? FxAppAvgMag FzAppAvgMag MzRotPosAvgMag MzRotMinAvgMag FxAppPosAvgMag FzAppPosAvgMag FxAppMinAvgMag FzAppMinAvgMag ]
    % bool_fcData: [
    bool_fcDataXDir         = [0,ones(1,totParamSet); 0 ones(1,totParamSet)];   % Rows 1,2 for xDir
    bool_fcDataYDir         = [0,ones(1,totParamSet); 0 ones(1,totParamSet)];   % Rows 3,4 for yDir
    bool_fcDataXRollDir     = [0,ones(1,totParamSet); 0 ones(1,totParamSet);    % Rows 1,2 for xRollDirPos
                               0,ones(1,totParamSet); 0 ones(1,totParamSet) ];  % Rows 3,4 for xMinDirMin

%% Load All FAILURE Historical Averaged Data First
%---XDir-----------------------------------------------------------------------------------------------------
    matName='f_histMyRotAvgMag.mat';    [f_histAvgMyRotAvgMag,~]    = loadFCData(fPath,StratTypeFolder,matName);
    matName='f_histFzRotAvgMag.mat';    [f_histAvgFzRotAvgMag,~]    = loadFCData(fPath,StratTypeFolder,matName);
%---YDir-----------------------------------------------------------------------------------------------------
    matName='f_histMzRotPosAvgMag.mat'; [f_histAvgMzRotPosAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);
    matName='f_histMzRotMinAvgMag.mat'; [f_histAvgMzRotMinAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);    
%---XRollDirPos-------------------------------------------------------------------------------------------------
    matName='f_histFxAppPosAvgMag.mat';    [f_histAvgFxAppPosAvgMag,~]    = loadFCData(fPath,StratTypeFolder,matName);
    matName='f_histFzAppPosAvgMag.mat';    [f_histAvgFzAppPosAvgMag,~]    = loadFCData(fPath,StratTypeFolder,matName); 
%---XRollDirMin-------------------------------------------------------------------------------------------------
    matName='f_histFxAppMinAvgMag.mat';    [f_histAvgFxAppMinAvgMag,~]    = loadFCData(fPath,StratTypeFolder,matName);
    matName='f_histFzAppMinAvgMag.mat';    [f_histAvgFzAppMinAvgMag,~]    = loadFCData(fPath,StratTypeFolder,matName);    
%% Approach State Analysis    
    if(whichState==approachState)

        %% Go through all the analysis states
        for analysis=xDir:xRot % May include later when more case scenarios exist.
        

            %% X-Direction Analysis
            if(analysis==xDir && xDirTest) % xDirTest &associated params are used during a testing phase, so that only that element is being tested (ie a mask). During real trials all params will be true.

                %% Analyze Deviation in X-Direction            
                % 1) Load SUCCESSFUL historically averaged My.Rot.AvgMag data
                matName='s_histMyRotAvgMag.mat'; [s_histAvgMyRotAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);

                % Load successful historically averaged Fz.Rot.AvgMag data
                matName='s_histFzRotAvgMag.mat'; [s_histAvgFzRotAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);           

                %% Test 1st condition: My.Rot
                dataStruc = MCs;                dataType = magnitudeType;
                dataThreshold  = [1.20,0.80];   percStateToAnalyze = 0.5;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied
                [bool_analysisOutcome1,AvgMyRotMag]= analyzeAvgData(motCompsFM,mcNumElems,dataType,stateData,My,rotState,s_histAvgMyRotAvgMag,dataStruc,percStateToAnalyze,dataThreshold);

                %% Test 2nd condition: Fz.Rot
                dataStruc=MCs;                  dataType = magnitudeType;
                dataThreshold  = [1.10,0.90];   percStateToAnalyze = 0.5;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied
                [bool_analysisOutcome2,AvgFzRotMag]= analyzeAvgData(motCompsFM,mcNumElems,dataType,stateData,Fz,rotState,s_histAvgFzRotAvgMag,dataStruc,percStateToAnalyze,dataThreshold);

                %% Compute Outputs
                bool_fcDataXDir(1:2,1)  = [bool_analysisOutcome1;bool_analysisOutcome2];
                avgData(1,:)            = [AvgMyRotMag,AvgFzRotMag];                       % First Row

                %% Analyze 1st restult to find out which Failure this is. If 0, that is the correlation and indication of our test. If 1 ignore.            
                % Analyze MyRot
                if(bool_analysisOutcome1)
                    dataThreshold  = [1.55,0.65]; % [max,min]                    
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMyRotMag/f_histAvgMyRotAvgMag(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MyRot=1;    else MyRot=0;       end; %[MyRot,~]= analyzeAvgData(motCompsFM,dataType,stateData,My,rotState,     f_histAvgMyRotAvgMag,dataStruc,percStateToAnalyze,dataThreshold); 
                    ratio=AvgMyRotMag/f_histAvgFzRotAvgMag(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzRot=1;    else FzRot=0;       end; 
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMyRotMag/f_histAvgMzRotPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzRotPos=1; else MzRotPos=0;    end;  
                    ratio=AvgMyRotMag/f_histAvgMzRotMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzRotMin=1; else MzRotMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMyRotMag/f_histAvgFxAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FxAppPos=1; else FxAppPos=0;    end;  
                    ratio=AvgMyRotMag/f_histAvgFzAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppPos=1; else FzAppPos=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMyRotMag/f_histAvgFxAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FxAppMin=1; else FxAppMin=0;    end;  
                    ratio=AvgMyRotMag/f_histAvgFzAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppMin=1; else FzAppMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    bool_fcDataXDir(1,2:totParamSet+1) = [MyRot,FzRot,MzRotPos,MzRotMin,FxAppPos,FzAppPos,FxAppMin,FzAppMin];
                end
                % Analyze FzRot
                if(bool_analysisOutcome2)
                    dataThreshold  = [1.35,0.75];                   
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzRotMag/f_histAvgMyRotAvgMag(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MyRot=1;    else    MyRot=0;    end; %[MyRot,~]= analyzeAvgData(motCompsFM,dataType,stateData,My,rotState,     f_histAvgMyRotAvgMag,dataStruc,percStateToAnalyze,dataThreshold); 
                    ratio=AvgFzRotMag/f_histAvgFzRotAvgMag(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzRot=1;    else    FzRot=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzRotMag/f_histAvgMzRotPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzRotPos=1; else MzRotPos=0;    end;  
                    ratio=AvgFzRotMag/f_histAvgMzRotMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzRotMin=1; else MzRotMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzRotMag/f_histAvgFxAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FxAppPos=1; else FxAppPos=0;    end;  
                    ratio=AvgFzRotMag/f_histAvgFzAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppPos=1; else FzAppPos=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzRotMag/f_histAvgFxAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FxAppMin=1; else FxAppMin=0;    end;  
                    ratio=AvgFzRotMag/f_histAvgFzAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppMin=1; else FzAppMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    bool_fcDataXDir(2,2:totParamSet+1) = [MyRot,FzRot,MzRotPos,MzRotMin,FxAppPos,FzAppPos,FxAppMin,FzAppMin];                 
                end

            %% Y-Direction Analysis
            elseif(analysis==yDir && yDirTest)
                %% Analyze Deviation in POS AND MIN Y-Direction. If mean is positive, only keep in MzRotPos. If minus, keep in MzRotMin.          
                % 1) Load SUCCESSFUL historically averaged Mz.Rot.Pos.AvgMag data
                matName='s_histMzRotPosAvgMag.mat'; [s_histAvgMzRotPosAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);

%                 % 2) Load SUCCESSFUL historically averaged Mz.Rot.Min.AvgMag data
%                 matName='s_histMzRotMinAvgMag.mat'; [s_histAvgMzRotMinAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);                
                
                %% Test 1st condition: Mz.Rot.Pos
                dataStruc = MCs;                dataType = amplitudeType;
                dataThreshold  = [1.30,0.70];   percStateToAnalyze = 1.0;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied            
                [bool_analysisOutcome3,AvgMzRotPosMag]= analyzeAvgData(motCompsFM,mcNumElems,dataType,stateData,Mz,rotState,s_histAvgMzRotPosAvgMag,dataStruc,percStateToAnalyze,dataThreshold);
                
%                 %% Test 2nd condition: Mz.Rot.Min
%                 dataStruc = MCs;        dataType = amplitudeType;
%                 dataThreshold  = 0.30;  percStateToAnalyze = 1.0;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied            
%                 [bool_analysisOutcome4,AvgMzRotMinMag]= analyzeAvgData(motCompsFM,mcNumElems,dataType,stateData,Mz,rotState,s_histAvgMzRotMinAvgMag,dataStruc,percStateToAnalyze,dataThreshold);                

                %% Compute Output BASED ON VALENCY
                
                % If the mean is positive, automatically set the boolOutcome of the min task to 0(non failure), and it's mean value equal to the historical value)
%                 if(AvgMzRotPosMag>0)                                                                                    % Don't need to check f_histAvgMzRotMinAvgMag b/c it will produce the same mean value
                    bool_fcDataYDir(1,1)    = bool_analysisOutcome3;
                    avgData(2,:)            = [AvgMzRotPosMag,0];%s_histAvgMzRotMinAvgMag(2,1)];                        % Second Row: since the min value is not tested, just place its historical value in col 2
%                     bool_analysisOutcome4   = 0;
%                 else
%                     bool_fcDataYDir(2,1)    = bool_analysisOutcome4;
%                     avgData(2,:)            = [0,AvgMzRotMinMag];  %[s_histAvgMzRotPosAvgMag(2,1),AvgMzRotMinMag];      % Second Row: since th epos value is not teste, just place its historical value in col 1    
%                     bool_analysisOutcome3 = 0;
%                 end
                % Here: Consider returning other data for recovery... Assgin steps for recovery 

                %% Analyze which Failure this is. If 0, that is the correlation and indication of our test. If 1 ignore.            
                if(bool_analysisOutcome3)
                    dataThreshold  = [3.50,0.30];                   
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMzRotPosMag/f_histAvgMyRotAvgMag(2,1);     if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MyRot=1;    else MyRot=0;       end; %[MyRot,~]= analyzeAvgData(motCompsFM,dataType,stateData,My,rotState,     f_histAvgMyRotAvgMag,dataStruc,percStateToAnalyze,dataThreshold); 
                    ratio=AvgMzRotPosMag/f_histAvgFzRotAvgMag(2,1);     if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzRot=1;    else FzRot=0;       end;
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMzRotPosMag/f_histAvgMzRotPosAvgMag(2,1);  if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzRotPos=1; else MzRotPos=0;    end; 
                    ratio=AvgMzRotPosMag/f_histAvgMzRotMinAvgMag(2,1);  if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzRotMin=1; else MzRotMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMzRotPosMag/f_histAvgFxAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FxAppPos=1; else FxAppPos=0;    end;  
                    ratio=AvgMzRotPosMag/f_histAvgFzAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppPos=1; else FzAppPos=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMzRotPosMag/f_histAvgFxAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FxAppMin=1; else FxAppMin=0;    end;  
                    ratio=AvgMzRotPosMag/f_histAvgFzAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppMin=1; else FzAppMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------               
                    bool_fcDataYDir(1,2:totParamSet+1) = [MyRot,FzRot,MzRotPos,MzRotMin,FxAppPos,FzAppPos,FxAppMin,FzAppMin];
                    bool_fcDataYDir(2,2:7) = 1;                   
                end  
%                 if(bool_analysisOutcome4)
%                     dataThreshold  = [0.10,0.10];
%                     %---------------------------------------------------------------------------------------------------------------------------------------------------
%                     ratio=AvgMzRotMinMag/f_histAvgMyRotAvgMag(2,1);     if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MyRot=1;    else MyRot=0;       end; %[MyRot,~]= analyzeAvgData(motCompsFM,dataType,stateData,My,rotState,     f_histAvgMyRotAvgMag,dataStruc,percStateToAnalyze,dataThreshold); 
%                     ratio=AvgMzRotMinMag/f_histAvgFzRotAvgMag(2,1);     if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzRot=1;    else FzRot=0;       end;
%                     %---------------------------------------------------------------------------------------------------------------------------------------------------
%                     ratio=AvgMzRotMinMag/f_histAvgMzRotPosAvgMag(2,1);  if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzRotPos=1; else MzRotPos=0;    end;  
%                     ratio=AvgMzRotMinMag/f_histAvgMzRotMinAvgMag(2,1);  if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzRotMin=1; else MzRotMin=0;    end;
%                     %-----------------------------------------------------------------------------------------------------------------------------------------------
%                     ratio=AvgMzRotMinMag/f_histAvgFxAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FxAppPos=1; else FxAppPos=0;    end;  
%                     ratio=AvgMzRotMinMag/f_histAvgFzAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppPos=1; else FzAppPos=0;    end;
%                     %-----------------------------------------------------------------------------------------------------------------------------------------------
%                     ratio=AvgMzRotMinMag/f_histAvgFxAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FxAppMin=1; else FxAppMin=0;    end;  
%                     ratio=AvgMzRotMinMag/f_histAvgFzAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppMin=1; else FzAppMin=0;    end;
%                     %-----------------------------------------------------------------------------------------------------------------------------------------------                  
%                     bool_fcDataYDir(1,2:7) = 1;
%                     bool_fcDataYDir(2,2:totParamSet+1) = [MyRot,FzRot,MzRotPos,MzRotMin,FxAppPos,FzAppPos,FxAppMin,FzAppMin];   
%                 end            

            %% XRollPos-Direction Analysis
            elseif(analysis==xRot && xRollDirTest)

                % ---------------------------- Analyze Deviation in xRollPos-Direction -------------------------------------          
                % 1) Load SUCCESSFUL historically averaged Fx.App.Pos.AvgMag data
                matName='s_histFxAppPosAvgMag.mat'; [s_histAvgFxAppPosAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);

                % 2) Load SUCCESSFUL averaged Fz.App.Pos.AvgMag data
                matName='s_histFzAppPosAvgMag.mat'; [s_histAvgFzAppPosAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);      
                
                % 3) Load SUCCESSFUL historically averaged Fx.App.Min.AvgMag data
                matName='s_histFxAppMinAvgMag.mat'; [s_histAvgFxAppMinAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);

                % 4) Load SUCCESSFUL historically averaged Fz.App.MinAvgMag data
                matName='s_histFzAppMinAvgMag.mat'; [s_histAvgFzAppMinAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);                 

                %% --------------------------------------------------------------------------------- Test Conditions -------------------------------------------------------------
                %% POS ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                % 1) condition: Fx.AppPos
                dataStruc = MCs;                dataType = magnitudeType;
                dataThreshold  = [1.20,0.80];   percStateToAnalyze = 1.0;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied            
                [bool_analysisOutcome5,AvgFxAppPosMag]= analyzeAvgData(motCompsFM,mcNumElems,dataType,stateData,Fx,approachState,s_histAvgFxAppPosAvgMag,dataStruc,percStateToAnalyze,dataThreshold);

                % 2) condition: Fz.AppPos
                dataStruc=MCs;                  dataType = magnitudeType;
                dataThreshold  = [1.20,0.80];   percStateToAnalyze = 1.0;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied            
                [bool_analysisOutcome6,AvgFzAppPosMag]= analyzeAvgData(motCompsFM,mcNumElems,dataType,stateData,Fz,approachState,s_histAvgFzAppPosAvgMag,dataStruc,percStateToAnalyze,dataThreshold);
                               
                %% Compute Output BASED ON VALENCY of FxAppPos
                
                % If the mean is positive, automatically set the boolOutcome of the min task to 0(non failure), and it's mean value equal to the historical value)
                if(AvgFxAppPosMag>0)                                                                                    % Group FxAppPos and FzAppPos
                    bool_fcDataXRollDir(1,1)    = bool_analysisOutcome5;
                    bool_fcDataXRollDir(2,1)    = bool_analysisOutcome6;
                    avgData(3,:)                = [AvgFxAppPosMag,AvgFzAppPosMag];
                    
                    bool_analysisOutcome7       = 0;
                    bool_analysisOutcome8       = 0;
                    avgData(4,:)                = [0,0]; %[AvgFxAppMinMag,AvgFzAppMinMag];
                else                                                                                                    % Group FxAppMin and FzAppMin
                    
                %% Min ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    % 3) condition: Fx.AppMin
                    dataStruc = MCs;                dataType  = magnitudeType;
                    dataThreshold  = [1.20,0.80];   percStateToAnalyze = 1.0;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied            
                    [bool_analysisOutcome7,AvgFxAppMinMag]= analyzeAvgData(motCompsFM,mcNumElems,dataType,stateData,Fx,approachState,s_histAvgFxAppMinAvgMag,dataStruc,percStateToAnalyze,dataThreshold);

                    % 4) condition: Fz.AppMin
                    dataStruc=MCs;                  dataType = magnitudeType;
                    dataThreshold  = [1.20,0.80];   percStateToAnalyze = 1.0;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied            
                    [bool_analysisOutcome8,AvgFzAppMinMag]= analyzeAvgData(motCompsFM,mcNumElems,dataType,stateData,Fz,approachState,s_histAvgFzAppMinAvgMag,dataStruc,percStateToAnalyze,dataThreshold);

                
                    bool_fcDataXRollDir(3,1)    = bool_analysisOutcome7;
                    bool_fcDataXRollDir(4,1)    = bool_analysisOutcome8;
                    avgData(4,:)                = [AvgFxAppMinMag,AvgFzAppMinMag];
                    
                    bool_analysisOutcome5       = 0;
                    bool_analysisOutcome6       = 0;
                    avgData(3,:)                = [0,0]; %[AvgFxAppMinMag,AvgFzAppMinMag];
                    
                end
                % Here: Consider returning other data for recovery... Assgin steps for recovery

                %% Analyze which Failure this is. If 0, that is the correlation and indication of our test. If 1 ignore.            
                % Analyze FxAppPos
                if(bool_analysisOutcome5)
                    dataThreshold  = [1.9,0.00];                    
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFxAppPosMag/f_histAvgMyRotAvgMag(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MyRot=1;    else MyRot=0;       end; 
                    ratio=AvgFxAppPosMag/f_histAvgFzRotAvgMag(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzRot=1;    else FzRot=0;       end;  
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFxAppPosMag/f_histAvgMzRotPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzRotPos=1; else MzRotPos=0;    end;  
                    ratio=AvgFxAppPosMag/f_histAvgMzRotMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzRotMin=1; else MzRotMin=0;    end;    
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFxAppPosMag/f_histAvgFxAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FxAppPos=1; else FxAppPos=0;    end;  
                    ratio=AvgFxAppPosMag/f_histAvgFzAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppPos=1; else FzAppPos=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFxAppPosMag/f_histAvgFxAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FxAppMin=1; else FxAppMin=0;    end;  
                    ratio=AvgFxAppPosMag/f_histAvgFzAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppMin=1; else FzAppMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------  
                    bool_fcDataXRollDir(1,2:totParamSet+1) = [MyRot,FzRot,MzRotPos,MzRotMin,FxAppPos,FzAppPos,FxAppMin,FzAppMin];     
                end 
                % Analyze FzAppPos
                if(bool_analysisOutcome6)
                    dataThreshold  = [2.45,-0.80];                   
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppPosMag/f_histAvgMyRotAvgMag(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MyRot=1;    else MyRot=0;       end; 
                    ratio=AvgFzAppPosMag/f_histAvgFzRotAvgMag(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzRot=1;    else FzRot=0;       end;    
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppPosMag/f_histAvgMzRotPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzRotPos=1; else MzRotPos=0;    end;  
                    ratio=AvgFzAppPosMag/f_histAvgMzRotMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzRotMin=1; else MzRotMin=0;    end;    
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppPosMag/f_histAvgFxAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FxAppPos=1; else FxAppPos=0;    end;  
                    ratio=AvgFzAppPosMag/f_histAvgFzAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppPos=1; else FzAppPos=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppPosMag/f_histAvgFxAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FxAppMin=1; else FxAppMin=0;    end;  
                    ratio=AvgFzAppPosMag/f_histAvgFzAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppMin=1; else FzAppMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------  
                    bool_fcDataXRollDir(2,2:totParamSet+1) = [MyRot,FzRot,MzRotPos,MzRotMin,FxAppPos,FzAppPos,FxAppMin,FzAppMin];
                end                    
                % Analyze FxAppMin
                if(bool_analysisOutcome7)
                    dataThreshold  = [2.75,0.45];                   
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFxAppMinMag/f_histAvgMyRotAvgMag(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MyRot=1;    else MyRot=0;       end; 
                    ratio=AvgFxAppMinMag/f_histAvgFzRotAvgMag(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzRot=1;    else FzRot=0;       end;  
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFxAppMinMag/f_histAvgMzRotPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzRotPos=1; else MzRotPos=0;    end;  
                    ratio=AvgFxAppMinMag/f_histAvgMzRotMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzRotMin=1; else MzRotMin=0;    end;    
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFxAppMinMag/f_histAvgFxAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FxAppPos=1; else FxAppPos=0;    end;  
                    ratio=AvgFxAppMinMag/f_histAvgFzAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppPos=1; else FzAppPos=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFxAppMinMag/f_histAvgFxAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FxAppMin=1; else FxAppMin=0;    end;  
                    ratio=AvgFxAppMinMag/f_histAvgFzAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppMin=1; else FzAppMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------  
                    bool_fcDataXRollDir(3,2:totParamSet+1) = [MyRot,FzRot,MzRotPos,MzRotMin,FxAppPos,FzAppPos,FxAppMin,FzAppMin];     
                end 
                % Analyze FzAppMin
                if(bool_analysisOutcome8)
                    dataThreshold  = [2.01,0.50];                    
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppMinMag/f_histAvgMyRotAvgMag(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MyRot=1;    else MyRot=0;       end; 
                    ratio=AvgFzAppMinMag/f_histAvgFzRotAvgMag(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzRot=1;    else FzRot=0;       end;    
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppMinMag/f_histAvgMzRotPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzRotPos=1; else MzRotPos=0;    end;  
                    ratio=AvgFzAppMinMag/f_histAvgMzRotMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzRotMin=1; else MzRotMin=0;    end;    
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppMinMag/f_histAvgFxAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FxAppPos=1; else FxAppPos=0;    end;  
                    ratio=AvgFzAppMinMag/f_histAvgFzAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppPos=1; else FzAppPos=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppMinMag/f_histAvgFxAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FxAppMin=1; else FxAppMin=0;    end;  
                    ratio=AvgFzAppMinMag/f_histAvgFzAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppMin=1; else FzAppMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------  
                    bool_fcDataXRollDir(4,2:totParamSet+1) = [MyRot,FzRot,MzRotPos,MzRotMin,FxAppPos,FzAppPos,FxAppMin,FzAppMin];
                end            
            end     % End for xDir Analysis                                                 
        end         % End for loop
    end             % End State Analysis
    
    bool_fcData=[bool_fcDataXDir;bool_fcDataYDir;bool_fcDataXRollDir];
end             % End Function