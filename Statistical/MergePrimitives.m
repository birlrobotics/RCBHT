%% **************************** Documentation *****************************
% Merges data between repeated elements in a data composition data
% structure. 
% 
% The data structure is a row numeric vector array composed of 7 elements: 
% statData = [dAvg dMax dMin dStart dFinish dGradient dLabel]. 
%
% If the value of gradientLblIndex is 0 or 1, it will merge the neighbor,
% but if it is larger than 1, it functions as a counter and will average gradientLblIndex number of primitives.
% 
% Input Parameters:
% index:            - first element of contiguous pair.
% data:             - an mx11 cell array data structure containing action compositions
% gradientLbl       - array structure that holds strings for primitives (not used after 2013Aug)
% gradientLblIndex  - value of 0 or 1 used to select the first primitive or the second
%                     primitive. 
% 
% Output:
% Returns the whole data structure.
%**************************************************************************
function data = MergePrimitives(index,data,gradientLblIndex)
%function data = MergePrimitives(index,data,gradientLbl,gradientLblIndex)

%%  Initialization

    % Define next contiguous element
    match = index+1;

%%  GRADIENT PRIMITIVES
    % primitives Structure Indeces
     AVG_MAG_VAL      = 1;   % average value of primitive
     MAX_VAL          = 2;   % maximum value of a primitive
     MIN_VAL          = 3;   % minimum value of a primitive   

     % Time Indeces
     %T1S = 4; 
     T1E = 5;
    
    % Gradient Indeces
    GRAD_VAL    = 6;
    GRAD_LBL    = 7;
    
    % Contiguous neighbor is repeated. 
    if(gradientLblIndex<2)

    %%  Name Label 
        data(index,GRAD_LBL) = data(index+gradientLblIndex,GRAD_LBL); % Keep the label of the gradient that is longer

    %%  Values                                                        
        % Average average magnitude value: (index+match)/2
        data(index,AVG_MAG_VAL)     = mean([data(index,AVG_MAG_VAL),data(match,AVG_MAG_VAL)]);

        % MAX_VAL value: keep the maximum value that comes from either one
        data(index,MAX_VAL)         = max( data(index,MAX_VAL),data(match,MAX_VAL) ); 

        % MIN_VAL value: (index+match)/2
        data(index,MIN_VAL)         = min( data(index,MIN_VAL),data(match,MIN_VAL) );     

    %%  Time
        % T1_END,index = T2_END,index
        data(index,T1E) = data(index+1,T1E);

    %% Gradient
        % Average gradient values
        data(index,GRAD_VAL)   = ( data(index,GRAD_VAL)   + data(match,GRAD_VAL) )/2; 

    %%  Delete 2nd element data                    
        data(match,:)=0; 
    
%% We have more than two repeated primitives    
    else
        
        %% Label: Nothing needs to be done. We will keep the lable of the first primitive.
        
        %%  Values                                                        
            % Average average magnitude value: (index+match)/2
            data(index,AVG_MAG_VAL)   = sum( data(index:index+gradientLblIndex,AVG_MAG_VAL))/gradientLblIndex; 

            % MAX_VAL value: (index+match)/2
            data(index,MAX_VAL)       = max( data(index:index+gradientLblIndex,MAX_VAL) ); 

            % MIN_VAL value: (index+match)/2
            data(index,MIN_VAL)       = min( data(index:index+gradientLblIndex,MIN_VAL) );    

        %%  Time
            % T1_END,index = T2_END,index
            data(index,T1E) = data(index+gradientLblIndex,T1E);

        %% Gradient
            % Average gradient values
            data(index,GRAD_VAL)   = sum( data(index:index+gradientLblIndex,GRAD_VAL))/gradientLblIndex;    

        %%  Delete the 2nd element of data + num of repetitions -1          
            data(match:match+gradientLblIndex-1,:)=0;         
    end
end