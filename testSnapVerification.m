
%dirFlags = [files.isdir]
% Extract only those that are directories.
%subFolders = files(dirFlags)
% SIM_HIRO_ONE_SA_SUCCESS
function testSnapVerification(StrategyType)

strat=AssignDir(StrategyType);
path='/home/vmrguser/research/AIST/Results/'; % The path at which you want to save the main body of results. Folders will be created within this folder for different strategyTypes.
%baxterPath='/home/vmrguser/ros/indigo/baxter_ws/src/birl_baxter/birl_demos/pivotApproach/pa_demo/bags/';  

% Check path's existence
if(exist(path,'dir')~=7)
    fprintf('Data path does not exist. Please check your path.')
    return;
end

% Formulate base path
base_dir=strcat(path,strat);


% Get folders
folders = dir(base_dir);

for k = length(folders):-1:1
    
    %% Remove non-folders
    if ~folders(k).isdir
        folders(k) = [ ];
        continue
    end
    
    % remove folders starting with .
    fname = folders(k).name;
    if(strcmp(StrategyType,'SIM_HIRO_ONE_SA_ERROR_CHARAC_Prob'))
        if fname(1) == '.'
            folders(k) = [ ];
        elseif(~strcmp(fname(1:2),'ex') && ~strcmp(fname(1:2),'FC'))
            folders(k) = [ ];
        end

        % remove folders starting with .
        fname = folders(k).name;
        if(strcmp(StrategyType,'SIM_HIRO_ONE_SA_ERROR_CHARAC_Prob'))
            if fname(1) == '.'
                folders(k) = [ ];        
            elseif(~strcmp(fname(1:2),'XX') && ~strcmp(fname(1:2),'FC'))
                folders(k) = [ ];             
            end                        
        else
            if fname(1) == '.'
                folders(k) = [ ];        
            elseif(~strcmp(fname(1:2),'20'))
                folders(k) = [ ];             
            end
        end
    end
end

% After clearing non-folders run snapVerfication
numFolders=length(folders);
tocMat=zeros(numFolders,1);
for i=1:numFolders
    tic;
    %% Run snapVerification on those folders
    snapVerification(StrategyType,folders(i).name,1,6);
    fprintf('This is run %d of %d.\n',i,numFolders);
    tocMat(i,1) = toc;
    averageTime=sum(tocMat)/i;
    fprintf('The average run time is: %0.4f.\n',averageTime);
end
end
