%%********************** Documentation ************************************
% Used to compute the amplitude between composites composed of two
% primitives, where the first primitive could be pos/neg/constant/impulse
% and the second one can also be pos/net/constant/impulse. 
% 
% Find the maximum distance between the two extremes. Sometimes this could
% be found in the same primitive. Sometimes one primitive has one extreme
% and the other primitive has the other extreme. (The other alternative is
% to take the extrmeme of each primitive according to sign and compute the
% difference - not used here).
%
% Also return the amplitude of the individual primitives.
% 
% Input Parameters: 
% p1type:   - string. the type of the 1st primitive pos/neg/const/impulse.
% p2type:   - string. the type of the 2nd primitive pos/neg/const/impulse.
% p1maxmin: - [p1max p1min], 1x2 vec that holds max and min vals
% p2maxmin: - [p1max p1min], 1x2 vec that holds max and min vals
%
% Output Parameters:
% amplitude: maximum distance between two primitives. 
% amp1: amplitude of 1st primitive
% amp2: amplitude of 2nd primitive
%**************************************************************************
function [amplitude,amp1,amp2]=computedAmplitude(p1type,p2type,p1maxmin,p2maxmin)

%% Positive p1
    % Pos,Neg
    if(strcmp(p1type,'pos') && strcmp(p2type,'neg'))
       
        %% 1. Compute individual Amplitudes
        % Amplitude 1
        if( p1maxmin(1,1)>=0 && p1maxmin(1,2)>=0 || p1maxmin(1,1)<=0 && p1maxmin(1,2)<=0 )
            amp1 = abs(p1maxmin(1,1))-abs(p1maxmin(1,2));
        else
            amp1 = abs(p1maxmin(1,1))+abs(p1maxmin(1,2));
        end
        
        % Amplitude 2
        if( p2maxmin(1,1)>=0 && p2maxmin(1,2)>=0 || p2maxmin(1,1)<=0 && p2maxmin(1,2)<=0 )
            amp2 = abs(p2maxmin(1,1))-abs(p2maxmin(1,2));
        else
            amp2 = abs(p2maxmin(1,1))+abs(p2maxmin(1,2));
        end
        
        %% 2. Compute overal Amplitude
        % Retrieve p1max,p2min
        high = max([p1maxmin p2maxmin]); low = min([p1maxmin p2maxmin]);
        
        %% Compute amplitude depending on signs
        % If both positive or negative:
        if(high>0 && low>=0 || high<0 && low<0)
            
            % Compute the absolute values
            high=abs(high); low=abs(low);
            amplitude = high - low;
            
        
        % p1=pos,p2=neg or 
        else
            amplitude = high-low;
        end
        
    % Pos,pos
    elseif(strcmp(p1type,'pos') && strcmp(p2type,'pos'))
        
        %% 1. Compute individual Amplitudes
        % Amplitude 1
        if( p1maxmin(1,1)>=0 && p1maxmin(1,2)>=0 || p1maxmin(1,1)<=0 && p1maxmin(1,2)<=0 )
            amp1 = abs(p1maxmin(1,1))-abs(p1maxmin(1,2));
        else
            amp1 = abs(p1maxmin(1,1))+abs(p1maxmin(1,2));
        end
        
        % Amplitude 2
        if( p2maxmin(1,1)>=0 && p2maxmin(1,2)>=0 || p2maxmin(1,1)<=0 && p2maxmin(1,2)<=0 )
            amp2 = abs(p2maxmin(1,1))-abs(p2maxmin(1,2));
        else
            amp2 = abs(p2maxmin(1,1))+abs(p2maxmin(1,2));
        end
        
        %% 2. Compute overal Amplitude

        % Retrieve p1min,p2max
        high = p1maxmin(1,2); low = p2maxmin(1,1);
        
        %% Compute amplitude depending on signs
        % If both positive or negative:
        if(high>0 && low>=0 || high<0 && low<0)
            
            % Compute the absolute values
            high=abs(high); low=abs(low);
            amplitude = low-high;
        
        % p1=neg,p2=pos or 
        else
            amplitude = low-high;
        end        
    
    % pos,const
    elseif(strcmp(p1type,'pos') && strcmp(p2type,'const'))
        
        %% 1. Compute individual Amplitudes
        % Amplitude 1
        if( p1maxmin(1,1)>=0 && p1maxmin(1,2)>=0 || p1maxmin(1,1)<=0 && p1maxmin(1,2)<=0 )
            amp1 = abs(p1maxmin(1,1))-abs(p1maxmin(1,2));
        else
            amp1 = abs(p1maxmin(1,1))+abs(p1maxmin(1,2));
        end
        
        % Amplitude 2
        if( p2maxmin(1,1)>=0 && p2maxmin(1,2)>=0 || p2maxmin(1,1)<=0 && p2maxmin(1,2)<=0 )
            amp2 = abs(p2maxmin(1,1))-abs(p2maxmin(1,2));
        else
            amp2 = abs(p2maxmin(1,1))+abs(p2maxmin(1,2));
        end
        
        %% 2. Compute overal Amplitude        
        % Retrieve p1min,p2max
        high = p1maxmin(1,2); low = p2maxmin(1,1);
        
        %% Compute amplitude depending on signs
        % If both positive or negative:
        if(high>0 && low>=0 || high<0 && low<0)
            
            % Compute the absolute values
            high=abs(high); low=abs(low);
            amplitude = low-high;
        
        % p1=neg,p2=pos or 
        else
            amplitude = low-high;
        end

    % pos,impulse
    elseif(strcmp(p1type,'pos') && strcmp(p2type,'impulse'))
        
        %% 1. Compute individual Amplitudes
        % Amplitude 1
        if( p1maxmin(1,1)>=0 && p1maxmin(1,2)>=0 || p1maxmin(1,1)<=0 && p1maxmin(1,2)<=0 )
            amp1 = abs(p1maxmin(1,1))-abs(p1maxmin(1,2));
        else
            amp1 = abs(p1maxmin(1,1))+abs(p1maxmin(1,2));
        end
        
        % Amplitude 2
        if( p2maxmin(1,1)>=0 && p2maxmin(1,2)>=0 || p2maxmin(1,1)<=0 && p2maxmin(1,2)<=0 )
            amp2 = abs(p2maxmin(1,1))-abs(p2maxmin(1,2));
        else
            amp2 = abs(p2maxmin(1,1))+abs(p2maxmin(1,2));
        end
        
        %% 2. Compute overal Amplitude        
        % Retrieve p1min,p2max
        high = p1maxmin(1,2); low = p2maxmin(1,1);
        
        %% Compute amplitude depending on signs
        % If both positive or negative:
        if(high>0 && low>=0 || high<0 && low<0)
            
            % Compute the absolute values
            high=abs(high); low=abs(low);
            amplitude = low-high;
        
        % p1=neg,p2=pos or 
        else
            amplitude = low-high;
        end                      
    
%% Negative p1
    
    % neg,pos
    elseif(strcmp(p1type,'neg') && strcmp(p2type,'pos'))
        
        %% 1. Compute individual Amplitudes
        % Amplitude 1
        if( p1maxmin(1,1)>=0 && p1maxmin(1,2)>=0 || p1maxmin(1,1)<=0 && p1maxmin(1,2)<=0 )
            amp1 = abs(p1maxmin(1,1))-abs(p1maxmin(1,2));
        else
            amp1 = abs(p1maxmin(1,1))+abs(p1maxmin(1,2));
        end
        
        % Amplitude 2
        if( p2maxmin(1,1)>=0 && p2maxmin(1,2)>=0 || p2maxmin(1,1)<=0 && p2maxmin(1,2)<=0 )
            amp2 = abs(p2maxmin(1,1))-abs(p2maxmin(1,2));
        else
            amp2 = abs(p2maxmin(1,1))+abs(p2maxmin(1,2));
        end
        
        %% 2. Compute overal Amplitude        
        % Retrieve p1min,p2max
        high = p1maxmin(1,2); low = p2maxmin(1,1);
        
        %% Compute amplitude depending on signs
        % If both positive or negative:
        if(high>0 && low>=0)            
            amplitude = low-high;
        
        % If both negative
        elseif(high<0 && low<0)
            % Compute the absolute values
            high=abs(high); low=abs(low);
            amplitude = high-low;
            
        % p1=neg,p2=pos or 
        else
            amplitude = low-high;
        end        
            
    % Neg,neg
    elseif(strcmp(p1type,'neg') && strcmp(p2type,'neg'))
        
        %% 1. Compute individual Amplitudes
        % Amplitude 1
        if( p1maxmin(1,1)>=0 && p1maxmin(1,2)>=0 || p1maxmin(1,1)<=0 && p1maxmin(1,2)<=0 )
            amp1 = abs(p1maxmin(1,1))-abs(p1maxmin(1,2));
        else
            amp1 = abs(p1maxmin(1,1))+abs(p1maxmin(1,2));
        end
        
        % Amplitude 2
        if( p2maxmin(1,1)>=0 && p2maxmin(1,2)>=0 || p2maxmin(1,1)<=0 && p2maxmin(1,2)<=0 )
            amp2 = abs(p2maxmin(1,1))-abs(p2maxmin(1,2));
        else
            amp2 = abs(p2maxmin(1,1))+abs(p2maxmin(1,2));
        end
        
        %% 2. Compute overal Amplitude        
        % Retrieve p1max,p2min
        high = max([p1maxmin p2maxmin]); low = min([p1maxmin p2maxmin]);
        
        %% Compute amplitude depending on signs
        % If both positive or p1=pos,p2=neg:
        if(high>0 && low>=0 || high>0 && low<0)           
            amplitude = high-low;
        
        % If both neg 
        else
            amplitude = abs(low)-abs(high);
        end        
              
    % Neg,const
    elseif(strcmp(p1type,'neg') && strcmp(p2type,'const'))

        %% 1. Compute individual Amplitudes
        % Amplitude 1
        if( p1maxmin(1,1)>=0 && p1maxmin(1,2)>=0 || p1maxmin(1,1)<=0 && p1maxmin(1,2)<=0 )
            amp1 = abs(p1maxmin(1,1))-abs(p1maxmin(1,2));
        else
            amp1 = abs(p1maxmin(1,1))+abs(p1maxmin(1,2));
        end
        
        % Amplitude 2
        if( p2maxmin(1,1)>=0 && p2maxmin(1,2)>=0 || p2maxmin(1,1)<=0 && p2maxmin(1,2)<=0 )
            amp2 = abs(p2maxmin(1,1))-abs(p2maxmin(1,2));
        else
            amp2 = abs(p2maxmin(1,1))+abs(p2maxmin(1,2));
        end
        
        %% 2. Compute overal Amplitude        
        % Retrieve p1max,p2min
        high = max([p1maxmin p2maxmin]); low = min([p1maxmin p2maxmin]);
        
        %% Compute amplitude depending on signs
        % If both positive or p1=pos,p2=neg:
        if(high>0 && low>=0 || high>0 && low<0)           
            amplitude = high-low;
        
        % If both neg 
        else
            amplitude = abs(low)-abs(high);
        end 
        
%% Neg,impulse 
    elseif(strcmp(p1type,'neg') && strcmp(p2type,'impulse'))
        
        %% 1. Compute individual Amplitudes
        % Amplitude 1
        if( p1maxmin(1,1)>=0 && p1maxmin(1,2)>=0 || p1maxmin(1,1)<=0 && p1maxmin(1,2)<=0 )
            amp1 = abs(p1maxmin(1,1))-abs(p1maxmin(1,2));
        else
            amp1 = abs(p1maxmin(1,1))+abs(p1maxmin(1,2));
        end
        
        % Amplitude 2
        if( p2maxmin(1,1)>=0 && p2maxmin(1,2)>=0 || p2maxmin(1,1)<=0 && p2maxmin(1,2)<=0 )
            amp2 = abs(p2maxmin(1,1))-abs(p2maxmin(1,2));
        else
            amp2 = abs(p2maxmin(1,1))+abs(p2maxmin(1,2));
        end
        
        %% 2. Compute overal Amplitude        
        % Retrieve p1max,p2min
        high = max([p1maxmin p2maxmin]); low = min([p1maxmin p2maxmin]);
        
        %% Compute amplitude depending on signs
        % If both positive or p1=pos,p2=neg:
        if(high>0 && low>=0 || high>0 && low<0)           
            amplitude = high-low;
        
        % If both neg 
        else
            amplitude = abs(low)-abs(high);
        end        

%% Constant p1
    % const p1 followed by a pos p2
    elseif(strcmp(p1type,'const') && strcmp(p2type,'pos'))
    
        %% 1. Compute individual Amplitudes
        % Amplitude 1
        if( p1maxmin(1,1)>=0 && p1maxmin(1,2)>=0 || p1maxmin(1,1)<=0 && p1maxmin(1,2)<=0 )
            amp1 = abs(p1maxmin(1,1))-abs(p1maxmin(1,2));
        else
            amp1 = abs(p1maxmin(1,1))+abs(p1maxmin(1,2));
        end
        
        % Amplitude 2
        if( p2maxmin(1,1)>=0 && p2maxmin(1,2)>=0 || p2maxmin(1,1)<=0 && p2maxmin(1,2)<=0 )
            amp2 = abs(p2maxmin(1,1))-abs(p2maxmin(1,2));
        else
            amp2 = abs(p2maxmin(1,1))+abs(p2maxmin(1,2));
        end
        
        %% 2. Compute overal Amplitude        
        % Retrieve p1min,p2max
        high = p1maxmin(1,2); low = p2maxmin(1,1);
        
        %% Compute amplitude depending on signs
        % If both positive or negative:
        if(high>0 && low>=0 || high<0 && low<0)
            
            % Compute the absolute values
            high=abs(high); low=abs(low);
            amplitude = low-high;
        
        % p1=min,p2=pos  
        else
            amplitude = low-high;
        end

    %% const followed by a neg
    elseif(strcmp(p1type,'const') && strcmp(p2type,'neg'))

        %% 1. Compute individual Amplitudes
        % Amplitude 1
        if( p1maxmin(1,1)>=0 && p1maxmin(1,2)>=0 || p1maxmin(1,1)<=0 && p1maxmin(1,2)<=0 )
            amp1 = abs(p1maxmin(1,1))-abs(p1maxmin(1,2));
        else
            amp1 = abs(p1maxmin(1,1))+abs(p1maxmin(1,2));
        end
        
        % Amplitude 2
        if( p2maxmin(1,1)>=0 && p2maxmin(1,2)>=0 || p2maxmin(1,1)<=0 && p2maxmin(1,2)<=0 )
            amp2 = abs(p2maxmin(1,1))-abs(p2maxmin(1,2));
        else
            amp2 = abs(p2maxmin(1,1))+abs(p2maxmin(1,2));
        end
        
        %% 2. Compute overal Amplitude        
        % Retrieve p1max,p2min
        high = max([p1maxmin p2maxmin]); low = min([p1maxmin p2maxmin]);
        
        %% Compute amplitude depending on signs
        % If both positive or negative:
        if(high<0 && low<0)
            
            % Compute the absolute values
            amplitude = abs(low)-abs(high);            
        
        % p1>0,p2>0 or p1>0,p2<0
        else
            amplitude = high-low;
        end
    %else const, const. amplitude = 0. covered in the 'else' case. 

%% Impulse p1
    elseif(strcmp(p1type,'impulse') && strcmp(p2type,'pos'))
        
        %% 1. Compute individual Amplitudes
        % Amplitude 1
        if( p1maxmin(1,1)>=0 && p1maxmin(1,2)>=0 || p1maxmin(1,1)<=0 && p1maxmin(1,2)<=0 )
            amp1 = abs(p1maxmin(1,1))-abs(p1maxmin(1,2));
        else
            amp1 = abs(p1maxmin(1,1))+abs(p1maxmin(1,2));
        end
        
        % Amplitude 2
        if( p2maxmin(1,1)>=0 && p2maxmin(1,2)>=0 || p2maxmin(1,1)<=0 && p2maxmin(1,2)<=0 )
            amp2 = abs(p2maxmin(1,1))-abs(p2maxmin(1,2));
        else
            amp2 = abs(p2maxmin(1,1))+abs(p2maxmin(1,2));
        end
        
        %% 2. Compute overal Amplitude        
        
        %% Check to see which is greater p1max or p2max
        % p1max is greater
        if(p1maxmin(1,1) > p2maxmin(1,1))
            
            % p1max,p2max
            high = p1maxmin(1,1); low = p2maxmin(1,1);

            %% Compute amplitude depending on signs
            % If both positive or p1 is pos and p2 is neg:
            if(high>0 && low>=0 || high>0 && low<0)
                amplitude = high - low;
            
            % If both neg 
            else
                amplitude = abs(low)-abs(high);
            end
            
        % p2max is greater
        else
            high = p1maxmin(1,1); low = p2maxmin(1,1);

            %% Compute amplitude depending on signs
            % If both positive or p1 is neg and p2 is pos:
            if(high>0 && low>=0 || high<0 && low>0)
                amplitude = low-high;
            
            % Ig both neg
            else
                amplitude = abs(low)-abs(high);
            end            
        end
        
    % impulse,neg
    elseif(strcmp(p1type,'impulse') && strcmp(p2type,'neg'))
        
        %% 1. Compute individual Amplitudes
        % Amplitude 1
        if( p1maxmin(1,1)>=0 && p1maxmin(1,2)>=0 || p1maxmin(1,1)<=0 && p1maxmin(1,2)<=0 )
            amp1 = abs(p1maxmin(1,1))-abs(p1maxmin(1,2));
        else
            amp1 = abs(p1maxmin(1,1))+abs(p1maxmin(1,2));
        end
        
        % Amplitude 2
        if( p2maxmin(1,1)>=0 && p2maxmin(1,2)>=0 || p2maxmin(1,1)<=0 && p2maxmin(1,2)<=0 )
            amp2 = abs(p2maxmin(1,1))-abs(p2maxmin(1,2));
        else
            amp2 = abs(p2maxmin(1,1))+abs(p2maxmin(1,2));
        end
        
        %% 2. Compute overal Amplitude        
        %% Check to see which is greater p1max or p2max
        % p1max is greater
        if(p1maxmin(1,1) > p2maxmin(1,1))
            
            % p1max,p2min
            high = max([p1maxmin p2maxmin]); low = min([p1maxmin p2maxmin]);

            %% Compute amplitude depending on signs
            % If both positive or p1 is pos and p2 is neg:
            if(high>0 && low>=0 || high>0 && low<0)
                amplitude = high - low;
            
            % If both neg 
            else
                amplitude = abs(low)-abs(high);
            end
            
        % p2max is greater
        else
            %p1max,p2min
            high = max([p1maxmin p2maxmin]); low = min([p1maxmin p2maxmin]);

            %% Compute amplitude depending on signs
            % If both positive or p1 is neg and p2 is pos:
            if(high>0 && low>=0 || high<0 && low>0)
                amplitude = low-high;
            
            % Ig both neg
            else
                amplitude = abs(high)-abs(low);
            end            
        end
        
    else % i.e. (const,const) or (const,impulse)
 %% 1. Compute individual Amplitudes
        % Amplitude 1
        if( p1maxmin(1,1)>=0 && p1maxmin(1,2)>=0 || p1maxmin(1,1)<=0 && p1maxmin(1,2)<=0 )
            amp1 = abs(p1maxmin(1,1))-abs(p1maxmin(1,2));
        else
            amp1 = abs(p1maxmin(1,1))+abs(p1maxmin(1,2));
        end
        
        % Amplitude 2
        if( p2maxmin(1,1)>=0 && p2maxmin(1,2)>=0 || p2maxmin(1,1)<=0 && p2maxmin(1,2)<=0 )
            amp2 = abs(p2maxmin(1,1))-abs(p2maxmin(1,2));
        else
            amp2 = abs(p2maxmin(1,1))+abs(p2maxmin(1,2));
        end
        
        %% 2. Compute overal Amplitude
        % Retrieve p1max,p2min
        high = max([p1maxmin p2maxmin]); low = min([p1maxmin p2maxmin]);
        
        %% Compute amplitude depending on signs
        % If both positive or negative:
        if(high>0 && low>=0 || high<0 && low<0)
            
            % Compute the absolute values
            high=abs(high); low=abs(low);
            amplitude = high - low;
            
        
        % p1=pos,p2=neg or 
        else
            amplitude = high-low;
        end     
    end
    
    % Make sure to return a scalar value. Take the absolute value.
    amplitude = abs(amplitude); 
    amp1=abs(amp1); 
    amp2=abs(amp2);
end