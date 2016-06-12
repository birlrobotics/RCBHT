% Calls snapVerification with hardcoded inputs
function [stateTimes,hlbehStruc]=pRCBHT()
    StrategyType='REAL_BAXTER_ONE_SA_SUCCESS';  % Using the real baxter robot, with one arm for side approach assembly
    FolderName='pa_jtc_tracIK';                 % this folder is in pa_demo/bags
    first=1;                                    % Evaluate from Fx to Mz
    last=6;
    [~,~,stateTimes,hlbehStruc,~,~]=snapVerification(StrategyType,FolderName,first,last);
end