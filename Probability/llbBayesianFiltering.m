%%*************************** Documentation *******************************
%% llbBayesianFiltering (offline)
% 
%  This function implements Bayesian Filtering on the
%  Change-Based-Hierarchical-Taxonomy (CBHT). Bayesian filtering is
%  requires three basic probabilities: the initial prior probabilities, the
%  system model probabilities, which model the likelihood of moving from a
%  state at time t-1 to a state at time t; and the measurement
%  probabilities, which model the likelihood of given a measurement, how
%  likely is it that it belong to a state at time t. 
%
% Currently, we used 7 experiments with the HIRO simulation to derive these
% parameters. The priors/measurements in effect have the same value as they
% are based on the cumulative duration of a given low-level behavior (as
% per the CBHT system) in a given automata state (of which there are three:
% ROTATION, SNAP, MATING). Note that the Approach state is removed.
%
% Additionaly, Bayesian filtering is implemented in two steps: the
% prediction step and the correction step. The former uses the system model
% and the prior probability to generate the belief (or posterior at a time
% t-1. The Correction step then corrects this belief by it's product with
% the measurement probability for that time step.
%
% Inputs:
% fPath                     - path for working directory
% StrategyType,FolderName   - used to print/save results in right location
%
% Outputs:
% postTime  - posterior for llbs. It's a (6xkx6) struc representing each of
%             the six llbs, for all time, for all axes.
% EndRot    - time index entry for end of rotation
% EndSnap   - time index entry for end of snap
% EndMat    - time index entry for end of mat
% time      - the time vector from RotState to End
% stateTimes- when states start and end
%**************************************************************************
function [postTime,EndRot,EndSnap,EndMat,time,modStateTimes] = llbBayesianFiltering(fPath, StrategyType,FolderName)

%% Initialize Data

    % Global Reference Parameters
    debug = 0;      % For debugging purposes
    NumAxes = 6;
    forceAxes     = ['Fx';'Fy';'Fz';'Mx';'My';'Mz'];
    %llbBehaviors  = ['FX' 'CT' 'PS' 'PL' 'SH' 'AL'];
    %hlbBehvaviors = ['Rot' 'Snap' 'Mating'];
    
    % LLB's Encoding: Generate variables that represent LLBs as int's:
    % FX = 11; CT = 22; PS = 33; PL = 44; SH = 55; AL = 66;
    NO_TAG = -1;

%% Load Data: 

    % 1) Set Path and Strategy Folder
    StratTypeFolder = AssignDir(StrategyType); %i.e. Hiro Side Approach = 'HSA'
    % 2) Assing appropriate directoy based on Ctrl Strategy to read data files
    if(ispc)
        Path = 'C:\\Documents and Settings\\suarezjl\\My Documents\\School\\Research\\AIST\\Results';
    else
       Path = '\\home\\juan\\Documents\\Results'; 
       % QNX
       % '\\home\\vmrguser\\Documents\\Results'; 
    end  

    % 3) Load Time data and States
    time = load(strcat(Path,StratTypeFolder,FolderName,'\\Torques.dat'));
    time = time(:,1); % Just keep the time column    
    
    % $4) Load State Vector:
    stateTimes = load(strcat(Path,StratTypeFolder,FolderName,'\\State.dat'));
    % 1) Set fPath and Strategy Folder
    StratTypeFolder = AssignDir(StrategyType); %i.e. Hiro Side Approach = 'HSA'
    
    % 3) Load Time data and States
    time = load(strcat(fPath,StratTypeFolder,FolderName,'\\Torques.dat'));
    time = time(:,1); % Just keep the time column    
    
    % $4) Load State Vector:
    stateTimes = load(strcat(fPath,StratTypeFolder,FolderName,'\\State.dat'));
    
    % 4b) Include finishing time
    r = size(stateTimes);
    if( r(1)<5 ) % Approach/Rotation/Snap/Mating
        stateTimes(end+1,1) = time(end); 
    end
    
    % 4c) Eliminate the first state - the Approach State
    stateTimes = stateTimes(2:end,1);
    
    % 5a) Eliminate time elements in the Approach State
    SimStep        = 0.005;                                 % The simulation's time step magnitude
    StartingIndex  = (stateTimes(1,1)/SimStep)+1;           % I.e. SimStep = 0.05. Time = {0,0.05}. Then time=0.05/SimStep = 1, but it's index 2.
    time           = time(StartingIndex+1:end);             % Start counting at the next time step
    
    % Indeces: i.e. when does the state start
    StartRot    = 1;
    EndRot      = uint16(stateTimes(2,1)/SimStep) - StartingIndex+1;
    StartSnap   = EndRot;
    EndSnap 	= uint16(stateTimes(3,1)/SimStep) - StartingIndex+1;
    StartMat    = EndSnap;
    EndMat      = uint16(time(end)/SimStep) - StartingIndex+1;
        
    % Length - i.e. how many elemnts of time
    FullDuration      = size(time);
    
    % 6) Create a posterior structure that holds force-axes posteriors along the rows, and their values over time along the columns for all axes.
    postTime = zeros(6,FullDuration(1),NumAxes); 
    
    % Create a LLBx1 vector to hold the random variable x of cumulative durations of an LLB at
    % time k for each axes
    x = zeros(6,1,NumAxes);
    
    % Measure measurement probability over time
    if(debug);zTime = zeros(6,EndRot,NumAxes);end;
    
%% Separate LLBs into states    
    %% Need to adjust the ending time. I learned that different llblayers
    %% have different ending times for different axes. My guess is that
    %% there is a mismatch in the pairing at the end. Need to adjust EndMat
    minTime=10000;
  
    for axes = 1:NumAxes    
       %% Load LLB by Axes (you will retrieve a CELL struc)
        LLB = load(strcat(fPath,StratTypeFolder,FolderName,'\\llBehaviors','\\llBehaviors_',forceAxes(axes,:),'.mat'));LLB = LLB.data; 
        r = size(LLB);        
        if(LLB{r(1),16}<minTime);minTime = LLB{r(1),16};end         
    end
    
    % Modified state time -- just used for plotting
    modStateTimes = stateTimes;
    modStateTimes(end,1) = minTime;
    
    [llbRot,llbSnap,llbMat] = DivideLLB2States(fPath,StratTypeFolder,FolderName,forceAxes,stateTimes);
%% Compute the a posterior Recursively
% We will need to study the llb that corresponds to a given time step

%% Load Probabilistic Data: Priors, System, Measurement Models
    % PRIOR:        3 6x6 matrices in a struct corresponding to prior's over LLBs for Rotation, Snap, Mating.
    % SYSTEM:       3 strucs each containing 6 matrices. Each matrix is a 6x6 matrix.
    % MEASUREMENT:  same as prior in our case.
    [PRIOR SYSTEM MEASUREMENT VARIANCE]= loadProbabilisticTrainingData;
    
    % Create a vector for the posterior
    posterior   = zeros(6,1);   
    
%% Bayesian filtering model for a recursive function: bel = normalizing coeff * Measurement Model * State Model * bel'; 
% Run the following algorithm for all three separate states, for each of
% the six force axes, and for each of the LLB's. 
    
%% Automata State -- Rotation 
    %N = 0; % Normalizing constant. Computed as the sum of each of the probabilities for the llb's.
    
    % Per time step starting with the beginning of the Rotation State. 
    for k = StartRot:EndRot; %1:SnapTimeIndex;%-1;
        
        % Per Axes
        for axes = 1:NumAxes
            
%% PREDICTION STEP: bel'(FX) = P(FX|FX)p(FX) + P(FX|CT)p(CT)+...+P(FX|SH)p(SH)
            % The former can be achieved by dotting (summing the corresponding row vectors)
                        
            % 1) Get current (measured) LLB first:
            currLLB = ReturnLLB(time(k),llbRot(:,:,axes));         

            % If in the Approach State, tag currLLB == 0. In that case, set postRot(:,k) = 0 and continue;
            if(currLLB==NO_TAG)
                postTime(:,k,axes) = 0;
                continue;
            else
                % Else, continue with prediction step
                posterior(:)=0;                                  % Ensure zero values to start.
                
                % Compute the posterior for each llb for a single force axis for a single time step, 
                % Where llb 1-6 represents: {FX,CT,PS,PL,SH,AL}
                for llb=1:6
                    posterior(llb,1) = dot( SYSTEM.Trans_Rot(llb,:,axes)', PRIOR.Prior_Rot(axes,:)' );
                    if(posterior(axes,1) > 1)
                        printf('\nPrediction Step Produces Probability > 1. Look at line 102.')
                    end
                end
            end
%% CORRECTION STEP: Update the belief

            % CORRECTION STEP
            % bel'(x) = p(z|x)bel and N = N + bel'
            % we need to compute the posterior for each of the 6 LLBs
            
            % Measurement Probability
            % Compute gaussian error between measured state and desired state.
            
            % 1) Extract the cumulative duration of the current llb:
            CumDur = ExtractCumDuration(currLLB,llbRot,time(k),axes);   
            
            % 2) Compute the multinomial statistical parameters
            x(currLLB,1,axes) = CumDur;             % Assign the duration of the current llb as the appropriate random variable, a single number. 
            u = MEASUREMENT.Meas_Rot(axes,:)';      % Extract the mean duration per state per axes for all llb = vector (6x1) of mean durations for all lbs. 
            v = VARIANCE.Var_Rot(axes,:)';          % Variance per state per axes for all llb = vector (6x1) of duration variances for all lbs. 
            s = sqrt(v);
            
            % 3) Compute the gaussian probability for the measurement model 
            %z=( 1./(sqrt(2*pi).*s) ) .*exp(-0.5*((x-u)./s).^2); 
            %z=normpdf (x, u, s)
            z = normcdf(x(:,1,axes),u,s); % Compute the probability as per the cumulative distribution
            z = CheckNaN(z);
            
            %% Check Cases
            for i=1:6 
                % If the CDF is at extrema 0 or 1, adjust to avoid prob. of
                % 0.
                if(z(i,1)==1.0) 
                    z(i,1) = 0.999;
                end
                if(z(i,1)==0.0)
                    z(i,1)=0.001;
                end

                % If the DURATION was equal to zero, NO CONTRIBUTION, need to set z to ZERO. Those values are not zero due to the variance
                % value that was computed. This is a temporal boundary.                
                if(x(i,1,axes)==0)
                    z(i,1) = 0;
                end                
                % In this case, we only treat one side of the curve. 0.5 will
                % be max prob. So if z>0.5, we set it equal to 1-z.                    
                if(z(i,1) > 0.5) 
                    z(i,1) = 1-z(i,1);
                end
            end

            % Accumulate values of z over time to plot later
            if(debug);zTime(:,k+1-StartRot,axes) = z;end;
            
            %   4) Compute the posterior according to the measurement model
            %   for each of the llb's in a given time step for a given axis.
            %   This is 6x1 vec, where each entry is the posterior of a
            %   given llb. 
            posterior(:,1) = z.*posterior(:,1);
            
            % 5) Update the normalizing constant for each llb in a state in an axis.
            N = sum(posterior(:,1));  
            
            % 6) Normalize the posterior
            posterior(:) = posterior(:)/N;
            
            % 7) Copy posterior into posterior time for the corresponding element
            %    It's a 6 x k x axes structure for a single automata state.
            postTime(:,k,axes) = posterior(:,1);            
        end % End Axes                                      
    end % End Time    
   


%% Automata State -- Snap 
    x(:) = 0; % Reset the random variable x
    
    if(debug);figure, plot(zTime(2,:,axes));end;
    % Per time step starting with the beginning of the Rotation State. 
    for k = StartSnap:EndSnap;%SnapTimeIndex:MatTimeIndex;%-1;
        
        % Per Axes
        for axes = 1:NumAxes
            
%% PREDICTION STEP: bel'(FX) = P(FX|FX)p(FX) + P(FX|CT)p(CT)+...+P(FX|SH)p(SH)
            % The former can be achieved by dotting (summing the corresponding row vectors)
                        
            % 1) Get current (measured) LLB first:
            currLLB = ReturnLLB(time(k),llbSnap(:,:,axes));

            % If in the Approach State, tag currLLB == 0. In that case, set postSnap(:,k) = 0 and continue;
            if(currLLB==NO_TAG)
                postTime(:,k,axes) = 0;
                continue;
            else
                % Else, continue with prediction step
                posterior(:)=0;                                  % Ensure zero values to start.
                
                % Compute the posterior for each llb for a single force axis for a single time step, 
                % Where llb 1-6 represents: {FX,CT,PS,PL,SH,AL}
                for llb=1:6
                    posterior(llb,1) = dot( SYSTEM.Trans_Snap(llb,:,axes)', PRIOR.Prior_Snap(axes,:)' );
                    if(posterior(axes,1) > 1)
                        printf('\nPrediction Step Produces Probability > 1. Look at line 102.')
                    end
                end
            end
%% CORRECTION STEP: Update the belief

            % CORRECTION STEP
            % bel'(x) = p(z|x)bel and N = N + bel'
            % we need to compute the posterior for each of the 6 LLBs
            
            % Measurement Probability
            % Compute gaussian error between measured state and desired state.
            
            % 1) Extract the cumulative duration of the current llb:
            CumDur = ExtractCumDuration(currLLB,llbSnap,time(k),axes);            
            
            % 2) Compute the multinomial statistical parameters
            x(currLLB,1,axes) = CumDur;                  % Assign the duration of the current llb as the appropriate random variable, a single number. 
            u = MEASUREMENT.Meas_Snap(axes,:)';      % Extract the mean duration per state per axes for all llb = vector (6x1) of mean durations for all lbs. 
            v = VARIANCE.Var_Snap(axes,:)';          % Variance per state per axes for all llb = vector (6x1) of duration variances for all lbs. 
            s = sqrt(v);
            
 % 3) Compute the gaussian probability for the measurement model 
            %z=( 1./(sqrt(2*pi).*s) ) .*exp(-0.5*((x-u)./s).^2); 
            %z=normpdf (x, u, s)
            z = normcdf(x(:,1,axes),u,s); % Compute the probability as per the cumulative distribution
            z = CheckNaN(z);
            
            %% Check Cases
            for i=1:6 
                % If the CDF is at extrema 0 or 1, adjust to avoid prob. of
                % 0.
                if(z(i,1)==1.0) 
                    z(i,1) = 0.999;
                end
                if(z(i,1)==0.0)
                    z(i,1)=0.001;
                end

                % If the DURATION was equal to zero, NO CONTRIBUTION, need to set z to ZERO. Those values are not zero due to the variance
                % value that was computed. This is a temporal boundary.                
                if(x(i,1,axes)==0)
                    z(i,1) = 0;
                end                
                % In this case, we only treat one side of the curve. 0.5 will
                % be max prob. So if z>0.5, we set it equal to 1-z.                    
                if(z(i,1) > 0.5) 
                    z(i,1) = 1-z(i,1);
                end
            end

            % Accumulate values of z over time to plot later
            if(debug);zTime(:,k+1-StartRot,axes) = z;end;
            
            %   4) Compute the posterior according to the measurement model
            %   for each of the llb's in a given time step for a given axis.
            %   This is 6x1 vec, where each entry is the posterior of a
            %   given llb. 
            posterior(:,1) = z.*posterior(:,1);
            
            % 5) Update the normalizing constant for each llb in a state in an axis.
            N = sum(posterior(:,1));  
            
            % 6) Normalize the posterior
            posterior(:) = posterior(:)/N;
            
            % 7) Copy posterior into posterior time for the corresponding element
            %    It's a 6 x k x axes structure for a single automata state.
            postTime(:,k,axes) = posterior(:,1);            
        end % End Axes                                      
    end % End Time  
    

   
%% Automata State -- Mating
    x(:) = 0; % Reset the random variable x
    
    % Per time step starting with the beginning of the Rotation State. 
    for k = StartMat:EndMat; %MatTimeIndex:FullDuration;
        
        % Per Axes
        for axes = 1:NumAxes
            
%% PREDICTION STEP: bel'(FX) = P(FX|FX)p(FX) + P(FX|CT)p(CT)+...+P(FX|SH)p(SH)
            % The former can be achieved by dotting (summing the corresponding row vectors)
                        
            % 1) Get current (measured) LLB first:
            currLLB = ReturnLLB(time(k),llbMat(:,:,axes));

            % If in the Approach State, tag currLLB == 0. In that case, set postMat(:,k) = 0 and continue;
            if(currLLB==NO_TAG)
                postTime(:,k,axes) = 0;
                continue;
            else
                % Else, continue with prediction step
                posterior(:)=0;                                  % Ensure zero values to start.
                
                % Compute the posterior for each llb for a single force axis for a single time step, 
                % Where llb 1-6 represents: {FX,CT,PS,PL,SH,AL}
                for llb=1:6
                    posterior(llb,1) = dot( SYSTEM.Trans_Mat(llb,:,axes)', PRIOR.Prior_Mat(axes,:)' );
                    if(posterior(axes,1) > 1)
                        fprintf('\nPrediction Step Produces Probability > 1. Look at line 102.')
                    end
                end
            end
%% CORRECTION STEP: Update the belief

            % CORRECTION STEP
            % bel'(x) = p(z|x)bel and N = N + bel'
            % we need to compute the posterior for each of the 6 LLBs
            
            % Measurement Probability
            % Compute gaussian error between measured state and desired state.
            
            % 1) Extract the cumulative duration of the current llb:
            CumDur = ExtractCumDuration(currLLB,llbMat,time(k),axes);            
            
            % 2) Compute the multinomial statistical parameters
            x(currLLB,1,axes) = CumDur;             % Assign the duration of the current llb as the appropriate random variable, a single number. 
            u = MEASUREMENT.Meas_Mat(axes,:)';      % Extract the mean duration per state per axes for all llb = vector (6x1) of mean durations for all lbs. 
            v = VARIANCE.Var_Mat(axes,:)';          % Variance per state per axes for all llb = vector (6x1) of duration variances for all lbs. 
            s = sqrt(v);
            
            % 3) Compute the gaussian probability for the measurement model 
            %z=( 1./(sqrt(2*pi).*s) ) .*exp(-0.5*((x-u)./s).^2); 
            %z=normpdf (x, u, s)
            z = normcdf(x(:,1,axes),u,s); % Compute the probability as per the cumulative distribution
            z = CheckNaN(z);
            
            %% Check Cases
            for i=1:6 
                % If the CDF is at extrema 0 or 1, adjust to avoid prob. of
                % 0.
                if(z(i,1)==1.0) 
                    z(i,1) = 0.999;
                end
                if(z(i,1)==0.0)
                    z(i,1)=0.001;
                end

                % If the DURATION was equal to zero, NO CONTRIBUTION, need to set z to ZERO. Those values are not zero due to the variance
                % value that was computed. This is a temporal boundary.                
                if(x(i,1,axes)==0)
                    z(i,1) = 0;
                end                
                % In this case, we only treat one side of the curve. 0.5 will
                % be max prob. So if z>0.5, we set it equal to 1-z.                    
                if(z(i,1) > 0.5) 
                    z(i,1) = 1-z(i,1);
                end
            end

            % Accumulate values of z over time to plot later
            if(debug);zTime(:,k+1-StartRot,axes) = z;end;
            
            %   4) Compute the posterior according to the measurement model
            %   for each of the llb's in a given time step for a given axis.
            %   This is 6x1 vec, where each entry is the posterior of a
            %   given llb. 
            posterior(:,1) = z.*posterior(:,1);
            
            % 5) Update the normalizing constant for each llb in a state in an axis.
            N = sum(posterior(:,1));  
            
            % 6) Normalize the posterior
            posterior(:) = posterior(:)/N;
            
            % 7) Copy posterior into posterior time for the corresponding element
            %    It's a 6 x k x axes structure for a single automata state.
            postTime(:,k,axes) = posterior(:,1);  
                      
        end % End Axes               
    end % End Time          
    
%% Plot and Save the LLB Belief Per Axis    
    % Plot the belief for each LLB for all six axes for the three automata
    % states
    plotllbBelief(fPath,StratTypeFolder,FolderName,time,postTime,modStateTimes);    
    
%% Save the LLB Posterior

    % Print llbehStruc  to file
    % Select kind of data motComps = 0; llbehStruc = 1; hlbehStruc = 2; Posterior Prob = 3
    saveData = 1;   % Do you want to save .mat to file
    dataFlag = 3;   % Save probabilities
    PlotType = 'NA';% Usually used to indicate a force axis. Not needed here.
    WriteCompositesToFile(fPath,StratTypeFolder,FolderName,PlotType,saveData,postTime,dataFlag);
     
end  
