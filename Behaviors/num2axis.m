% num2State
% Change a number from 1 to 6, into a corresponding 
%%-------------------------------------------------------------------------
function state=num2axis(num)

    % Convert labels to ints
    if(num==1)
        state = 'Fx';    % alignment
    elseif(num==2)
        state= 'Fy';    % increase
    elseif(num==3)
        state = 'Fz';    % decrease
    elseif(num==4)
        state = 'Mx';    % constant
    elseif(num==5)
        state = 'My';    % positive contact
    elseif(num==6)
        state = 'Mz';    % negative contact
    end    
end