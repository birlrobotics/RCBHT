%%-------------------------------------------------------------------------
%%  Motion Composition Labels
%     % Labels for actions in motion compositions
%     adjustment      = 1;    % a
%     increase        = 2;    % i
%     decrease        = 3;    % d
%     constant        = 4;    % k
%     pos_contact     = 5;    % pc
%     neg_contact     = 6;    % nc
%     contact         = 7;    % c
%     unstable        = 8;    % u
%     noisy           = 9;    % n
%     none            = 10;    % z
%    %actionLbl       = {'a','i','d','k','pc','nc','c','u','n','z');  % String representation of each possibility in the actnClass set.                 
%     actionLbl       = [ 1,  2,  3,  4,  5,   6,   7,  8,  9,  10];  % Updated July 2012. Represent the actionLbl's directly by integers. Facilitates conversion into C++

%%-------------------------------------------------------------------------
function actionLbl = actionInt2actionLbl(actionLbl)

    % Convert labels to ints
    if(actionLbl==1)
        actionLbl = 'a';    % alignment
    elseif(actionLbl==2)
        actionLbl = 'i';    % increase
    elseif(actionLbl==3)
        actionLbl = 'd';    % decrease
    elseif(actionLbl==4)
        actionLbl = 'k';    % constant
    elseif(actionLbl==5)
        actionLbl = 'pc';    % positive contact
    elseif(actionLbl==6)
        actionLbl = 'nc';    % negative contact
    elseif(actionLbl==7)
        actionLbl = 'c';    % contact
    elseif(actionLbl==8)
        actionLbl = 'u';    % unstable
    elseif(actionLbl==9)
        actionLbl = 'n';    % noisy
    else % z:none
        actionLbl = 'z';    % none
    end    
end