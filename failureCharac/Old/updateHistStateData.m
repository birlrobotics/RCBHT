% updateHistStateData
% Loads the historically averaged automata state transition times data, it
% then performes averaging and counter updating with the new data and then
% saves the file as a file.
%
% Output
% histStateData:        outputs the col vec with ctr and times info
%--------------------------------------------------------------------------
function histStateData=updateHistData(fPath,StratTypeFolder,StrategyType,stateData,matName)

    % Load the historical stateData structure
    [histStateData,hisStateDataPath] = loadFCData(fPath,StratTypeFolder,matName);

    % Do the averaging
    histStateData = averageHistStateData(StrategyType,stateData,histStateData);

    % Save statData.mat to file
    save(strcat(hisStateDataPath),'histStateData','-mat');

end