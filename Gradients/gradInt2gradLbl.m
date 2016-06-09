%%-------------------------------------------------------------------------
% gradLbl2gradInt
% -Imp -Big -Med -Small Const Small Med Big Imp
%   -4   -3   -2     -1   0       1   2   3   4
%%-------------------------------------------------------------------------
function dLabel = gradInt2gradLbl(dLabel)

    % Convert labels to ints
    if(dLabel==1.0)
        dLabel = 'bpos';
    elseif(dLabel==2.0)
        dLabel = 'mpos';
    elseif(dLabel==3.0)
        dLabel = 'spos';
    elseif(dLabel==4.0)
        dLabel = 'bneg';
    elseif(dLabel==5.0)
        dLabel = 'mneg';
    elseif(dLabel==6.0)
        dLabel = 'sneg';
    elseif(dLabel==7.0)
        dLabel = 'cons';
    elseif(dLabel==8.0)
        dLabel = 'pimp';
    elseif(dLabel==9.0)
        dLabel = 'nimp';
    elseif(dLabel==10)
        dLabel = 'none';
    end    
end