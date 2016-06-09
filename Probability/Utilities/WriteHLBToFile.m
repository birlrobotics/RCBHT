%% ************************** Documentation *********************************
% Write to file, statistical data used in fitRegressionCurves to analyze 
% segmented portions of force-moment data.
%
% Input Variables:
% Path              : path string to the "Results" directory
% StratTypeFolder   : path string to Position/Force Control and Straight Line
%                     approach or Pivot Approach.
% Foldername        : name of folder of data we are handling
% data              : data to be saved. motComps 1x11, llBehStruc 1x17
%**************************************************************************
function FileName=WriteHLBToFile(WinPath,StratTypeFolder,FolderName,hlbPriorRot,hlbPriorSnp,hlbPriorMat,hlbBelief)

%% Initialization

    % Set the linux path to the pivot approach where we will save composites
    LinuxPath   = '\\home\\Documents\\Results\\Force Control\\Pivot Approach\\';  
      
    
%%  Generate the Directory Path
    if(ispc)
        % Set path with new folder "Composites" in it.
        dir          = strcat(WinPath,StratTypeFolder,FolderName,'\\Probability','\\Data');                    
    else % Linux
        dir         = strcat(LinuxPath,StratTypeFolder,FolderName,'\\Probability','\\Data');         
    end 

    % Check if directory exists, if not create a directory
    if(exist(dir,'dir')==0)
        mkdir(dir);
    end     

%%  Create a time sensitive name for file according to data    
%%  Save to composites folder
% Save motcomps.mat to Composites folder save filename content stores only those variables specified by content in file filename
    save(strcat(dir,'\\hlbPriorRot','.mat'),'hlbPriorRot');
    save(strcat(dir,'\\hlbPriorSnp','.mat'),'hlbPriorSnp');
    save(strcat(dir,'\\hlbPriorMat','.mat'),'hlbPriorMat');
    save(strcat(dir,'\\hlbBelief','.mat'),'hlbBelief');             
end