% 1. Rotation States
            % 1.1 - Only Rotation
            if(LLB(i,tEnd)<stateTimes(EndMating,1)) % End of Rotation time 
                % 1.2 - Rotation and Snap
                if(LLB(i,tEnd)<stateTimes(EndSnap,1)) % End of Snap time
                    % 1.3 - Rotation and Snap and Mating
                    if(LLB(i,tEnd)<stateTimes(EndRot,1)) % End of Mating time                        

                        % 1.3.1 - ROTATION
                        % If the LLB ends after the end of the Rotation state, trunk at the end.
                        if(LLB(i,tEnd)>stateTimes(EndRot,1))
                            EndTime = stateTimes(EndRot,1);
                        else
                            EndTime = LLB(i,tEnd);
                        end

                        % If the LLB starts before the start of the Rotation state, trunk at the beginning
                        if(LLB(i,tStart)<stateTimes(EndApproach,1))
                            StartTime = stateTimes(EndApproach,1);
                        else
                            StartTime = LLB(i,tStart);
                        end
                        %-------------------------------------------------------------------------------------------------------------------------------------
                        llbRot(i,1,axes) = LLB(i,1);            % Tag
                        llbRot(i,2,axes) = StartTime;           % Starting time - trunked if necessary
                        llbRot(i,3,axes) = EndTime;             % Ending time   - truned if necessary
                        llbRot(i,4,axes) = EndTime-StartTime;   % Duration
                        %-------------------------------------------------------------------------------------------------------------------------------------

                        % 1.3.2 - SNAP
                        % If the LLB ends after the end of the Snap state, trunk at the end.
                        if(LLB(i,tEnd)>stateTimes(EndSnap,1))
                            EndTime = stateTimes(EndSnap,1);
                        else
                            EndTime = LLB(i,tEnd);
                        end

                        % If the LLB starts before the start of the Snap state, trunk at the beginning
                        if(LLB(i,tStart)<stateTimes(EndRot,1))
                            StartTime = stateTimes(EndRot,1);
                        else
                            StartTime = LLB(i,tStart);
                        end         
                        %-------------------------------------------------------------------------------------------------------------------------------------
                        llbSnap(i,1,axes) = LLB(i,1);   llbSnap(i,2,axes) = EndTime-StartTime; % i.e. duration = the end of the rotation state - where it started
                        %-------------------------------------------------------------------------------------------------------------------------------------

                        % 1.3.3 - Mating
                        % Set end time regardless
                        EndTime = LLB(i,tEnd);

                        % If the LLB starts before the start of the Mating state, trunk at the beginning
                        if(LLB(i,tStart)<stateTimes(EndSnap,1))
                            StartTime = stateTimes(EndSnap,1);
                        else
                            StartTime = LLB(i,tStart);
                        end     
                        %-------------------------------------------------------------------------------------------------------------------------------------
                        llbMat(i,1,axes) = LLB(i,1);   llbMat(i,2,axes) = EndTime-StartTime; % i.e. duration = the end of the rotation state - where it started                    
                        %-------------------------------------------------------------------------------------------------------------------------------------
                    end               

                    %1.2 - Crosses Rotation and Snap states                
                    % 1.2.1 - ROTATION
                    % If the LLB ends after the end of the Rotation state, trunk at the end.
                    if(LLB(i,tEnd)>stateTimes(EndRot,1))
                        EndTime = stateTimes(EndRot,1);
                    else
                        EndTime = LLB(i,tEnd);
                    end

                    % If the LLB starts before the start of the Rotation state, trunk at the beginning
                    if(LLB(i,tStart)<stateTimes(EndApproach,1))
                        StartTime = stateTimes(EndApproach,1);
                    else
                        StartTime = LLB(i,tStart);
                    end
                    %-------------------------------------------------------------------------------------------------------------------------------------
                    llbRot(i,1,axes) = LLB(i,1);   llbRot(i,2,axes) = EndTime-StartTime;    % i.e. duration = the end of the rotation state - where it started
                    %-------------------------------------------------------------------------------------------------------------------------------------

                    % 1.2.2 - SNAP
                    % Set end time regardless
                    EndTime = LLB(i,tEnd);

                    % If the LLB starts before the start of the Snap state, trunk at the beginning
                    if(LLB(i,tStart)<stateTimes(EndRot,1))
                        StartTime = stateTimes(EndRot,1);
                    else
                        StartTime = LLB(i,tStart);
                    end         
                    %-------------------------------------------------------------------------------------------------------------------------------------
                    llbSnap(i,1,axes) = LLB(i,1);   llbSnap(i,2,axes) = EndTime-StartTime; % i.e. duration = the end of the rotation state - where it started
                    %-------------------------------------------------------------------------------------------------------------------------------------                    
                end

                % 1.1.1 - ROTATION
                % Set end time regardless
                EndTime = LLB(i,tEnd);

                % If the LLB starts before the start of the Rotation state, trunk at the beginning
                if(LLB(i,tStart)<stateTimes(EndApproach,1))
                    StartTime = stateTimes(EndApproach,1);
                else
                    StartTime = LLB(i,tStart);
                end         
                %-------------------------------------------------------------------------------------------------------------------------------------
                llbRot(i,1,axes) = LLB(i,1);   llbRot(i,2,axes) = EndTime-StartTime; % i.e. duration = the end of the rotation state - where it started
                %-------------------------------------------------------------------------------------------------------------------------------------
            end % End of Rotation States 
            
            % 2. Snap States
            % 2.1 - Snap
             if(LLB(i,tEnd)<stateTimes(EndSnap,1)) % End of Snap time
                    % 2.2 - Snap and Mating
                    if(LLB(i,tEnd)<stateTimes(EndMating,1)) % End of Mating time

                        % Copy tag and duration across rotation, snap, and mating respectively.

                        % 2.2.1 - SNAP
                        % If the LLB ends after the end of the Snap state, trunk at the end.
                        if(LLB(i,tEnd)>stateTimes(EndSnap,1))
                            EndTime = stateTimes(EndSnap,1);
                        else
                            EndTime = LLB(i,tEnd);
                        end

                        % If the LLB starts before the start of the Snap state, trunk at the beginning
                        if(LLB(i,tStart)<stateTimes(EndRot,1))
                            StartTime = stateTimes(EndRot,1);
                        else
                            StartTime = LLB(i,tStart);
                        end         
                        %-------------------------------------------------------------------------------------------------------------------------------------
                        llbSnap(i,1,axes) = LLB(i,1);   llbSnap(i,2,axes) = EndTime-StartTime; % i.e. duration = the end of the rotation state - where it started
                        %-------------------------------------------------------------------------------------------------------------------------------------

                        % 2.2.2 - Mating
                        % Set end time regardless
                        EndTime = LLB(i,tEnd);

                        % If the LLB starts before the start of the Mating state, trunk at the beginning
                        if(LLB(i,tStart)<stateTimes(EndSnap,1))
                            StartTime = stateTimes(EndSnap,1);
                        else
                            StartTime = LLB(i,tStart);
                        end     
                        %-------------------------------------------------------------------------------------------------------------------------------------
                        llbMat(i,1,axes) = LLB(i,1);   llbMat(i,2,axes) = EndTime-StartTime; % i.e. duration = the end of the rotation state - where it started                    
                        %-------------------------------------------------------------------------------------------------------------------------------------                    
                    end               

                % 2.1 - Does not cross Snap state             
                % 2.1.1 - SNAP

                % Set end time regardless
                EndTime = LLB(i,tEnd);

                % If the LLB starts before the start of the Snap state, trunk at the beginning
                if(LLB(i,tStart)<stateTimes(EndRot,1))
                    StartTime = stateTimes(EndRot,1);
                else
                    StartTime = LLB(i,tStart);
                end         
                %-------------------------------------------------------------------------------------------------------------------------------------
                llbSnap(i,1,axes) = LLB(i,1);   llbSnap(i,2,axes) = EndTime-StartTime; % i.e. duration = the end of the rotation state - where it started
                %-------------------------------------------------------------------------------------------------------------------------------------                    
             end
        
            
            % 3. Mating States
            % 3.1 - Mating
                    
            % Set end time regardless
            EndTime = LLB(i,tEnd);

            % If the LLB starts before the start of the Mating state, trunk at the beginning
            if(LLB(i,tStart)<stateTimes(EndSnap,1))
                StartTime = stateTimes(EndSnap,1);
            else
                StartTime = LLB(i,tStart);
            end         
            %-------------------------------------------------------------------------------------------------------------------------------------
            llbSnap(i,1,axes) = LLB(i,1);   llbSnap(i,2,axes) = EndTime-StartTime; % i.e. duration = the end of the rotation state - where it started
            %-------------------------------------------------------------------------------------------------------------------------------------                                    
            
        end
        
        % Clear memory
        clear LLB;
    end