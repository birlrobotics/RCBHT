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
%       SIM_PA10_SLA
%       SIM_PA10_PivotApproach
%% -------------- hiro Robot ----------------------------
%       SIM_HIRO_SLA
%       SIM_HIRO_SLA_NOISE
%       SIM_HIRO_PivotApproach,
%       SIM_HIRO_PivotApproach_Noise
%       SIM_HIRO_SideApproach
%       SIM_HIRO_SA_ErrorCharac_001
%       SIM_HIRO_SA_ErrorCharac_002
%       SIM_HIRO_SA_ErrorCharac_003
%       SIM_HIRO_SA_ErrorCharac_004
%       SIM_HIRO_SA_DualArm
%       HIRO_SA_ErrorCharac
%% -------------- SLA ----------------------------
%       SIM_HIRO_SLA
%       SIM_HIRO_SLA_NOISE
%       SIM_PA10_SLA
%% -------------- PA ----------------------------   
%       SIM_HIRO_PivotApproach,
%       SIM_HIRO_PivotApproach_Noise
% 		SIM_PA10_PivotApproach,
%% -------------- SA ----------------------------
%       % --- Simulated HIRO
%       SIM_HIRO_SideApproach
%       SIM_HIRO_SA_ErrorCharac_001
%       SIM_HIRO_SA_ErrorCharac_002
%       SIM_HIRO_SA_ErrorCharac_003
%       SIM_HIRO_SA_ErrorCharac_004
%       SIM_HIRO_SA_DualArm
%       % --- Real HIRO
%       HIRO_SideApproach
%       % --- Real HIRO Error Charac
%       HIRO_SA_ErrorCharac
%       % --- Simulated Baxter
%       SIM_BAXTER_SA
%       SIM_BAXTER_SA_DUAL
%       % --- Real Baxter
%       BAXTER_SideApproach
%       BAXTER_SA_DUAL
%--------------------------------------------------------------------------
function res = strategySelector(category,StrategyType)

    %% Robot Type: PA10
    if(strcmp(category,'pa10'))
        if(strcmp(StrategyType,'SIM_PA10_SLA') ||...
            strcmp(StrategyType,'SIM_PA10_PivotApproach'))
        
            res=true;
            return;             
        else
            res=false;
            return;
        end
        
    % HIRO
    elseif(strcmp(category,'hiro'))
        if(strcmp(StrategyType,'SIM_HIRO_SLA')                      ||...
                strcmp(StrategyType,'SIM_HIRO_SLA_NOISE')           ||...
                strcmp(StrategyType,'SIM_HIRO_PivotApproach')       ||...
                strcmp(StrategyType,'SIM_HIRO_PivotApproach_Noise') ||...
                strcmp(StrategyType,'SIM_HIRO_SideApproach')        ||...
                strcmp(StrategyType(1:23),'SIM_HIRO_SA_ErrorCharac')||...
                strcmp(StrategyType,'SIM_HIRO_SA_DualArm')          ||...
                strcmp(StrategyType,'HIRO_SA_ErrorCharac'))
        
            res=true;
            return;             
        else
            res=false;
            return;
        end
        
    % Baxter
    elseif(strcmp(category,'baxter'))
        if(strcmp(StrategyType,'SIM_BAXTER_SA')                     ||...
                strcmp(StrategyType,'SIM_BAXTER_SA_DUAL')           ||...
                strcmp(StrategyType,'BAXTER_SideApproach')          ||...
                strcmp(StrategyType,'BAXTER_SA_DUAL'))
        
            res=true;
            return;             
        else
            res=false;
            return;
        end    

    %% Strategy Type: 
    elseif(strcmp(category,'SLA'))
        if(strcmp(StrategyType,'SIM_HIRO_SLA') ||...
            strcmp(StrategyType,'SIM_HIRO_SLA_NOISE') ||...
            strcmp(StrategyType,'SIM_PA10_SLA'))
        
            res=true;
            return;             
        else
            res=false;
            return;
        end
    
    elseif(strcmp(category,'PA'))
            if(strcmp(StrategyType,'SIM_HIRO_PivotApproach') ||...
                strcmp(StrategyType,'SIM_HIRO_PivotApproach_Noise') ||...
                strcmp(StrategyType,'SIM_PA10_PivotApproach'))
                
                res=true;
                return;
            else
                res=false;
                return;
            end
    elseif(strcmp(category,'SA'))
            if(strcmp(StrategyType,'SIM_HIRO_SideApproach') ||...
                strcmp(StrategyType,'SIM_HIRO_SA_ErrorCharac_001') ||...
                strcmp(StrategyType,'SIM_HIRO_SA_ErrorCharac_002') ||...
                strcmp(StrategyType,'SIM_HIRO_SA_ErrorCharac_003') ||...
                strcmp(StrategyType,'SIM_HIRO_SA_ErrorCharac_004') ||...
                strcmp(StrategyType,'SIM_HIRO_SA_DualArm') ||...
                strcmp(StrategyType,'HIRO_SideApproach') ||...
                strcmp(StrategyType,'HIRO_SA_ErrorCharac') ||...
                strcmp(StrategyType,'SIM_BAXTER_SA') ||...
                strcmp(StrategyType,'SIM_BAXTER_SA_DUAL') ||...
                strcmp(StrategyType,'BAXTER_SideApproach') ||...
                strcmp(StrategyType,'BAXTER_SA_DUAL'))
                
                res=true;
                return;
            else
                res=false;
                return;
            end
    %% Dual Arms
    elseif(strcmp(category,'dual'))
        if(strcmp(StrategyType,'SIM_HIRO_SA_DualArm')              	||...
                strcmp(StrategyType,'SIM_BAXTER_SA_DUAL')           ||...
                strcmp(StrategyType,'BAXTER_SA_DUAL'))
        
            res=true;
            return;             
        else
            res=false;
            return;
        end             
    end
end
