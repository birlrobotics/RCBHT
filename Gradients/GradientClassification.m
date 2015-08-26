%%*************************** Documentation *******************************
% GradientClassification()
%
% The gradient classification converts a gradient value into a gradient
% label. 
%
% Input:
% gradient      - value of the gradient for a segment computed by linear
%                 regression. 
% domain:       - the difference between the maximum y-value of the force
%                 data and the minimum y-value of the force data. 
% StrategyType  - tells whether using PA10-PivotApproach or HIRO-SideApproach
% forceAxisIndex- what force axis are we on.
%
% Assign one of six kinds of labels to a gradient, based on it's magnitude.
% If an optimization routines was used, these values are saved to file and
% need to be extracted from file. Otherwise use the followin standard
% values:
%
% imp      +/-: gradient whose abs value is         m >= 1000; large gradient (impulse)
% Big      +/-: gradient whose abs value is: 100 =< m < 1000; big gradient
% Moderate +/-: gradient whose abs value is:  10 =< m <  100; med gradient
% Small    +/-: gradient whose abs value is:   1 =< m <   10; small gradient
% Constant    : gradient whose abs value is: 0.0 =< m <    1; constant
%
% Positive labels are: 'pimp','bpos','mpos','spos','pConst'.
% Negative labels are: 'nimp','bneg','mneg','sneg','nConst'.
%
% The domain
%**************************************************************************
function gradLabel = GradientClassification(gradient,domain,...
                                            fPath,FolderName,StrategyType,forceAxisIndex)

%% Intialization
    global Optimization;                            % Copy the global value defined in snapVerification.m
    gradientClassificationFlag = false;             % Initialize the flag to false indicating that gradients have not been optimized
%% Set Path                                        
    StratTypeFolder = AssignDir(StrategyType);
    
%% Open File according to index
    
    % Convert index to string to reference the appropriate force axes
    if(forceAxisIndex==1);       name='/Fx.dat';
    elseif(forceAxisIndex==2);   name='/Fy.dat';
    elseif(forceAxisIndex==3);   name='/Fz.dat';
    elseif(forceAxisIndex==4);   name='/Mx.dat';
    elseif(forceAxisIndex==5);   name='/My.dat';
    elseif(forceAxisIndex==6);   name='/Mz.dat';
    end    

%% Create Directory   
    gradClassFolder = 'gradClassFolder';
    dir             = strcat(fPath,StratTypeFolder,gradClassFolder);        

    % Check if directory exists where optimized gradients were saved. ==2, means that it exists.
    if(exist(strcat(dir,name),'file')==2)

        % The folder exists thus optimization has taken place. Set
        % gradientClassificationFlag to true to USE those values. 
        if(Optimization==0)
            gradientClassificationFlag = true; 
            gradClassification = load(strcat(dir,name));    % I.e. gradients have been optimized

        % Optimization == 1
        % There is a desire to RECOMPUTE the values one more time. Keep
        % the gradientClassificationFlag to true. 
        else
            gradientClassificationFlag = true;

        end

    % No optimized gradients exist because the folder doesn't exist.        
    else
        % The folder does not exist but we want to calibrate for the
        % first time. This will happen in snapVerification's call to
        % gradientCalibration ~ L290
        if(Optimization==1)
            gradientClassificationFlag  = false; %WriteGradientClassification will trigger the computation of calibrated gradients

        % No calibrated gradients and don't want to compute them.
        else
            gradientClassificationFlag = false;
        end

    end 

%% Gradient limits - values based on strategy, domain, or optimization

    zero = 0.0;

    % If Calibration is ON
    if(gradientClassificationFlag==true)
        
        %% Assign values
        % Positive Gradients
        pimp = gradClassification(1,1);     % Ie. The first entry in the file corresponds to pimp
        spos = gradClassification(4,1);
        
        % Rest of values are to be filled depending on domain
        % 1) Scale values by 0.5 if domain is less than 0.1 in total value.
        
        % Equivalent values occur if we use the computed value for My pimp.
        if(domain < 1.9)
            factor = 10.0;

            pimp  = pimp/factor;     
            grads = computeGradientSpectrum(pimp, spos);        % Returns the structure [pimp bpos mpos spos sneg mneg bneg nimp];
            
                                    nimp = grads(1,8); 
            bpos  = grads(1,2);     bneg = grads(1,7);
            mpos  = grads(1,3);     mneg = grads(1,6);
            spos  = grads(1,4);     sneg = grads(1,5);   
            
        elseif(domain < 0.1)
            factor = 100.0;
           
            pimp  = pimp/factor;     
            grads = computeGradientSpectrum(pimp, spos);        % Returns the structure [pimp bpos mpos spos sneg mneg bneg nimp];
            
                                    nimp = grads(1,8); 
            bpos  = grads(1,2);     bneg = grads(1,7);
            mpos  = grads(1,3);     mneg = grads(1,6);
            spos  = grads(1,4);     sneg = grads(1,5);  
        
        % No domain changes, load directly from file
        else
            
            bpos = gradClassification(2,1);     % Second entry corresponds to bpos...
            mpos = gradClassification(3,1);
            spos = gradClassification(4,1);

            % Negative Gradients
            sneg = gradClassification(5,1);
            mneg = gradClassification(6,1);
            bneg = gradClassification(7,1);
            nimp = gradClassification(8,1);            
            
        end 
        
    % No optimization. Use standard values. Still look at strategy & domain.
    elseif(gradientClassificationFlag==false)
        
        %% Read value from file to know if we should load standard values
        %% or optimized values
        
        if(~strcmp(StrategyType,'SIM_SideApproach') && ~strcmp(StrategyType(1:12),'SIM_SA_Error') && ~strcmp(StrategyType,'SIM_SA_DualArm'))
            pimp  =1000.0;     nimp = -1*pimp; % These are a later addition but are indexed as positions 7 and 8
            bpos  = 100.0;     bneg = -1*bpos;
            mpos  =  10.0;     mneg = -1*mpos;
            spos  =   1.0;     sneg = -1*spos;
            zero  =   0.0;

        % HIRO    
        else
            pimp  =  70.0;     nimp = -1*pimp; % These are a later addition but are indexed as positions 7 and 8
            bpos  =  46.0;     bneg = -1*bpos;
            mpos  =  23.0;     mneg = -1*mpos;
            spos  =   1.0;     sneg = -1*spos;
            zero  =   0.0;
        end    
    
%% OPTIMIZATION ACCORDING TO THE FORCE/MOMENT-AXIS DOMAIN --Primarily used in moment signals.
        % 1) Scale values by 0.5 if domain is less than 0.1 in total value.
        if(forceAxisIndex>3) % moments
            if(strcmp(StrategyType,'SIM_SideApproach') || strcmp(StrategyType,'SIM_SA_DualArm') && domain < 1.9) 
                factor = 10.0;

                pimp  = pimp/factor;     nimp = -1*pimp; % These are a later addition but are indexed as positions 7 and 8
                bpos  = bpos/factor;     bneg = -1*bpos;
                mpos  = mpos/factor;     mneg = -1*mpos;
                spos  = spos/factor;     sneg = -1*spos;   

            elseif(strcmp(StrategyType,'SIM_SideApproach') || strcmp(StrategyType,'SIM_SA_DualArm') && domain < 0.1) 
                factor = 100.0;

                pimp  = pimp/factor;     nimp = -1*pimp; % These are a later addition but are indexed as positions 7 and 8
                bpos  = bpos/factor;     bneg = -1*bpos;
                mpos  = mpos/factor;     mneg = -1*mpos;
                spos  = spos/factor;     sneg = -1*spos; 

            %% Error Characterization: Has larger values
            elseif(strcmp(StrategyType(1:12),'SIM_SA_Error') && domain < 4.0)
                factor = 10.0;

                pimp  = pimp/factor;     nimp = -1*pimp; % These are a later addition but are indexed as positions 7 and 8
                bpos  = bpos/factor;     bneg = -1*bpos;
                mpos  = mpos/factor;     mneg = -1*mpos;
                spos  = spos/factor;     sneg = -1*spos;   

            elseif(strcmp(StrategyType(1:12),'SIM_SA_Error') && domain < 1)
                factor = 100.0;

                pimp  = pimp/factor;     nimp = -1*pimp; % These are a later addition but are indexed as positions 7 and 8
                bpos  = bpos/factor;     bneg = -1*bpos;
                mpos  = mpos/factor;     mneg = -1*mpos;
                spos  = spos/factor;     sneg = -1*spos; 
            end
        end
    end    

%% Classify each gradient

        %% Check for positive values and assign labels
        if(gradient >= pimp)
            gradLabel = 'pimp';
        elseif(gradient >= bpos && gradient < pimp)
            gradLabel = 'bpos';
        elseif(gradient >= mpos && gradient < bpos)
            gradLabel = 'mpos';
        elseif(gradient >= spos && gradient < mpos)
            gradLabel = 'spos';  
        elseif(gradient >= zero && gradient < spos)
            gradLabel = 'cons';

        %% Check for negative values and assign labels
        elseif(gradient < nimp)
            gradLabel = 'nimp';
        elseif(gradient > nimp && gradient <= bneg ) % Be careful with the direction of the inequalities
            gradLabel = 'bneg';
        elseif(gradient > bneg && gradient <= mneg )
            gradLabel = 'mneg';
        elseif(gradient > mneg && gradient <= sneg )
            gradLabel = 'sneg';               
        elseif(gradient > sneg && gradient < zero  ) % do not include equal sign for zero inequality. that belongs in the positive const area
            gradLabel = 'cons';
        end
end