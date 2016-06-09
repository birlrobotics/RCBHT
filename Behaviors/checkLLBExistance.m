% checkLLBExistance
% This function is a function designed to check whether or not 
% the LLBs passed into the function for a given automata state (through the 
% structure stateLLBstruc) actually exist or not. This will help us to verify
% conditions. 
%
% Conditions could be used to verify whether a task is successful or
% whether an anomaly is present in case of malformed assemblies.
%
% Note:
% 
% Assumes that a structure is created as follows:
%   str.Fx=FIX      // FIX is of type int = 1
%   str.Fy=[]       // empty
%   str.Fz=ALGN     // ALGN 
% Another external function will be needed to iterative through: (a)
% different automata states, and (b) different conditions one wants to
% check, whether successful or anomalous.
%
% Inputs: 
%
% stateLbl:         this is a multidimensional array (4xmx6). That is 4
%                   automata states (Approach, Rotation, Insertion, Mating), in all 6 axis, with an unknown
%                   number of labels. In fact, m is determined by the largest number of
%                   labels across all 4 states. This implies that mean elements in the array
%                   will be padded with zeros.
% whichState:       indicates what state we are working with.
% llbehLbl:         Array that contains the stringed list of standard low-level behaviors.
% stateLLBstruc:    This is a 'struc' that contains: {field1,test1,...,fieldn,testn}. 
%                   The field(s) is the axis we want to test; the value(s) is the 
%                   LLB labels that we want to check.
%                   These LLB labels will be represented by integers to ease conversion in
%                   matlab coder.
%
% Output
%
% llbIsInAxis:      Indicates if the desired LLBs are actually found in
%                   their corresponding axes
function llbIsInAxis = checkLLBExistance( stateLbl, whichState, llbehLbl, stateLLBstruc)


%% Local Variables
    llbIsInAxis = 1;
    %Fx=1;Fy=2;Fz=3;Mx=4;My=5;Mz=6;
    % state2=2; state3=3; state4=4; % Rotation, Insertion, and Mating.

%   Labels for low-level behaviors (see hlbCompositions_new.m)
% 	FIX     = 1;        % Fixed in place
%   CONTACT = 2;        % Contact
%   PUSH    = 3;        % Push
%   PULL    = 4;        % Pull
%   ALIGN   = 5;        % Alignment
%   SHIFT   = 6;        % Shift
%   UNSTABLE= 7;        % Unstable
%   NOISE   = 8;        % Noise
%   llbehLbl    = {'FX' 'CT' 'PS' 'PL' 'AL' 'SH' 'U' 'N'}; % {'fix' 'cont' 'push' 'pull' 'align' 'shift' 'unstable' 'noise'};

%% Extract Size and Contents
    
    % To get the size of the structure, we need to use structfun which is
    % also compatible with online coder. Use numelem as a handle function
    % for the structure.
    sz=structfun(@numel,stateLLBstruc);
    
    % To know what label to use, we will analyse 'sz' find out which of the
    % six entries has 0 or non-zeros. Non-zero entries are equivalent to
    % Fx...Mz. This structure will always contain 6 rows. Some 0 some not.
    for axisIndex=1:6

        % Based on the size, we will want to iterate and discern the function
        if(sz(axisIndex))

            %% Extract the field value, the label(s)
            if(sz(axisIndex)==1) % I.e. there is only one label, extract it

                axis=num2axis(axisIndex);                                   % Converts the int to a string
                llbLabel = stateLLBstruc.(axis);                            % Use the dynamic field reference to refer to the appropriate axis and extract the LLB label(s)

                % Find where the first 0 entry for the labels is.
                [minVal,minIndex]=min(stateLbl(whichState,:,axisIndex),[],2); 
                tempLbl = stateLbl(whichState,1:minIndex-1,axisIndex);      % Copy the non-zero labels.

                %% Look for conditions   
                len=length(tempLbl);                                        % Get the real lenght of existing labels
                res=zeros(1,len);                                           % Create a results vector of the same size. It will be filled with one's or zero's, depending if the entries match the desired LLB.

                for lblIndex=1:len
                    res(1,lblIndex)=intcmp(tempLbl(1,lblIndex),llbehLbl(llbLabel));
                end;

                % Do an AND operation, such that if at any time, the sum is zero, it will tell that not all of the desired LLBs are in the corresponding axes
                llbIsInAxis = llbIsInAxis && sum(res);           

            % If there are two labels. TODO: could make it more generalizable by creatinga  vector of labels.
            else 
                axis=num2axis(axisIndex);                                   % The index will tell what axis we are in
                llbLabel = stateLLBstruc.(axis);                            % See http://blogs.mathworks.com/loren/2005/12/13/use-dynamic-field-references/
                label1 = llbLabel(1,1);                                     % Int's representing what low-level behavior is desired
                label2 = llbLabel(1,2);

                [minVal,minIndex]=min(stateLbl(whichState,:,axisIndex),[],2); 
                tempLbl = stateLbl(whichState,1:minIndex-1,axisIndex);    

                %% Look for conditions   
                len=length(tempLbl);
                res=zeros(1,len);

                for lblIndex=1:len
                     res(1,lblIndex) = ( (intcmp(tempLbl(1,lblIndex),llbehLbl(label1))) || (intcmp(tempLbl(1,lblIndex),llbehLbl(label2))) );
                end;

                % Do an AND operation, such that if at any time, the sum is zero, it will tell that not all of the desired LLBs are in the corresponding axes
                llbIsInAxis = llbIsInAxis && sum(res);
            end
        end
    end
end

