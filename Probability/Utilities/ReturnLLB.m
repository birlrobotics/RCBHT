%% ReturnLLB
% This function returns a string LLB tag ('FX' or 'CT' or 'PS' or 'PL' or
% 'SH' or 'AL') depending on which LLB was recorded for a given time step.
%
% Inputs:
% time              - the current simulation time
% llbStruc          - this is a (n x 4 x 1) structure continaing:
%                     {'llbtag',StartingTime,EndingTime,Duration}. It
%                     corresponds to a given force axis.
%
% Outputs:
% llbtag            - one of the LLBs shared above, if no match (in the
%                     case it is in the Approach state, it returns 0).
%%
function llbTag = ReturnLLB(time,llbStruc)

%% Initialize Variables
    tStart = 2;
    tEnd   = 3;
    Tag    = 1;
    
    
%% Extract Tag

    % For the given time index, if it is withing the bounds of the llb, return
    % the tag.
    
    % Get size of tag
    r = size(llbStruc);
    
    for elem = 1:r
        % 1) Check for false entries
        if( llbStruc(elem,tStart)==0 || llbStruc(elem,tEnd)==0 )
            llbTag = 0;
        
        % 2) Check to see if the time index is within the llbStruc    
        elseif( time >= llbStruc(elem,tStart) && time < llbStruc(elem,tEnd) ) % Do not includ the upper limit. Otherwise it absorbs the previous element and does not return the current element.
            llbTag = llbStruc(elem,Tag);
            break;

        % 3) If time is not within bounds, return llbTag = 0
        else
            llbTag = 0;
        end
    end
end