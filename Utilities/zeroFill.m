%*************************** Documentation *******************************
% zeroFill is a function that takes either a motionComposition structure: mx11x6
% or a low-level behavior struc: mx17x6. 
% Because the size of the rows for each array is different we have to pad with zeros. 
% The function will get the size of the larges array and use that to fill with zeros the
% rest of the arrays.
%
%--------------------------------------------------------------------------
% For Reference: Structures and Labels
%--------------------------------------------------------------------------
% Primitives = [bpos,mpos,spos,bneg,mneg,sneg,cons,pimp,nimp,none]      % Represented by integers: [1,2,3,4,5,6,7,8,9,10]  
% statData   = [dAvg dMax dMin dStart dFinish dGradient dLabel]
%--------------------------------------------------------------------------
% actionLbl  = ['a','i','d','k','pc','nc','c','u','n','z'];             % Represented by integers: [1,2,3,4,5,6,7,8,9,10]  
% motComps   = [nameLabel,avgVal,rmsVal,amplitudeVal,
%               p1lbl,p2lbl,
%               t1Start,t1End,t2Start,t2End,tAvgIndex]
%--------------------------------------------------------------------------
% llbehLbl   = ['FX' 'CT' 'PS' 'PL' 'AL' 'SH' 'U' 'N'];                 % Represented by integers: [1,2,3,4,5,6,7,8]
% llbehStruc:  [actnClass,...
%              avgMagVal1,avgMagVal2,AVG_MAG_VAL,
%              rmsVal1,rmsVal2,AVG_RMS_VAL,
%              ampVal1,ampVal2,AVG_AMP_VAL,
%              mc1,mc2,
%              T1S,T1_END,T2S,T2E,TAVG_INDEX]
%--------------------------------------------------------------------------
%
% Inputs:
% llbehFx-llbehMz: mx17 structures that contains all the fields of
% information generated in the pRCBHT 4th layer: Low-Level Behavior
% implementaiton. 
% dataTypeFlag      - indicates whether we are working with motion
%                     compositions (value 2) or low-level beahviors (value
%                     3).
%
% Outputs:
% dataFM:   According to data type will be a motCompsFM (mx11x6) or an llbehFM(mx17x6)
% numElems: returns the last row that contians non-zero entrries for each
% of the siz structures.
%**************************************************************************
function [dataFM,numElems] = zeroFill(Fx,Fy,Fz,Mx,My,Mz,dataTypeFlag)

    %% Local Variables
    
    % Type of data
    MCs = 2; 
    LLBs = 3;
    
    % Dimensions
    NumAxis=6;
    NumMCElems=11;
    NumLLBElems=17;
    
    if(dataTypeFlag==MCs)
        % Create numElems column vector and rowPadding column vector
        numElems = zeros(1,6);
        rowPadding = zeros(1,6);

        % Retrieve the size
        [numElems(1,1),~] = size(Fx);
        [numElems(1,2),~] = size(Fy);
        [numElems(1,3),~] = size(Fz);
        [numElems(1,4),~] = size(Mx);
        [numElems(1,5),~] = size(My);
        [numElems(1,6),~] = size(Mz);

        % Find maximum value for number of rows
        maxRowNum = max(numElems);

        %% Perform Padding

        % Find the difference between max value and numElems
        for i=1:6

            % How many rows need padding
            rowPadding(1,i) = maxRowNum - numElems(i);

            % Fill
            if(i==1)
                Fx(end+1:end+rowPadding(1,i),:) = -99*ones(rowPadding(1,i),NumMCElems);
            elseif(i==2)
                Fy(end+1:end+rowPadding(1,i),:) = -99*ones(rowPadding(1,i),NumMCElems);
            elseif(i==3)
                Fz(end+1:end+rowPadding(1,i),:) = -99*ones(rowPadding(1,i),NumMCElems);
            elseif(i==4)
                Mx(end+1:end+rowPadding(1,i),:) = -99*ones(rowPadding(1,i),NumMCElems);
            elseif(i==5)
                My(end+1:end+rowPadding(1,i),:) = -99*ones(rowPadding(1,i),NumMCElems);
            elseif(i==6)
                Mz(end+1:end+rowPadding(1,i),:) = -99*ones(rowPadding(1,i),NumMCElems);            
            end
        end

        % Compound the structures into a 3D array.
        dataFM = zeros(maxRowNum,NumMCElems,NumAxis);
        dataFM(:,:,1) = Fx;
        dataFM(:,:,2) = Fy;
        dataFM(:,:,3) = Fz;
        dataFM(:,:,4) = Mx;
        dataFM(:,:,5) = My;
        dataFM(:,:,6) = Mz;        
        
    elseif(dataTypeFlag==LLBs)
        % Create numElems column vector and rowPadding column vector
        numElems = zeros(1,6);
        rowPadding = zeros(1,6);

        % Retrieve the size
        [numElems(1,1),~] = size(Fx);
        [numElems(1,2),~] = size(Fy);
        [numElems(1,3),~] = size(Fz);
        [numElems(1,4),~] = size(Mx);
        [numElems(1,5),~] = size(My);
        [numElems(1,6),~] = size(Mz);

        % Find maximum value for number of rows
        maxRowNum = max(numElems);

        %% Perform Padding

        % Find the difference between max value and numElems
        for i=1:6

            % How many rows need padding
            rowPadding(1,i) = maxRowNum - numElems(i);

            % Fill
            if(i==1)
                Fx(end+1:end+rowPadding(1,i),:) = -99*ones(rowPadding(1,i),NumLLBElems);
            elseif(i==2)
                Fy(end+1:end+rowPadding(1,i),:) = -99*ones(rowPadding(1,i),NumLLBElems);
            elseif(i==3)
                Fz(end+1:end+rowPadding(1,i),:) = -99*ones(rowPadding(1,i),NumLLBElems);
            elseif(i==4)
                Mx(end+1:end+rowPadding(1,i),:) = -99*ones(rowPadding(1,i),NumLLBElems);
            elseif(i==5)
                My(end+1:end+rowPadding(1,i),:) = -99*ones(rowPadding(1,i),NumLLBElems);
            elseif(i==6)
                Mz(end+1:end+rowPadding(1,i),:) = -99*ones(rowPadding(1,i),NumLLBElems);            
            end
        end

        % Compound the structures into a 3D array.
        dataFM = zeros(maxRowNum,NumLLBElems,NumAxis);
        dataFM(:,:,1) = Fx;
        dataFM(:,:,2) = Fy;
        dataFM(:,:,3) = Fz;
        dataFM(:,:,4) = Mx;
        dataFM(:,:,5) = My;
        dataFM(:,:,6) = Mz;
    else
        dataFM=-1;
    end
end