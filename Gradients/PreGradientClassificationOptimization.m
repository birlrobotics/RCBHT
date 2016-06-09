%% PreGradientClassificationOptimization
%
% This function seeks to recognize gradient classification values
% associated with CONTACT events and CONSTANT gradient classifications
% according to the Relative-Change-Based-Hierarchical-Taxonomy (RCBHT).
% 
% The classification of CONTACTS and CONSTANTS will be separated for Force
% values and Moment values (as obtained by the 6 DoF FT sensor).
%
% A CONSTANT value will be computed for each of the 6 DoF of the FT data.
% This value, however, will be extracted by looking at the "maximum value
% gradient" that occurs during the ROTATION state of the task. 
%
% As for the CONTACT value, we will look at the max gradient values in the
% Snap state of the task. The max value associated with Fz will be used to
% classify both Fz and Fy. The value of Fx will be used for itself. And the
% value of My will be used for Mx and Mz as well. 
% This last arbitration was selected based on the fact that Fx, Fz, and My
% are the key axes to study for contacts. The other axes do not experience
% contacts during successful assemblies so their data is of no use for this
% selection.
%
% Care needs to be taken to understand if the max gradients are positive or
% negative. Then, as per the original gradient classification of the RCBHT
% we need to compute the 4 positive and 4 negative gradient
% classifications: [pimp, bpos, mpos, spos, const, sneg, mneg, bneg, nimp]. 
%
% Since we have computed the impulse and the constant the rest of the space
% is divided by three. 
%
% The stateData vector is used to divide the time series 
% Inputs:
% stateData     - vector of state times
% statData      - nx6 statistical data where the [dAvg dMax dMin dStart dFinish dGradient dLabel]
% forceAxes     - what force axes is being used for computation
%--------------------------------------------------------------------------
function PreGradientClassificationOptimization(stateVec,statData,index)      
    
%% Initialization

    % Variables
    GradientNum	= 10;                               % Number of gradient classifications  
    
    % Statistical Data
    startTime   = 4;                                % start time for statistical vector
    endTime     = 5;                                % end time for statistical vector
    dGradient   = 6;                                % gradient value for statistical vector
    
    % State Vector
    rotStart    = 2;
    rotEnd      = 3;
    snapStart   = 3;
    snapEnd     = 4;
    
    % Size
    rStatistical = size(statData);   % Size of statistical data vector
    
    % Gradients
    
	maxContact = 0;
    maxConst   = 0;
    
    % Store the 9 values (and for each force axis) of gradient classification values
    gradClassification = zeros(GradientNum,1);       % Store [pimp, bpos, mpos, spos, const, sneg, mneg, bneg, nimp]
    
%%  Work with FIXED Behaviors -- Rotation Automata State

    % FORCE AXES -- 3 -- {Fx,Fy,Fz}
    % Moment AXES -- 3 -- {Mx,My,Mz}
    
    % Look at all the primitives within the rotation state
    for i = 1:rStatistical(1)
        if( statData(i,startTime)>stateVec(rotStart,1) && statData(i,endTime)<stateVec(rotEnd,1))
            if ( abs(statData(i,dGradient)) > maxConst ) % Look for the absolute value
                maxConst = statData(i,dGradient);
            end
        end        
    end   
    
    % Assign the maximum value Pimp and Nimp
    pConst = maxConst;
    nConst = -maxConst;
    
%% Work with CONTACT Behaviors   

    % FORCE AXES -- 2 -- {(Fx),(Fz->Fy)}
    % Moment AXES -- 1 -- {My}
    
    % Look at all the primitives within the snap state
    for i = 1:rStatistical(1)
        if( statData(i,startTime)>stateVec(snapStart,1) && statData(i,endTime)<stateVec(snapEnd,1))
            if ( abs(statData(i,dGradient)) > maxContact ) % Look for the absolute value
                maxContact = statData(i,dGradient);
            end
        end        
    end   
    
    % Assign the maximum value Pimp and Nimp
    pimp = maxContact;
    nimp = -maxContact;    
    
%% Compute the rest of the set of gradient values 

    pSpectrum = (pimp - pConst)/3.0;
    nSpectrum = (nimp - nConst)/3.0;
    
    % Positive Gradients
    bpos = pimp - 1.0*pSpectrum;
    mpos = pimp - 2.0*pSpectrum;
    spos = pimp - 3.0*pSpectrum;
    
    % Negative Gracients
    bneg = nimp + 1.0*nSpectrum;
    mneg = nimp + 2.0*nSpectrum;
    sneg = nimp + 3.0*nSpectrum;   
    
    % Save gradient values for a single force axes
    gradClassification(:,1,index) = [pimp bpos mpos spos pConst nConst sneg mneg bneg nimp]; 
%% Write them to file
    WriteGradientClassification(gradClassification,index);
end