%% plotHLB
% plot the higher-level prior probabilities according to the Side Approach
% (Pivot Approch for 4 snaps). 
% Also plot the joint probability of the priors to yield the likelihood of
% success of the task.
%
% Also saves the plot to file. 
%
% Inputs:
% Path              - main path where results are saved
% StratTypeFolder   - Folder according to force control strategy
% FolderNAme        - Place where results are placed
% EndRot/Snp/Mat    - indeces indicating the end of the respective stages
% time              - The time of the simulation not including the approach
%                     stage
% stateTimes        - vector of state times
% hlbPriorRot       - the prior probability for each time step of the
%                     rotation state.
% hlbPriorSnap/Mat  - same as above
% hlbBelief         - the product of the priors in a progressive fashion
%
% Output
% handle            - handle for graphics figure
%%
function handle  = plotHLB(Path,StratTypeFolder,FolderName,...
                           EndRot,EndSnap,EndMat,...
                           time,stateTimes,...
                           hlbPriorRot,hlbPriorSnp,hlbPriorMat,hlbBelief)

%% Make it a full screen
    fullscreen = get(0,'ScreenSize');
    figure('Position',[0 -50 fullscreen(3) fullscreen(4)]),
    
%% Plot priors
    Window=5; % skip some points for better viewing. 
    plot(time(1:Window:EndRot),hlbPriorRot(1:Window:end),        '--ko','MarkerSize',6,'MarkerEdgeColor','m','MarkerFaceColor',[1 0 1]), hold on,  % Plot Rotation Prior with more spacing on the time
    plot(time(EndRot+1:Window:EndSnap),hlbPriorSnp(1:Window:end),'--ko','MarkerSize',6,'MarkerEdgeColor','b','MarkerFaceColor',[0 0 1]), hold on,  % Plot Rotation Prior with more spacing on the time
    plot(time(EndSnap+1:Window:EndMat),hlbPriorMat(1:Window:end),'--ko','MarkerSize',6,'MarkerEdgeColor','k','MarkerFaceColor',[0 0 0]), hold on,  % Plot Rotation Prior with more spacing on the time
    
    % Plot the likelihood of success
    handle = plot(time(1:EndMat),hlbBelief(1:end),'r','LineWidth',2);
    
    % Labels
    xlabel('Time (seconds)');
    ylabel('Probability (per state');
    title('Likelihood of a Successful Snap Assembly Based on the Pivot Approach');
    legend('Rotation Prior','Snap Prior','Mating Prior','Location','SouthOutside','Orientation','horizontal');
    
    % Insert States and Ajdust Axis (Approach State is not included)
    Max=1.0;
    Min = 0.0;
    FillFlag = 1;
    insertStates(stateTimes,Max,Min,FillFlag);
    axis([stateTimes(1,1) stateTimes(end,1) Min Max]);
    
%% Save plot to the results file
    if(ispc)        
        
        % Make matlab folder                    
        Name = strcat(Path,StratTypeFolder,FolderName,'\\Probability','\\HLBBelief');
        if(exist(Name,'dir')==0)
            mkdir(Name);
        end
        
        % Set plot name
        %Name = strcat(Name,'\\hlbBelief');
        Name = strcat(Name,'\\hlbBelief_mod'); % 20120612 - modified KeyLLB. Want to see result separately.
        
        % Save files
        saveas(handle(1),Name,'epsc');
        saveas(handle(1),Name,'png');         
        saveas(handle(1),Name,'fig');
    else
        print -depsc    ProbabilityPlot.eps;
        print -dpslatex ProbabilityPlot.eps;
        print -dfig     ProbabilityPlot.fig;
        print -dpng     ProbabilityPlot.png;
        print '\home\juan\Documents\Results\SideApproach\snapData3\' -depsc ProbabilityPlot.eps
    end    
end