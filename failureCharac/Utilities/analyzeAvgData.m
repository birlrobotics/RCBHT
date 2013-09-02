% Documentation
% Average the current whichAxis.Rot.RMS values existing in the motionCompositions not the llbehStruc..
%
% Inputs
% data                  - can be motion compositions (motCompsFM) or low-level behaviors (llbehFM)
% dataType              - what type of data do we want to average? Magnitude, RMS, or Amplitude
% stateData             - col vec of automata state transitions
% whichAxis             - what axis do we want to work with: Fx-Mz
% whichState            - Approach/Rotation/Insertion/Mating (have not added PA10 PivotApproach functionality)
% histAvgData           - An appropriate and historically averaged data struc loaded from file
% dataFlag              - Indicates if using motionCompositions or LLBs.
% percStateToAnalyze    - how much of the state do you want to look at
% dataThreshold         - threshold to determine if averaged data is too far out from success levels
%
%
% Outputs
% analysisOutcome       - Did the current average surpass the threshold level? If threshold surpassed, then set outcome to 1, which indicates the task has failed.
% AvgDataSum            - This is the averaged data of sums of dataType. Used to update history later.
%
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
function [analysisOutcome,meanSum]= analyzeAvgData(data,dataType,stateData,whichAxis,whichState,histAvgData,dataFlag,percStateToAnalyze,dataThreshold)


    %% Local Variables
        
    % States
    startState=whichState; 
    endState=startState+1;
    
    % Data Type
    MCs=2;  % Flag to indicate we are using motion compositions
    LLBs=3; % Flag to indicate we are using low-level behaviors    
    
    % Data Types
    magnitudeType   = 1;
    rmsType         = 2;
    AmplitudeType   = 3;
    
    % Indeces
    mcMagIndex=2;   mcRMSIndex=3;   mcAmpIndex=4;
    llbMagIndex=4;  llbRMSIndex=7;  llbAmpIndex=10;
    
    if(dataFlag==MCs)
        
        % Set the data index (appropriate to Motion Compositions) to the correct value according to the data we want to average
        if(dataType==magnitudeType);        dataIndex=mcMagIndex; 
        elseif(dataType==rmsType);          dataIndex=mcRMSIndex; 
        elseif(dataType==AmplitudeType);    dataIndex=mcAmpIndex; 
        end
                                    
    elseif(dataFlag==LLBs)
        
        % Set the data index (appropriate to Motion Compositions) to the correct value according to the data we want to average
        if(dataType==magnitudeType);        dataIndex=llbMagIndex; 
        elseif(dataType==rmsType);          dataIndex=llbRMSIndex; 
        elseif(dataType==AmplitudeType);    dataIndex=llbAmpIndex; 
        end        
    end
    
    % Find starting index and ending index: In this case we only want to examine the first 1/2 of the Rot State. Modify the stateData here to represent that
    diff = ( (stateData(endState,1)-stateData(startState,1))*percStateToAnalyze);
    endStateShort = stateData(startState,1) + diff;
    stateData(endState,1) = endStateShort;
    [startStateIndex,endStateIndex]=getStateIndeces(data,stateData,whichAxis,whichState,dataFlag);

    %% Sum the LLBs avg Magnitude value
    startStateIndex=startStateIndex+1; % Avoid transition points
    if(percStateToAnalyze==1.0)
        endStateIndex=endStateIndex-1;
    end
    meanSum=mean(data(startStateIndex:endStateIndex,dataIndex,whichAxis)); % Compute the average LLbs in Fz.Rot

    %% Compute ration of absolute values of meanData and historicalMeanData to see if average is > or < threshold: indicates failure
    ratio=abs(meanSum)/abs(histAvgData(2,1));
    
    % Check if the history is 0 and it's the first time, in which case set Outcome to 0, if not do the corresponding comparison: 
    if(histAvgData(1,1)>0)        
        if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) )
            analysisOutcome = 1;    % If true, then failure.
            % Time at which failure happens?
            % Magnitudes?
        else
            analysisOutcome=0;
        end       
    else
        analysisOutcome=0;
    end
end