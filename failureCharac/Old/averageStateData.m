% averageHistStateData
% This function takes a historical averaged figure of automata state data
% tranistions times and averages a new value into it.
%
% Finally increase the counter by one.
%
% Inputs:
% StrategyType:     what kind of strategy/experiment are we doing
% stateData:        col vector of automata transition state times
% histStateData:    col vector of historical averaged automata transition
%                   times. however, the 1st entry of this vector keeps a
%                   counter of how many times the averaging has been done
function histData = averageStateData(StrategyType,stateData,histData)

    %% Perform Averaging: new_tot_num-1*histAvgData + 1/new_tot_num*new_data
    if(strcmp(StrategyType,'SIM_SideApproach') || strcmp(StrategyType1(1:18),'SIM_SA_ErrorCharac') || strcmp(StrategyType,'SIM_SA_DualArm')) 
        for i=3:6 % We start at index 3, because index 2 is always 0, indicating the start of the task
         histData(i,1) = histData(i,1)*( histData(1,1)/(histData(1,1)+1) ) + ...
                             ( stateData(i-1,1)*1/(histData(1,1)+1) );
        end

    % PA10 Approach
    else
         for i=2:7
         histData(i,1) = histData(i,1)*( histData(1,1)/(histData(1,1)+1) ) + ...
                             ( stateData(i-1,1)*1/(histData(1,1)+1) );
        end       
    end
    
    
    %% Increase Counter by one
    histData(1,1) = histData(1,1) + 1;
end