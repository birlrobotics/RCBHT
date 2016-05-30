%% hlbBayesFiltering (Offline)
% 
% Overview
% Computes the belief for each of the three -- force-containgin -- Side Approach (Pivot Approach
% with 4 Snaps) high-level-behavior (HLB) states: Rotation, Snap, and
% Mating in offline mode. 
%
% HLB Beliefs:
% The HLB beliefs are conceptualized as follows:
% Belief(Rotation), Belief(Snap|Rotation), Belief(Mating|Snap,Rotation)
%
% Conditional Probabilities:
% These conditional probabilities could be computed using some joint
% distribution. The joint probabilities could be modeled with some linear
% distribution. Such that as Rotation is more likely to succeed, so is the
% Snap, in a linear fashion.
% Update: have not the right way of doing this so far.
%
% HLB Prior Probabilities:
% The HLB prior probabilities are computed as the product of "key llb
% beliefs" for a given automata state for all force axes.
% However, the snap state has a unique aspect to it in that the contacts
% that happen in the {Fx,Fz,My} axes, do not necessarily happen at the same
% time. Especially the one for Fz which tends to happen later. Therefore
% such a product would yield 0 probability. For this reason, we look at
% this history of each of these and save the largest value to date in order
% to compute this prior. 
%
% KeyLLBLookUp.m returns data according to the following table:
%--------------------------------------------------------------------------
%   ROT     = ['FX'     'NA'    'FX'    'NA'    'FX'    'NA'];
%   SNAP    = ['CT'     'AF'    'AF'    'AF'    'CT'    'AF'];
%   MAT     = ['FX'     'FX'    'FX'    'FX'    'FX'    'FX'];
%--------------------------------------------------------------------------
%
% The HLB posterior belief is then the product of the priors. 
%
% Inputs:
% llBelief      - it's a (6 x 1 x Axes) structure where the rows represent
%                 the llb's in numerical format according to convertLLB2int.m
%                 And ['FX' 'CT' 'PS' 'PL' 'SH' 'AL'] are represented by
%                 1-6. And 'AF' the union of an AL and an FX is represented by 7.
% time          - time vector from RotState through SnapState to end of MatState.
% EndRot,EndSnap,EndMat - time indeces that signal the corresponding event.
% Outputs:
% hlbBelif      - it's a (6 x time) matrix of hlb beliefs. 
%%
function [hlbBelief llbBelief] = hlbBayesianFiltering(StrategyType,FolderName,stateTimes,llbBelief,time,EndRot,EndSnap,EndMat)

%% Initialize Data

    % Global Reference Parameters
    NumAxes = 6;  
    
    % Stringed Var's
    %llbBehaviors  = ['FX' 'CT' 'PS' 'PL' 'SH' 'AL'];
    HLB = ['ROT';'SNP';'MAT'];
    hlbLength = size(HLB);
    
    % Probability Structures
    keyLLB = zeros(6,1);
    hlbPrior = ones(1,hlbLength(1)); % Basically a 1x3 struc of prior probs
    
    hlbPriorRot = zeros(EndRot,1);
    hlbPriorSnp = zeros((EndSnap-EndRot-1),1);
    hlbPriorMat = zeros((EndMat-EndSnap),1);
    hlbBelief = zeros(EndMat,1);      % Structure to hold the belief for every time step excluding the Approach state.
    
    % LLB's Encoding: Generate variables that represent LLBs as int's:
     FX = 1; CT = 2; PS = 3; PL = 4; SH = 5; AL = 6; ALFX = 7; NA=-1;
     ROT = 1; SNP = 2; MAT = 3;
     
     % Contact - Maximum valus over time for CT criteria across 3 axes:
     Fx_MaxCT = 0;
     %Fz_MaxCT = 0;
     My_MaxCT = 0;
     
%% Flags for HLB Probability Method
     product    = 1;
     sum        = 2;
     probMethod = sum;
%% Compute Rotation Prior Probability according to automata state

%% Go through all time indeces in Rotation-Mating and compute priors for the 3 automata states
    % For a given HLB
    for timeIndex = 1:EndMat
        
        % For every time step initialize the hlb prior's
        hlbPrior(:) =1;
        
        % Go through all the axes and multiply all the key probabilities for that
        % time step to formulate a single value for the prior of a given HLB
        for axes = 1:NumAxes            
            
            % 1) Retrieve the key llb's as an integer according to automata state
            if(timeIndex<=EndRot)
                hlbTag = ROT;
                
            elseif(timeIndex>EndRot && timeIndex <= EndSnap)
                hlbTag = SNP;
              
            else
                hlbTag = MAT;
            end
            
            keyLLB(axes) = KeyLLBLookUp(HLB(hlbTag,:),axes);
            
            % 2) According to tag and state extract probability
            if( keyLLB(axes)== FX )
                hlbPrior(1,hlbTag) = hlbPrior(1,hlbTag) * llbBelief(FX,timeIndex,axes);
                
            elseif( keyLLB(axes)== CT )
                % Keep maximum historic value. Do it separately for each of
                % the axes. 
                if(axes==1)
                    if(llbBelief(CT,timeIndex,axes)>Fx_MaxCT)
                        Fx_MaxCT = llbBelief(CT,timeIndex,axes);
                        hlbPrior(1,hlbTag) = hlbPrior(1,hlbTag) * Fx_MaxCT;
                     end
%                 elseif(axes==3)
%                     if(llbBelief(CT,timeIndex,axes)>Fz_MaxCT)
%                         Fz_MaxCT = llbBelief(CT,timeIndex,axes);
%                         hlbPrior(1,hlbTag) = hlbPrior(1,hlbTag) * Fz_MaxCT;                    
%                     end
                elseif(axes==5)
                    if(llbBelief(CT,timeIndex,axes)>My_MaxCT)
                        My_MaxCT = llbBelief(CT,timeIndex,axes);
                        hlbPrior(1,hlbTag) = hlbPrior(1,hlbTag) * My_MaxCT;                    
                    end
                end
                                
            elseif( keyLLB(axes)== PS )
                hlbPrior(1,hlbTag) = hlbPrior(1,hlbTag) * llbBelief(PS,timeIndex,axes);
                
            elseif( keyLLB(axes)== PL )
                hlbPrior(1,hlbTag) = hlbPrior(1,hlbTag) * llbBelief(PL,timeIndex,axes);
                
            elseif( keyLLB(axes)== SH )
                hlbPrior(1,hlbTag) = hlbPrior(1,hlbTag) * llbBelief(SH,timeIndex,axes);
                
            elseif( keyLLB(axes)== AL )
                hlbPrior(1,hlbTag) = hlbPrior(1,hlbTag) * llbBelief(AL,timeIndex,axes);
                
            elseif( keyLLB(axes)== ALFX )    
                hlbPrior(1,hlbTag) = hlbPrior(1,hlbTag) * (llbBelief(AL,timeIndex,axes) + ...
                                                           llbBelief(FX,timeIndex,axes));    
            elseif( keyLLB(axes)== NA ) 
                hlbPrior(1,hlbTag) = hlbPrior(1,hlbTag)*1;
                
            end                            
        end
        
%% Compute the hlbPrior and the hlbBelief.
        % The hlbPrior is the product of priors. However, during state Rot,
        % there is no product. During state Snp, there are two products.
        % During Mat there are three products. 
        
        Window = 100; % At boundaries prob's change. So we look at a max within a window where hopefully the prob is still high before boundary changes
        
        % << Rotation >>
        if(timeIndex<=EndRot)
            hlbPriorRot(timeIndex,1) = hlbPrior(1,ROT);
            if(probMethod==sum)
                hlbBelief(timeIndex,1) = (hlbPrior(1,ROT)/3); % Cumulative sum
            else
            	hlbBelief(timeIndex,1) = (hlbPrior(1,ROT));
            end
            
        %% << Snap >>
        elseif(timeIndex>EndRot && timeIndex<=EndSnap)
            hlbPriorSnp(timeIndex-EndRot,1) = hlbPrior(1,SNP);  
            % Note, we will take the maximum probability in a window of 10
            % points, because around the transition point probabilities can
            % some times change. 
            if(probMethod==sum)
                hlbBelief(timeIndex,1) = (max(hlbPriorRot(EndRot-Window:EndRot,1))/3)+(hlbPriorSnp(timeIndex-EndRot,1)/3); %sum of priors
            else
                hlbBelief(timeIndex,1) = max(hlbPriorRot(EndRot-Window:EndRot,1))*hlbPriorSnp(timeIndex-EndRot,1); %Product of priors 
            end
        
        % << Mating >>
        else
            hlbPriorMat(timeIndex-EndSnap,1) = hlbPrior(1,MAT); 
            if(probMethod==sum)
                hlbBelief(timeIndex,1) = (max(hlbPriorRot(EndRot-Window:EndRot,1))/3)+(max(hlbPriorSnp((EndSnap-EndRot-Window):(EndSnap-EndRot-1),1))/3)+(hlbPriorMat(timeIndex-EndSnap,1)/3); % Sum of priors; 
            else
                hlbBelief(timeIndex,1) = (max(hlbPriorRot(EndRot-Window:EndRot,1)))*(max(hlbPriorSnp((EndSnap-EndRot-Window):(EndSnap-EndRot-1),1)))*(hlbPriorMat(timeIndex-EndSnap,1));
            end
            
        end % End hlbPrior and hlbBelief
    end     % EndMat
    
%% Save the HLB Prior and Posterior
    % Set Path and Strategy Folder
    StratTypeFolder = AssignDir(StrategyType); %i.e. Hiro Side Approach = 'HSA'
    % 2) Assing appropriate directoy based on Ctrl Strategy to read data files
    if(ispc)
        Path = 'C:\\Documents and Settings\\suarezjl\\My Documents\\School\\Research\\AIST\\Results';
    else
       Path = '\\home\\juan\\Documents\\Results'; 
       % QNX
       % '\\home\\vmrguser\\Documents\\Results'; 
    end 

    WriteHLBToFile(Path,StratTypeFolder,FolderName,hlbPriorRot,hlbPriorSnp,hlbPriorMat,hlbBelief);    
    
%% Plot the HLB Priors and the Belief    
    plotHLB(Path,StratTypeFolder,FolderName,...
            EndRot,EndSnap,EndMat,...
            time,stateTimes,...
            hlbPriorRot,hlbPriorSnp,hlbPriorMat,hlbBelief);  
end