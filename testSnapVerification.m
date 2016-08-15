
%dirFlags = [files.isdir]
% Extract only those that are directories.
%subFolders = files(dirFlags)
% SIM_HIRO_TWO_SA_SUCCESS
function testSnapVerification(StrategyType)

    strat=AssignDir(StrategyType);
    path='/media/vmrguser/DATA/Documents/School/Research/AIST/Results/'; % The path at which you want to save the main body of results. Folders will be created within this folder for different strategyTypes.
    %baxterPath='/home/vmrguser/ros/indigo/baxter_ws/src/birl_baxter/birl_demos/pivotApproach/pa_demo/bags/';  

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
        if fname(1) == '.'
            folders(k) = [ ];
        elseif(~strcmp(fname(1:2),'20'))
            folders(k) = [ ];
%         elseif(strcmp('gradClassFolder',fname))
%                 folders(k) = [ ];            
%         elseif(strcmp('001_MPFH',fname))
%             folders(k) = [ ];
%         elseif(strcmp('002_MHFP',fname))
%             folders(k) = [ ];          
%         elseif(strcmp('Media',fname))
%             folders(k) = [ ];              
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