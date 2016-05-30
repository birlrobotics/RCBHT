%% CheckNan
%  If the function contains NaN, convert them to zero.
%%
function z = CheckNaN(z)

    % Check for divisions by 0:
    Div = isnan(z);

    % If any of the elements are true, convert the NaN entry to zero.
    r = size(z);

    % Iterate through the elments
    for i=1:r
        if(Div(i))
            z(i) = 0;
        end
    end
end