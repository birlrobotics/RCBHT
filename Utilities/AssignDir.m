%%*************************** Documentation *******************************
% Function used for Snap Assembly strategies. 
% Assigns appropriate strategy path based on the kind of approach used.
%
% If new categories are created for HIRO, please do a global
% search for HSA and make sure that any string comparisons include the new
% categories. Need to improve the way we do this. There are several
% instances in the code, where parameters change according to the type of
% experiment that is being run.
%
% I.e. loadData.m, SnapData3.m, InsertStates3.m, WritePrimitivesToFile.m,
% cleanUp.m, WriteCompositesToFile.m, plotMotionCompositions.m,
% GradientClassification.m, CustomizePlotLength.m
%**************************************************************************
function StratTypeFolder = AssignDir(StrategyType)

% Assign a directory path based on the StrategyType used. 
    if strcmp(StrategyType,'S')
        StratTypeFolder = 'PositionControl/StraightLineApproach-NewIKinParams/';            % Straight Line with new IKin params
    elseif strcmp(StrategyType,'SN')
        StratTypeFolder = 'PositionControl/StraightLineApproach-NewIkinParams-Noise/';      % Straight Line with new IKin params with noise
    elseif strcmp(StrategyType,'P')
        StratTypeFolder = 'PositionControl/PivotApproach-NewIkinParams/';                   % Pivot approach with new IKin Params
    elseif strcmp(StrategyType,'PN')
        StratTypeFolder = 'PositionControl/PivotApproach-NewIKin-Noise/';                   % Pivot approach with new IKin Params with noise
    elseif strcmp(StrategyType,'FS')
        StratTypeFolder = 'ForceControl/StraightLineApproach/';                             % Used with PA10 Simulation
    elseif strcmp(StrategyType,'FP')
        StratTypeFolder = 'ForceControl/PivotApproach/';                                    % Used with PA10 PivotApproach Simulation
    elseif strcmp(StrategyType,'HSA')
        StratTypeFolder = 'ForceControl/SideApproach/';                                     % Used with HIRO SideApproach Simulation and Physical
    elseif strcmp(StrategyType, 'ErrorCharac')
        StratTypeFolder = 'ForceControl/ErrorCharac/';                                      % Used with HIRO SideApproach to compute error characteristics
    elseif strcmp(StrategyType,'HIRO')
        StratTypeFolder = 'ForceControl/HIRO/';                                             % Used for experiments with real HIRO robot and side approach.
    else
        StratTypeFolder = '';
%        FolderName='';
    end
end