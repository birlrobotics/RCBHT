%%******************* Documenation ****************************************
% Compute the derivative (differences) of X and Y.
% Input Params:
% X:                - typically angle data in my usage
% Y:                - typically force-moment data in my usage
%
% Ouput Params:
% dX:               - typically derivatives in position
% dY:               - typically derivatives in force
%**************************************************************************
function [dX dY] = computeDataDifference(X,Y)

% Rates of change for force and moment over time
% Create the matrices that will hold the differential data
[pr pc] = size(X);          % Position differential
[fr fc] = size(Y);          % Force    differential

dX = zeros(pr-1,pc);        % The differential vector is a n-1 vector along the time dimension
dY = zeros(fr-1,fc);        

% Copy the time over
dX(:,1) = X(1:pr-1,1);           % Position differential vector
dY(:,1) = Y(1:fr-1,1);           % Force differential vector  


% Fill in the differential data for PxyzRxyz
for i=1:pr-1            % For all time points - 1
    for j=2:pc          % Start with the second column Fx, and move down for other columns. 
        dX(i,j) = X(i+1,j) - X(i,j);
    end
end

% Fill in the differential data for FxyzMxyz
for i=1:fr-1     % For all time points
    for j=2:fc % Start with the second column Fx, and move down for other columns. 
        dY(i,j) = Y(i+1,j) - Y(i,j);
    end
end