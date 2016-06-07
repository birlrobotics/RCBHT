%% convertLLB2int
% Accepts a stringed tag for an LLB: {FX CT PS PL SH AL} and returns the
% corresponding index.
% Also takes two special options:
%   'ALFX' returns 7.
%   'NA'   returns -1

function llbTag = convertLLB2int(llbTag)

%% Return index according to string llb tag
    if(strcmp(llbTag,'FX')) 
        llbTag = 1;
    elseif(strcmp(llbTag,'CT')) 
        llbTag = 2;
    elseif(strcmp(llbTag,'PS')) 
        llbTag = 3;
    elseif(strcmp(llbTag,'PL')) 
        llbTag = 4;
    elseif(strcmp(llbTag,'SH')) 
        llbTag = 5;
    elseif(strcmp(llbTag,'AL')) 
        llbTag = 6;
    elseif(strcmp(llbTag,'AF')) 
        llbTag = 7;
    elseif(strcmp(llbTag,'NA')) 
        llbTag = -1;
    end
   
end