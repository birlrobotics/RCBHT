%********************* Documentation **************************************
% This function LABELS the plot of primitives with composition labels. 
% The set of compositions include: {alignment, increase, decrease, constant}
% and represendted by the strings: {'a','i','d','c'}.
% 
% Positioning of Labels:
% The dependent axis is time. The average time between two primitives that
% have been compounded together is used to set the x-position of the label.
%
% The y-position is set 
% 
% Text Labeling:
% The text labeling is performed by extracting the first category or
% element of the CELL ARRAY motComps of type string. 
%
% Input Parameters:
% hlbehStruc:         - refers to the llbehStruc[llBehClass,avgVal,rmsVal,AmplitudeVal,mc1,mc2,t1Start,t1End,t2Start,t2End,tavgIndex]
% pType:        - the force element Fx,Fy,...,Mz.
%
% Output Parameters:
% htext         - handle to the text objects in case user wants to modify
%**************************************************************************
function htext = plotHighLevelBehCompositions(aHandle,TL,BL,hlbehStruc,stateData,fPath,StrategyType,FolderName)

%%  Preprocessing    
    %k       = 1;                               % counter
    len     = length(aHandle);                  % Check how many hanlde entries we have
    r       = length(hlbehStruc);               % Get the # entries of compositions
    sLen    = length(stateData);                % Number of states. When working with Hiro this assumes that there is a state entry for the end of the task. This is not the case if working with PA1-0 yet.
    htext   = zeros(r,1);                       % This is a text handle and can be used if we want to modify/delete the text
    center  = (stateData(end)-stateData(1))/2;
    
    % Strategy Type Folder
    StratTypeFolder=AssignDir(StrategyType);
    
    % Indeces
    % LblIndex  = 1;                                % type of composition: alignment, increase, decrease, constant
    if(strategySelector('PA',StrategyType))         % 'PA' stands for PivotApproach. This strat uses 5 states. The function will be set to true for a number of strategy types that belong to this category.
        % Create a char array for access to complete words
        hlBehLbl = char('Approach','Rotation','Alignment','Snap','Mating');
        
    elseif(strategySelector('SA',StrategyType)      % SA stands for SideApproach. This strat uses 5 states. The function will be set to true for a number of strategy types that belong to this category.
        hlBehLbl = char('Approach','Rotation','Snap','Mating'); % For HIRO and ErrorCharac change the labels into an array of strings.
    else
        hlBehLbl = char('Approach','Rotation','Snap','Mating');
    end       
        
%%  Evaluate High-Level Behaviors
       
    % Change the color of the string based on whether it was successful or not
    if(hlbehStruc(1:end)) % end is used b/c when used with PA10 there are five states, when used with HIRO there are 4 states.
        clrVec = [0,0.50,0]; % green for success            
        result = 'SUCCESS';
    else
        clrVec = [0.5,0,0]; % red for failure            
        result = 'FAILURE';
    end

%%  HANDLES    
    % For each of the axis handles
    if(len==8); len=6; end;
    for i=1:len                           % Expect 6                
        
        axes(aHandle(i));        
        
        % Plot Properties
        % Maximum height of plot
        maxHeight = aHandle(i).YLim(2);
        minHeight = aHandle(i).YLim(1);

        % Set Text Upper Height Limit
        if(TL(i)>maxHeight)
            TL(i)=maxHeight;
        elseif(TL(i)<minHeight)
            TL(i)=minHeight;
        end

        % Set Text Lower Height Limit
        if(BL(i)<minHeight)
            BL(i)=minHeight;
        elseif(BL(i)>maxHeight)
            BL(i)=maxHeight;
        end    

        % Set Text Height Levels. For HLB @ 10% From Bottom. For Task @ 50%
        if(maxHeight>0) % 
            height_HLB =minHeight+((maxHeight-minHeight)*0.05);
            height_Task=minHeight+((maxHeight-minHeight)*0.50);
        else 
            height_HLB =minHeight+((maxHeight-minHeight)*0.05);
            height_Task=minHeight+((maxHeight-minHeight)*0.50);
        end
        
%%      STATES        
        % For each of the states
        for index=1:sLen-1                 % Expect 6-1=5
            
%%          COLOR            
            % Depending on whether or not we have a successful high-level behavior change the color.
            if(hlbehStruc(index))
                clrVec = [0,0.25,0]; %green for success
            else
                clrVec = [0.25,0,0]; %red for failure
            end
            
%%          X-LOCATION            
            % Compute the 0.50 location of each state
            if(index<length(stateData))
                textPos_HLB = (stateData(index) + stateData(index+1))/2;                
%             % For the last two states put at one third and two thirds
%             elseif(index==5)
%                 if(k==1)
%                     sLen=stateData(index+1)-stateData(index);
%                     textPos = stateData(4)+sLen*k*1/3;
%                     k=k+1;
%                 end
%             elseif(index==5)
%                     textPos = stateData(4)+sLen*k*1/3;
%                     k = 1;  % Reset for next cycle
            else
                break;
            end              
                
            % Plot the labels
            htext(i)=text(textPos_HLB,...                           % x-position. Average time of composition.
                           height_HLB,...                           % y-position. No randomness here since there is no overcrowding... //Set it at 75% of the top boundary of the axis +/- randn w/ sigma = BL*0.04
                           hlBehLbl(index,:),...                % HLB String: Approach, Rotation, Insertion, Mating
                          'Color',clrVec,...                    % Green or red font color
                          'FontSize',10,...                     % Size of font
                          'FontWeight','bold',...               % Font weight can be light, normal, demi, bold
                          'HorizontalAlignment','center');      % Alignment of font: left, center, right.        
    
            %%  Print the SUCCESS and FAILURE LABEL when we reach the last state
            if(index==(sLen-1 ))
                text(center,...                         % x-position. Position at the center
                     height_Task,...                     % y-position. Position almost at the top
                     result,...                         % 'Success' string
                     'Color',clrVec,...                 % Color
                     'FontSize',10,...                   % Size of font
                     'FontWeight','bold',...            % Font weight can be light, normal, demi, bold
                     'HorizontalAlignment','center');   % Alignment of font: left, center, right.);
            end                        
        end % End index=1:sLen-1  
    end % End fori=1:len
%%  Save plot
    savePlot(fPath,StratTypeFolder,FolderName,aHandle,'hlbehPlot');
end