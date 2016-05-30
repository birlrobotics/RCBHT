% Take all existing results in:
% "C:\Documents and Settings\suarezjl\My Documents\School\Research\AIST\Results\ForceControl\SideApproach\"\
% Load all the hlbBeliefs as well as the individual posteriors for the
% three states: Rot, Snp, Mat.
%
% Plot all the posteriors of the LLBs on the same plot as dotted lines. 
% Then plot the average of the belief for all results as a thick red line.
%
% Note:
% Different trials have different times for their state transitions.
% In this case, we select the minimum time transition across all trials, to
% have coherence across results. 
function hlbBelief = averageProbResults(stateTimes)

%% Load Data

    % 1) Define computer path
    if(ispc)
        Path = 'C:\\Documents and Settings\\suarezjl\\My Documents\\School\\Research\\AIST\\Results\\ForceControl\\'; 
        Top  = 'SideApproach\\';
    % Linux
    else
       Path = '\\home\\juan\\Documents\\Results'; 
       % QNX
       % '\\home\\vmrguser\\Documents\\Results'; 
    end

    % Folder Name (stringed) array. 
    % Use the command dir on the top folder to get a struc for each file/folder
    % in the top folder.
    % First two elements are to be ignored, then use a loop and check the
    % 'isdir' property to check if it is a folder. If so, store the name if the
    % FolderName array. Note that this can stringed array can be easily be
    % implemented because all names have the same length.

    FolderNames = cell(1,1);
    
    % Save the folder structure into listing
    listing = dir(strcat(Path,Top));

    % Get the size
    r = size(listing);
    
    % Iterate through listing struc and save names of directories. Start at i=3.
    for i=3:r(1)
       % If we have a directry
       if(listing(i,1).isdir == 1)
           % If successful attempt
           temp = listing(i,1).name;
           if(length(temp)<28)
               continue; % skip this one
           elseif(strcmp(temp(1,28),'S'))
               % Store the name
               FolderNames{i-2,1} = temp;
           end
       end
    end

    % Get thesize of FolderNames
    r = size(FolderNames);
    
%%      Create buffers as big as the number of files
    hlbBeliefMat   = cell(r(1),1);
    hlbPriorRotMat = cell(r(1),1);
    hlbPriorSnpMat = cell(r(1),1);
    hlbPriorMatMat = cell(r(1),1);    
        
%% Load .mat files and states 

    % Probability Path
    ProbData        = '\\Probability\\Data\\';
    
    % Prob Data Structures saved in the Results Files
    hlbBeliefFile   = 'hlbBelief.mat';

    hlbPriorRotFile = 'hlbPriorRot.mat';
    hlbPriorSnpFile = 'hlbPriorSnp.mat';    
    hlbPriorMatFile = 'hlbPriorMat.mat';
    
    
%%  Load Probability Data for each Results Folder
    for i=1:r(1)
        hlbBeliefMat{i}   = load(strcat(Path,Top,FolderNames{i},ProbData,hlbBeliefFile));
        
        hlbPriorRotMat{i} = load(strcat(Path,Top,FolderNames{i},ProbData,hlbPriorRotFile));        
        hlbPriorSnpMat{i} = load(strcat(Path,Top,FolderNames{i},ProbData,hlbPriorSnpFile));
        hlbPriorMatMat{i} = load(strcat(Path,Top,FolderNames{i},ProbData,hlbPriorMatFile));        
    end

%% Retrieve size (rows and cols) from each of the structures. keep the smallest number for each
    
    % Number of rows for all instances of each structure
    rows_hlbBelief      = zeros(r(1),1);
    rows_hlbPriorRotMat = zeros(r(1),1);
    rows_hlbPriorSnpMat = zeros(r(1),1);
    rows_hlbPriorMatMat = zeros(r(1),1);
    
    min_rows = zeros(4,1);
    
    for i=1:r(1)
        [rows_hlbBelief(i)      c] = size(hlbBeliefMat{i}.hlbBelief);      
        [rows_hlbPriorRotMat(i) c] = size(hlbPriorRotMat{i}.hlbPriorRot);        
        [rows_hlbPriorSnpMat(i) c] = size(hlbPriorSnpMat{i}.hlbPriorSnp);        
        [rows_hlbPriorMatMat(i) c] = size(hlbPriorMatMat{i}.hlbPriorMat);        
    end
    
    % Establish min results
    min_rows(1) = min(rows_hlbBelief);
    min_rows(2) = min(rows_hlbPriorRotMat);
    min_rows(3) = min(rows_hlbPriorSnpMat);
    min_rows(4) = min(rows_hlbPriorMatMat);    
     
%% Compute the average posterior for each structure: hlbBelief, llbRot,
%% llbSnp, llbMat.

    % Initialize structures    
    hlbBelief   = 0;
    hlbPriorRot = 0;
    hlbPriorSnp = 0;
    hlbPriorMat = 0;

    % Sum each cell
    for i=1:r(1)
        hlbBelief   = hlbBelief    + hlbBeliefMat{i}.hlbBelief(1:min_rows(1),1);
        hlbPriorRot = hlbPriorRot  + hlbPriorRotMat{i}.hlbPriorRot(1:min_rows(2),1);
        hlbPriorSnp = hlbPriorSnp  + hlbPriorSnpMat{i}.hlbPriorSnp(1:min_rows(3),1);
        hlbPriorMat = hlbPriorMat  + hlbPriorMatMat{i}.hlbPriorMat(1:min_rows(4),1);
    end
    
    % Divide by total number of trials
    hlbBelief   = hlbBelief  /r(1);
    hlbPriorRot = hlbPriorRot/r(1);
    hlbPriorSnp = hlbPriorSnp/r(1);
    hlbPriorMat = hlbPriorMat/r(1);
    
%% Initialize State Times

    SimStep        = 0.005;                                 % The simulation's time step magnitude
    StartingIndex  = (stateTimes(1,1)/SimStep)+1;           % I.e. SimStep = 0.05. Time = {0,0.05}. Then time=0.05/SimStep = 1, but it's index 2.    
    % Indeces: i.e. when does the state start
    StartRot    = 1;
    EndRot      = length(hlbPriorRot);
    EndSnap 	= EndRot  + length(hlbPriorSnp);    
    EndMat      = EndSnap + length(hlbPriorMat);
    
%% Plot data

    % Create a time vector
    time = stateTimes(1,1)+(0.005*(0:min_rows(1,1)-1))';

%% Plot Individual Prior Results
    for i=1:r(1)
        p(1) = plot(time(StartRot:EndRot), hlbPriorRotMat{i}.hlbPriorRot(1:min_rows(2),1), '--m'); hold on;
        p(2) = plot(time(EndRot+1:EndSnap), hlbPriorSnpMat{i}.hlbPriorSnp(1:min_rows(3),1),'--b'); hold on;
        p(3) = plot(time(EndSnap+1:EndMat), hlbPriorMatMat{i}.hlbPriorMat(1:min_rows(4),1),'--k'); hold on;        
%         plot(time(StartRot:EndRot), hlbPriorRot(1:end),  '--m'); hold on; %,'MarkerSize',6,'MarkerEdgeColor','m','MarkerFaceColor',[1 0 1]), hold on,  % Plot Rotation Prior with more spacing on the time
%         plot(time(EndRot+1:EndSnap),hlbPriorSnp(1:end),  '--b'); hold on; %,'MarkerSize',6,'MarkerEdgeColor','b','MarkerFaceColor',[0 0 1]), hold on,  % Plot Rotation Prior with more spacing on the time
%         plot(time(EndSnap+1:EndMat),hlbPriorMat(1:end),  '--k'); hold on; %,'MarkerSize',6,'MarkerEdgeColor','k','MarkerFaceColor',[0 0 0]), hold on,  % Plot Rotation Prior with more spacing on the time        
%         plot(time, hlbBeliefMat{i}.hlbBelief(1:min_rows(1),1),':k'); hold on;
    end    
    
%% Plot Average Priors and Average Weighted Belief
    % Avg Priors
    p(4) = plot(time(StartRot:EndRot), hlbPriorRot(1:end),  'm', 'LineWidth',2.5); hold on; %,'MarkerSize',6,'MarkerEdgeColor','m','MarkerFaceColor',[1 0 1]), hold on,  % Plot Rotation Prior with more spacing on the time
    p(5) = plot(time(EndRot+1:EndSnap),hlbPriorSnp(1:end),  'b','LineWidth',2.5);  hold on; %,'MarkerSize',6,'MarkerEdgeColor','b','MarkerFaceColor',[0 0 1]), hold on,  % Plot Rotation Prior with more spacing on the time
    p(6) = plot(time(EndSnap+1:EndMat),hlbPriorMat(1:end),  'k','LineWidth',2.5);  hold on; %,'MarkerSize',6,'MarkerEdgeColor','k','MarkerFaceColor',[0 0 0]), hold on,  % Plot Rotation Prior with more spacing on the time        

    % Avg Weighted Belief
    p(7) =plot( time, hlbBelief,'r','LineWidth',2.5 ); 

  % Labels
    title('Average Belief across Trials as a function of State Automata'); 
    xlabel('Time (secs)'); 
    ylabel('Posterior Probability'); 
    legend([p(4) p(5) p(6) p(7)],'Avg. bel(Rot)','Avg. bel(Snap)','Avg. bel(Mat)','Avg. Weighted Belief','Location','SouthOutside','Orientation','Horizontal');

    % Axis adjustment
    Max = 1.1; % Probability can be 1.0 max.
    Min = 0.0;         
    axis([stateTimes(1,1) stateTimes(end,1) Min Max]);        

    % Insert State lines        
    FillFlag = 0;   % no fill
    insertStates(stateTimes,Max,Min,FillFlag)    
    
%% Print a single legend


%% Save plot to the results file
    if(ispc)       
        % Set plot name
        StratTypeFolder = AssignDir('HSA'); %i.e. Hiro Side Approach = 'HSA'
        % 2) Assing appropriate directoy based on Ctrl Strategy to read data files
        if(ispc)
            Path = 'C:\\Documents and Settings\\suarezjl\\My Documents\\School\\Research\\AIST\\Results';
        else
           Path = '\\home\\juan\\Documents\\Results'; 
           % QNX
           % '\\home\\vmrguser\\Documents\\Results'; 
        end          
        Name = strcat(Path,StratTypeFolder,'AveragePosteriorPlot');
        
        if(exist(Name,'dir')==0)
            mkdir(Name);
        end
        
        % Add file name
        Name=strcat(Name,'\\averagePosterior');
        
        % Save
        saveas(p,Name,'epsc');
        saveas(p,Name,'png');         
        saveas(p,Name,'fig');
    else
        print -depsc    ProbabilityPlot.eps;
        print -dpslatex ProbabilityPlot.eps;
        print -dfig     ProbabilityPlot.fig;
        print -dpng     ProbabilityPlot.png;
        print '\home\juan\Documents\Results\SideApproach\snapData3\' -depsc ProbabilityPlot.eps
    end
end    