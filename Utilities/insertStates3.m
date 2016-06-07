%%************************** Documentation ********************************
% All data used in this function was generated in snapData3. It plots 8
% subplots. On the left hand side column Fx, Fy, Fz, and the right hand side 
% column Mx, My, and Mz.
% 
% The function will call insertStates for each subplot. It will pass the
% stateData vector which has the times in which new states begin. It will
% use the handles for each subplot to select the appropriate axes when
% drawing the states, and similarly, it will use a top limit and bottom
% limit, to draw matlab "patch boxes" with transparently filled faces, to
% help differentiate each state.
%
% We chose to insertStates at the end of snapData3 instead with each
% subplot, because every time there is an adjustment to the axis limits,
% the patch face color disappears. 
%
% Inputs:
% StrategyType:     - If PA10 data, we have 8 plots, if HIRO 6 plots.
%**************************************************************************
function insertStates3(StrategyType,stateData,EndTime,handles,TOP_LIMIT,BOTTOM_LIMIT)
   
    % Insert EndTime as the last row of the stateData
    r = size(stateData);
    stateData(r(1)+1,1) = EndTime;
    
    % Determine how many limits do we have: 6 for force moment or 8
    % including snap joints.
    if(strategySelector('PA',StrategyType))         % 'PA' stands for PivotApproach. This strat uses 5 states. The function will be set to true for a number of strategy types that belong to this category.
        FX=3;FY=4;FZ=5;MX=6;MY=7;MZ=8;
    else
        FX=1;FY=2;FZ=3;MX=4;MY=5;MZ=6;
    end

    % Insert state lines
    FillFlag = 1; % Fill states with color
    axes(handles(1));                        % Fx
    insertStates(stateData,TOP_LIMIT(FX),BOTTOM_LIMIT(FX),FillFlag);    
    
    % Insert state lines
    axes(handles(2));                        % Fy
    insertStates(stateData,TOP_LIMIT(FY),BOTTOM_LIMIT(FY),FillFlag);     
    
    % Insert state lines
    axes(handles(3));                        % Fz
    insertStates(stateData,TOP_LIMIT(FZ),BOTTOM_LIMIT(FZ),FillFlag);         
    
    % Insert state lines
    axes(handles(4));                        % Mx
    insertStates(stateData,TOP_LIMIT(MX),BOTTOM_LIMIT(MX),FillFlag);        

    % Insert state lines
    axes(handles(5));                        % My
    insertStates(stateData,TOP_LIMIT(MY),BOTTOM_LIMIT(MY),FillFlag);        
       
    % Insert state lines
    axes(handles(6));                        % Mz
    insertStates(stateData,TOP_LIMIT(MZ),BOTTOM_LIMIT(MZ),FillFlag);        
end