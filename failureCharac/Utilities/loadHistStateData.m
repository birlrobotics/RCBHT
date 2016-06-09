%--------------------------------------------------------------------------
% loadHistStateData
% Loads the data structure loadHistStateData by formulating the right path
% structure and loading from MATLABs mat data struc.
%
% Inputs
% fPath:                    working directory
% StratTypeFolder:          correct path according to strategy
% 
% Outputs
% hisStateData:             a col vector with first item as counter and
%                           then a 5x1 for HSA/ErrorCharac or 6x1 for PA10
%                           vector of automata state transition times.
% hisStateDataPath:         path where the historical state data can be
%                           found
%--------------------------------------------------------------------------
function [histStateData,hisStateDataPath] = loadHistStateData(fPath,StratTypeFolder)

    % Set the path where the historicalData will be saved
    histStateDataDir = strcat('TrainingData/');
    
    % Create the entire working path
    hisStateDataPath = strcat(fPath,StratTypeFolder,histStateDataDir,'histStateData.mat');
    
    % Load the data
    load(hisStateDataPath,'-mat');  % 1x2 data struc. 1st element is a counter, 2nd is a col vector with 5 states and average transitions times
                                    % No need to provide an output arg. It
                                    % will load with the name with which it
                                    % was saved: histStateData 
end