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
% stateData:        - Vector of state start times. Does not include task end.
% EndTime:          - When the task ends.
% TOP_LIMIT         - Vector of top data limits 
% BOTTOM_LIMIT      - Vector of bottom data limits
% plotOptions       - If false, one plot for all FT axes. If true, subplots
%**************************************************************************
function insertStates3(StrategyType,stateData,EndTime,handles,TOP_LIMIT,BOTTOM_LIMIT,plotOptions)
   
    % Insert EndTime as the last row of the stateData
    r = size(stateData);
    if(strcmp(StrategyType,'HSA') || strcmp(StrategyType,'ErrorCharac') || strcmp(StrategyType,'HIRO'))
        if(r(1)<5)
            stateData(r(1)+1,1) = EndTime;
        end
    elseif(strcmp(StrategyType,'FP'))
        if(r(1)<6)
            stateData(r(1)+1,1) = EndTime;
        end            
    end
    
    % Determine how many limits do we have: 6 for force moment or 8
    % including snap joints.
    if(~strcmp(StrategyType,'HSA') && ~strcmp(StrategyType,'ErrorCharac')) % If not HIRO
        FX=3;FY=4;FZ=5;MX=6;MY=7;MZ=8;
    else
        FX=1;FY=2;FZ=3;MX=4;MY=5;MZ=6;
    end

    % Fill in State Colors. For all axes in one plot or subplots.
    if(plotOptions==0) 
        FillFlag = 1; % Fill states with color
        axes(gca);    % Get handle to current axes
        insertStates(stateData,max(TOP_LIMIT),min(BOTTOM_LIMIT),FillFlag);
   
    else % Subplots
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
end