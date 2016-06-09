%% KeyLLBLookUp
% This function returns a string LLB tag ('FX' or 'CT' or 'PS' or 'PL' or
% 'SH' or 'AL'or 'ALFX') the last term is union of two AL and FX.
% Their selection depends on what Higher-level state we are looking for. 
%
% Currently we just compute successful states like: 
% - 'Rotation', 
% - 'Snaping',
% - 'Mating'.
%
% Inputs:
% HLB_State          - String in the form 
% llbStruc          - this is a (n x 4) structure continaing:
%                     {'llbtag' StartingTime EndingTime Duration}
% HLB_State string  - one of the tree mentioned above.
%
% Outputs:
% currLLB            - an LLB encoded as an integer according to the LLB
%                     struc. The result is used the in the system model as part of the
%                     prediction stage of the bayes filtering computation.
% prevLLB            - 
%%
function currLLB = KeyLLBLookUp(HLB_State,Axes)

%% Policies according to HLB state for a given axes
%   ROT     = ['FX';     'NA';    'FX';    'NA';    'FX';    'NA'];
    ROT     = ['NA';     'NA';    'FX';    'NA';    'FX';    'NA']; % seems like Fx changes too much
    SNAP    = ['CT';     'AF';    'AF';    'AF';    'CT';    'AF'];
    %MAT     = ['FX';     'FX';    'FX';    'FX';    'FX';    'FX'];
    MAT     = ['AF';     'AF';    'AF';    'AF';    'AF';    'AF'];
    
    % Retun for rotation
	if(strcmp(HLB_State,'ROT'))
        currLLB= ROT(Axes,:);
        
    elseif(strcmp(HLB_State,'SNP'))
        currLLB= SNAP(Axes,:);       
        
    elseif(strcmp(HLB_State,'MAT'))
        currLLB= MAT(Axes,:);      
    else
        currLLB = '';
    end
        
%% Convert string into into integer
    currLLB = convertLLB2int(currLLB);
end