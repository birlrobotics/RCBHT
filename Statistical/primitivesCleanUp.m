%% ************************** Documentation *******************************
% The primitive clean-up phase filters primitives based on: (1) repeated primitives,
% and, (2) time duration.
%
% (1) Repeated Primitives: merge as many primitives in a row as necessary
% if the label is repeated. Then deleted the elements who were merged
% up-front in the array.
%
% (2) Time Duration & Amplitude Context: for two contiguous primitives, if one 
%  primitive is 5x longer and 2x larger than the other then we absorb it 
% (except for pimp/nimp impulses).
%
% The reason for this, is that if there is a "big" jump in amplitude even if
% it is of short duration it is important. We have learned that not only
% contacts but also also signals of smaller gradients can be significant.
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
% stateData:        - time at which states start. First entry (out of four)
%                     indicates the time at which the second state starts.
%                     Assumes the 5 states of the Pivot Approach.
% gradLabels        - column string vector containing all of the primitive labels
%**************************************************************************
function statData = primitivesCleanUp(statData,gradLabels)

%% Initialization

    % Get dimensions of motComps
    %r = size(statData);     
    
%%  GRADIENT PRIMITIVES

%   % CONSTANTS FOR gradLabels (defined in fitRegressionCurves.m)
%   BPOS            = 1;        % big   pos gradient
%   MPOS            = 2;        % med   pos gradient
%   SPOS            = 3;        % small pos gradient
%   BNEG            = 4;        % big   neg gradient
%   MNEG            = 5;        % med   neg gradient
%   SNEG            = 6;        % small neg gradient
%   CONST           = 7;        % constant  gradient
    PIMP            = 8;        % large pos gradient 
    NIMP            = 9;        % large neg gradient
    %NONE            = 10;       % none
    
%     gradLabels = { 'bpos',   ... % big   pos grads
%                    'mpos',   ... % med   pos grads
%                    'spos',   ... % small pos grads
%                    'bneg',   ... % big   neg grads
%                    'mneg',   ... % med   neg grads
%                    'sneg',   ... % small neg grads
%                    'const',  ... % constant  grads
%                    'pimp',   ... % large pos grads
%                    'nimp',   ... % large neg grads
%                    'none'};    

%   % primitives Structure Indeces
%   AVG_MAG_VAL      = 1;   % average value of primitive
%   MAX_VAL          = 2;   % maximum value of a primitive
%   MIN_VAL          = 3;   % minimum value of a primitive   

    % Time Indeces
    T1S = 4; T1E = 5;     
    
    % Amplitude Indeces
    mxAmp=2;  minAmp=3;
    GRAD_LBL    = 7;
%%  DURATION VARIABLES    
    % Threshold for merging two primitives according to lengthRatio
    lengthRatio     = 5;  % Empirically set
    amplitudeRatio = 2;
%%  Delete Empty Cells If Any. 
    [statData]= DeleteEmptyRows(statData);   
    r = size(statData);   
    
%% (1) Delete repeated primitives    
 % no repeatition flag
    noRepeat    = false;
    numRepeated = 0;
%%  Until no more repeats    
    while(~noRepeat)

        % Set noRepat flag here to true. If there is a reptition inside,
        % set it to false. Such that, when there are no more repetitions, it will exit
        noRepeat = true;
        i=1;
        % For all primitives compositions
        while i<=r(1)-1
            j = i+1;
            
%%          Compare labels (int type's) of contiguous primitives)
            while(j<=r(1) && intcmp(statData(i,7),statData(j,7)))
                j=j+1;
                numRepeated=numRepeated+1;
            end
        
            % If there are no repetitions here, move the index and then break
            if(numRepeated==0)
                i=i+1;
            else
                % Merge as many primitives as are repeated
                nextPrimitive=numRepeated;
                statData = MergePrimitives(i,statData,nextPrimitive); % The third argument is gradLabels but it is not used.
                i=i+1+numRepeated; % Since, j+1 was deleted, move to the next next element.

                % Change the noRepeat flag 
                noRepeat = false;  
                numRepeated=0;
            end
        end
    
%%      Delete Empty Cells
        [statData]= DeleteEmptyRows(statData);        
        % Update size variable of motCmops after resizing
        r = size(statData);    
    end
    
     
%%  (2) TIME DURATION CONTEXT - MERGE AND MODIFY Primitives
    for i=1:r(1)-1
        
        % If it is not a contact label compare the times.
        if(~intcmp(statData(i,GRAD_LBL),PIMP) && ...
                ~intcmp(statData(i,GRAD_LBL),NIMP))                
            
            % (1) Get Amplitude of Primitives
            amp1 = abs(statData(i,mxAmp)-statData(i,minAmp));       % Absolute value of amplitude difference of first primitive
            amp2 = abs(statData(i+1,mxAmp)-statData(i+1,minAmp));   % bsolute value of amplitude difference of second primitive
            
            % Compute ratio of 2nd primitive vs 1st primitive
            ampRatio = amp2/amp1;
            if(ampRatio==0 || ampRatio==inf); continue; end            
            if(ampRatio > amplitudeRatio || ampRatio < inv(amplitudeRatio)) 
                break;                                              % If this is true, don't do anything else.
            
            % The amplitude ratio is small, it's okay to filter by duration
            else                
                % (2) Get Duration of primitives inside compositions
                p1time = statData(i,T1E)-statData(i,T1S);       % Get duration of first primitive
                p2time = statData(i+1,T1E)-statData(i+1,T1S);   % Get duration of second primitive    
                
                ratio = p1time/p2time;
                if(ratio==0 || ratio==inf); continue; end

                % Merge according to the ratio            
                if(ratio > lengthRatio)
                    thisPrim = 0;            % First primitive is longer
                    statData = MergePrimitives(i,statData,thisPrim);
                elseif(ratio < inv(lengthRatio))
                    nextPrim = 1;            % Second primitive is longer
                    statData = MergePrimitives(i,statData,nextPrim);
                end  
            end
        end
     end       
%%  Delete Empty Cells
    [statData]= DeleteEmptyRows(statData);   
    %r = size(statData);        
    
end