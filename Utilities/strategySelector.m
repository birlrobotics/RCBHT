% This function helps select appropriate strategy strings as defined by /Utilities/AssignDir.m
% The function takes two inputs: 
% StrategyType:		string provided by user to test a desired strategy.
% 		
% Possible CATEGORIES to include are as follows:
%   1. SLA:     straight line approach. Very early work. 
%   2. PA:      Pivot Approach. Consisted of 5 stages: Approach, Rotation,
%               Alignment, Insertion, Mating.
%   3. SA:      Side Approach. Consits of 4 stages: Approach, Rotation,
%               Insertion, Mating. 
%
% Categories are broad and include several STRATEGYTYPES. Categories can be
% conceived as a robot type, a strategy type, or the number of arms.

%% -------------- pa10 Robot ----------------------------
%       SIM_PA10_ONE_SL_SUCCESS
%       SIM_PA10_ONE_PA_SUCCESS
%% -------------- hiro Robot ----------------------------
%       SIM_HIRO_SLA
%       SIM_HIRO_SLA_NOISE
%       SIM_HIRO_ONE_PA_SUCCESS,
%       SIM_HIRO_ONE_PA_NOISE
%       SIM_HIRO_ONE_SA_SUCCESS
%       SIM_HIRO_ONE_SA_FAILURE
%       SIM_HIRO_ONE_SA_ERROR_CHARAC_LoopBack_x
%       SIM_HIRO_ONE_SA_ERROR_CHARAC_LoopBack_y
%       SIM_HIRO_ONE_SA_ERROR_CHARAC_Prob
%       SIM_HIRO_ONE_SA_ERROR_CHARAC_SVM
%       SIM_HIRO_TWO_SA_SUCCESS
%       SIM_HIRO_TWO_SA_FAILURE
%       REAL_BAXTER_ONE_SA_SUCCESS
%       REAL_HIRO_ONE_SA_SUCCESS
%       REAL_HIRO_ONE_SA_ERROR_CHARAC              
%% -------------- baxter  ----------------------------
%       SIM_BAXTER_ONE_SA_SUCCES
%       SIM_BAXTER_SA_DUAL
%       REAL_BAXTER_ONE_SA_SUCCESS
%       REAL_BAXTER_TWO_SA_SUCCESS
%% -------------- SLA ----------------------------
%       SIM_HIRO_SLA
%       SIM_HIRO_SLA_NOISE
%       SIM_PA10_ONE_SL_SUCCESS
%% -------------- PA ----------------------------   
%       SIM_HIRO_ONREAL_BAXTER_ONE_SA_SUCCESS_PA_SUCCESS,
%       SIM_HIRO_ONE_PA_NOISE
% 		SIM_PA10_ONE_PA_SUCCESS,
%% -------------- SA ----------------------------
%       % --- Simulated HIRO
%       SIM_HIRO_ONE_SA_SUCCESS
%       SIM_HIRO_ONE_SA_FAILURE
%       SIM_HIRO_ONE_SA_ERROR_CHARAC_LoopBack_x
%       SIM_HIRO_ONE_SA_ERROR_CHARAC_LoopBack_y
%       SIM_HIRO_ONE_SA_ERROR_CHARAC_Prob
%       SIM_HIRO_ONE_SA_ERROR_CHARAC_SVM
%       SIM_HIRO_TWO_SA_SUCCESS
%       SIM_HIRO_TWO_SA_FAILURE
%       % --- Real HIRO
%       REAL_HIRO_ONE_SA_SUCCESS
%       % --- Real HIRO Error Charac
%       REAL_HIRO_ONE_SA_ERROR_CHARAC
%       % --- Simulated Baxter
%       SIM_BAXTER_ONE_SA_SUCCES
%       SIM_BAXTER_SA_DUAL
%       % --- Real Baxter
%       REAL_BAXTER_ONE_SA_SUCCESS
%       REAL_BAXTER_TWO_SA_SUCCESS
%--------------------------------------------------------------------------
function res = strategySelector(category,StrategyType)

    %% Robot Type: PA10
    if(strcmp(category,'pa10'))
        if(strcmp(StrategyType,'SIM_PA10_ONE_SL_SUCCESS') ||...
            strcmp(StrategyType,'SIM_PA10_ONE_PA_SUCCESS'))
        
            res=true;
            return;             
        else
            res=false;
            return;
        end
%--------------------------------------------------------------------------        
    % HIRO
%--------------------------------------------------------------------------    
    elseif(strcmp(category,'hiro'))
        if(strcmp(StrategyType,'SIM_HIRO_SLA')                              ||...
                strcmp(StrategyType,'SIM_HIRO_SLA_NOISE')                   ||...
                strcmp(StrategyType,'SIM_HIRO_ONE_PA_SUCCESS')              ||...
                strcmp(StrategyType,'SIM_HIRO_ONE_PA_NOISE')                ||...
                strcmp(StrategyType,'SIM_HIRO_ONE_SA_SUCCESS')              ||...
                strcmp(StrategyType,'SIM_HIRO_ONE_SA_FAILURE')              ||...
                strcmp(StrategyType,'SIM_HIRO_ONE_SA_ERROR_CHARAC_LoopBack_x')  ||... 
                strcmp(StrategyType,'SIM_HIRO_ONE_SA_ERROR_CHARAC_LoopBack_y')  ||... 
               	strcmp(StrategyType,'SIM_HIRO_ONE_SA_ERROR_CHARAC_Prob')    ||... 
                strcmp(StrategyType,'SIM_HIRO_ONE_SA_ERROR_CHARAC_SVM')     ||... 
                strcmp(StrategyType,'SIM_HIRO_TWO_SA_SUCCESS')              ||...
                strcmp(StrategyType,'SIM_HIRO_TWO_SA_FAILURE')              ||...
                strcmp(StrategyType,'REAL_HIRO_ONE_SA_SUCCESS')             ||...
                strcmp(StrategyType,'REAL_HIRO_ONE_SA_ERROR_CHARAC'))
        
            res=true;
            return;             
        else
            res=false;
            return;
        end
%--------------------------------------------------------------------------        
    % Baxter
%--------------------------------------------------------------------------    
    elseif(strcmp(category,'baxter'))
        if(strcmp(StrategyType,'SIM_BAXTER_ONE_SA_SUCCESS')          ||...
                strcmp(StrategyType,'SIM_BAXTER_SA_DUAL')           ||...
                strcmp(StrategyType,'REAL_BAXTER_ONE_SA_SUCCESS')   ||...
                strcmp(StrategyType,'REAL_BAXTER_TWO_SA_SUCCESS'))
        
            res=true;
            return;             
        else
            res=false;
            return;
        end    
%--------------------------------------------------------------------------
    %% Strategy Type: 
%--------------------------------------------------------------------------
%   Straight Line Approach
%--------------------------------------------------------------------------
    elseif(strcmp(category,'SLA'))
        if(strcmp(StrategyType,'SIM_HIRO_SLA') ||...
            strcmp(StrategyType,'SIM_HIRO_SLA_NOISE') ||...
            strcmp(StrategyType,'SIM_PA10_ONE_SL_SUCCESS'))
        
            res=true;
            return;             
        else
            res=false;
            return;
        end
%--------------------------------------------------------------------------
% Pivot Approach: 5 states
%--------------------------------------------------------------------------
    elseif(strcmp(category,'PA'))
            if(strcmp(StrategyType,'SIM_HIRO_ONE_PA_SUCCESS') ||...
                strcmp(StrategyType,'SIM_HIRO_ONE_PA_NOISE') ||...
                strcmp(StrategyType,'SIM_PA10_ONE_PA_SUCCESS'))
                
                res=true;
                return;
            else
                res=false;
                return;
            end
%--------------------------------------------------------------------------
% Side Approach: 4 states
%--------------------------------------------------------------------------
    elseif(strcmp(category,'SA'))
            if(strcmp(StrategyType,'SIM_HIRO_ONE_SA_SUCCESS')               ||...
                strcmp(StrategyType,'SIM_HIRO_ONE_SA_FAILURE')              ||...
                strcmp(StrategyType,'SIM_HIRO_ONE_SA_ERROR_CHARAC_LoopBack_x')  ||... 
                strcmp(StrategyType,'SIM_HIRO_ONE_SA_ERROR_CHARAC_LoopBack_y')  ||... 
               	strcmp(StrategyType,'SIM_HIRO_ONE_SA_ERROR_CHARAC_Prob')    ||... 
                strcmp(StrategyType,'SIM_HIRO_ONE_SA_ERROR_CHARAC_SVM')     ||... 
                strcmp(StrategyType,'SIM_HIRO_TWO_SA_SUCCESS')              ||...
                strcmp(StrategyType,'SIM_HIRO_TWO_SA_FAILURE')              ||...
                strcmp(StrategyType,'REAL_HIRO_ONE_SA_SUCCESS')             ||...
                strcmp(StrategyType,'REAL_HIRO_ONE_SA_ERROR_CHARAC')        ||...
                strcmp(StrategyType,'SIM_BAXTER_ONE_SA_SUCCES')             ||...
                strcmp(StrategyType,'SIM_BAXTER_SA_DUAL')                   ||...
                strcmp(StrategyType,'REAL_BAXTER_ONE_SA_SUCCESS')           ||...
                strcmp(StrategyType,'REAL_BAXTER_TWO_SA_SUCCESS'))
                
                res=true;
                return;
            else
                res=false;
                return;
            end
    %% ERRORS
%--------------------------------------------------------------------------
%   HIRO ERRORS
%--------------------------------------------------------------------------
    elseif(strcmp(category,'hiro_error'))
            if(strcmp(StrategyType(1:23),'SIM_HIRO_ONE_SA_ERROR_CHARAC_LoopBack_x')     ||...
               strcmp(StrategyType,'SIM_HIRO_ONE_SA_FAILURE')                           ||...
               strcmp(StrategyType,'SIM_HIRO_TWO_SA_FAILURE'))
                
                res=true;
                return;
            else
                res=false;
                return;
            end            
    %% Dual Arms
%--------------------------------------------------------------------------
%   Two arm scenarios
%--------------------------------------------------------------------------
    elseif(strcmp(category,'dual'))
        if(strcmp(StrategyType,'SIM_HIRO_TWO_SA_SUCCESS')              	||...
                strcmp(StrategyType,'SIM_BAXTER_SA_DUAL')               ||...
                strcmp(StrategyType,'REAL_BAXTER_TWO_SA_SUCCESS'))
        
            res=true;
            return;             
        else
            res=false;
            return;
        end             
    end
end
