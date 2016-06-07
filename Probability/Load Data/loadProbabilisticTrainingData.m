%% loadProbabilisticTrainingData
% Loads probability data: priors, system model probabilities, and
% measurement model probabilities that were created on 20120525.
%%
function [PRIOR SYSTEM MEASUREMENT VARIANCE] = loadProbabilisticTrainingData

%% Priors
    % Each output is a 6x6 matrix with rows representing the force axis
    % {Fx,Fy,Fz,Mx,My,Mz} and the columsn {FX CT PS PL SH AL} representing the
    % low-level behaviors. The value of the matrix represents the probability
    % that that beavhior is present in the corresponding automata state. 
    % Note that the probability values are captures as a function of duration
    % in the state. I.e if the state is 10 seconds long, and FX takes 5 secs,
    % then the prob. of that LLB is 0.5
    [Prior_Rot Prior_Snap Prior_Mat] = loadTrainingPriorProb;      

    % Create a structure
    PRIOR = struct('Prior_Rot',Prior_Rot,'Prior_Snap',Prior_Snap,'Prior_Mat',Prior_Mat);

%% Transition Model
    %% loadTrainingSystemModel
    % The system model is the probability of going from state t-1 to state t.
    % In this case we have six states or low level behaviors (LLBs): fix,
    % contact, push, pull, shift, and align. They are summarized by: 
    % {FX, CT, PS, PL, SH, AL}.
    %
    % The probabilities of going from one state to another are encoded in a 6x6
    % matrix with rows and column entries ordered as shown above.
    %
    % This 6x6 matrix thus represents state-transition probabilities. Most of
    % these matrices are sparse.
    %
    % The computation of these matrices is also performed separately for each
    % of the six force axis of the robot; that is, the force in the x,y,z
    % directions as well as the moment:
    % {Fx Fy Fz Mx My Mz}.
    %
    % Finally, these transition computations are also performed for each of the three automata states that use fore data 
    % in the Pivot/Side Approach: Rotation, Snap, and Mating.
    %
    % Hence, the output is organized in SIX 6x6 matrices for each of the THREE
    % automata state, for a total of 18 matrices. 
    % To simplify the output, the six force matrices will be encoded as part of
    % a structure within the automata states. That is to say, expect the
    % following matrix structures:
    %   struct Rot{Fx...Mz}; 
    %   struct Snap{Fx...Mz};
    %   struct Mat{Fx...Mz};

    % Data Flag
    xlsDataImport = 1;
    dataTypeFlag = xlsDataImport;
    [Trans_Rot Trans_Snap Trans_Mat] = loadTrainingSystemModel(dataTypeFlag);

    % Create a structure for all Transition Probabilities
    SYSTEM = struct('Trans_Rot',Trans_Rot,'Trans_Snap',Trans_Snap,'Trans_Mat',Trans_Mat);

%% Measurement Model
    % The measurement model probabilities that are generated as a mean value from training data.
    %
    % The measurements are for low-level behaviors (LLBs) that are deemed essential
    % to characterized the desired high-level behaviors (HLBs) for a successful cantilever snap
    % assembly based on the Pivot Approach for four snaps.
    %
    % The measurements found here are the average "cumulative-durations" of
    % a given llb per automata state. So if there are two llb's found in
    % one automata state, their durations in seconds is summed up and counted as one. 

    [Meas_Rot Meas_Snap Meas_Mat] = loadTrainingMeasurementModel;

    % Create a structure for measurement probabilistic data
    MEASUREMENT = struct('Meas_Rot',Meas_Rot,'Meas_Snap',Meas_Snap,'Meas_Mat',Meas_Mat);
    
%% Variance on Measurement Model
    % The measurement model probabilities that are generated as the variance from training data.
    %
    % The measurements are for low-level behaviors (LLBs) that are deemed essential
    % to characterized the desired high-level behaviors (HLBs) for a successful cantilever snap
    % assembly based on the Pivot Approach for four snaps.
    %
    % The measurements found here are the variance of them "cumulative-durations" of
    % a given llb per automata state. 

    [Var_Rot Var_Snap Var_Mat] = loadTrainingVariance;

    % Create a structure for measurement probabilistic data
    VARIANCE = struct('Var_Rot',Var_Rot,'Var_Snap',Var_Snap,'Var_Mat',Var_Mat);    
end