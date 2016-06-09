% averageHistStateData
% This function takes a historical averaged figure of automata state data
% tranistions times and averages a new value into it.
%
% Finally increase the counter by one.
%
% Inputs:
% data:             current averaged data (1x1).
% histStateData:    col vector of historical averaged automata transition
%                   times. however, the 1st entry of this vector keeps a
%                   counter of how many times the averaging has been done
function histData = averageHistData(data,histData)

    % Indeces
    averagedIndex=2;
    
    if(histData(1,1)==0)
        histData(2,1) = data(averagedIndex-1,1);
    else
        %% Perform Averaging: new_tot_num-1*histAvgData + 1/new_tot_num*new_data
        histData(averagedIndex,1) = histData(averagedIndex,1)*( histData(1,1)/(histData(1,1)+1) ) + ...
                                    ( data(averagedIndex-1,1)*              1/(histData(1,1)+1) );
    end
    
    %% Increase Counter by one
    histData(1,1) = histData(1,1) + 1;    
end