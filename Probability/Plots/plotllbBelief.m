%% plotBelief
%
% This function plots the posterior (also known as belief) for the CBHT,
% where we have a {6 x time x axes} structure. The rows represent the six
% low-level behaviors of the CBHT, the columns represent the duration of
% the trial, and it is repeated across 6 dimensions for each of the six
% force axis elements for which it was computed. 
%
% A different line is assigned to the probability of an llb. Six subplots
% are generated for each of the six axes. 
% 
% The automata Approach State is skipped since it does not contribute info.
%
% The plot is saved at the end in .png, .fig, and .eps formats.
%%
function plotllbBelief(Path,StratTypeFolder,FolderName,time,posterior,stateTimes)

%% Global Variables

    % Number of Forces Axes
    NumAxes = 6;

    % Global Indeces
    handle = zeros(NumAxes,1);  
    
%% Reference Parameters: two kinds (a) Axes, (b) Suplots. 
    % Subplot: Row major order. Used to indicate where in the subplot the
    % figure goes. 
    SP_Fx=1; SP_Mx=2;
    SP_Fy=3; SP_My=4;
    SP_Fz=5; SP_Mz=6;
    
    % Axes: Serial Order. To select the right axis data. 
    Fx=1; Fy=2; Fz=3; Mx=4; My=5; Mz=6;   
    
%% Plot the posterior probability for each of the llbs across the 3 automata states for the Fx axes

    % Make it a full screen
    fullscreen = get(0,'ScreenSize');
    figure('Position',[0 -50 fullscreen(3) fullscreen(4)])
        
    % Plot each axis
%% Fx

    handle(SP_Fx)=subplot(3,2,SP_Fx); 
    % For all low-level behaviors 
    plot( time, posterior(1,:,Fx),'k',...     % FX - black
          time, posterior(2,:,Fx),'b',...     % CT - blue
          time, posterior(3,:,Fx),'w',...     % PS - white
          time, posterior(4,:,Fx),'c',...     % PL - cyan
          time, posterior(5,:,Fx),'m',...     % SH - magenta
          time, posterior(6,:,Fx),'r');       % AL - red    
      
        % Labels
        title('LLB Belief for Fx'); 
        xlabel('Time (secs)'); 
        ylabel('Posterior Probability'); 

        % Axis adjustment
        Max = 1.1; % Probability can be 1.0 max.
        Min = 0.0;         
        axis([time(1) stateTimes(end,1) Min Max]);  
                
        % Insert State lines        
        FillFlag = 0;   % no fill
        insertStates(stateTimes,Max,Min,FillFlag)   
%% Fy

    handle(SP_Fy)=subplot(3,2,SP_Fy); 
    plot( time, posterior(1,:,Fy),'k',...     % FX - black
          time, posterior(2,:,Fy),'b',...     % CT - blue
          time, posterior(3,:,Fy),'w',...     % PS - white
          time, posterior(4,:,Fy),'c',...     % PL - cyan
          time, posterior(5,:,Fy),'m',...     % SH - magenta
          time, posterior(6,:,Fy),'r');       % AL - red     
      
        % Labels
        title('LLB Belief for Fy'); 
        xlabel('Time (secs)'); 
        ylabel('Posterior Probability'); 

        % Axis adjustment
        Max = 1.1; % Probability can be 1.0 max.
        Min = 0.0;         
        axis([time(1) stateTimes(end,1) Min Max]);        
        
        % Insert State lines        
        FillFlag = 0;   % no fill
        insertStates(stateTimes,Max,Min,FillFlag)   
%% Fz

    handle(SP_Fz)=subplot(3,2,SP_Fz);
    plot( time, posterior(1,:,Fz),'k',...     % FX - black
          time, posterior(2,:,Fz),'b',...     % CT - blue
          time, posterior(3,:,Fz),'w',...     % PS - white
          time, posterior(4,:,Fz),'c',...     % PL - cyan
          time, posterior(5,:,Fz),'m',...     % SH - magenta
          time, posterior(6,:,Fz),'r');       % AL - red     
      
        % Labels
        title('LLB Belief for Fz'); 
        xlabel('Time (secs)'); 
        ylabel('Posterior Probability'); 

        % Axis adjustment
        Max = 1.1; % Probability can be 1.0 max.
        Min = 0.0;         
        axis([time(1) stateTimes(end,1) Min Max]);        
        
        % Insert State lines        
        FillFlag = 0;   % no fill
        insertStates(stateTimes,Max,Min,FillFlag)   
%% Mx

    handle(SP_Mx)=subplot(3,2,SP_Mx);
    plot( time, posterior(1,:,Mx),'k',...     % FX - black
          time, posterior(2,:,Mx),'b',...     % CT - blue
          time, posterior(3,:,Mx),'w',...     % PS - white
          time, posterior(4,:,Mx),'c',...     % PL - cyan
          time, posterior(5,:,Mx),'m',...     % SH - magenta
          time, posterior(6,:,Mx),'r');       % AL - red   
      
        % Labels
        title('LLB Belief for Mx'); 
        xlabel('Time (secs)'); 
        ylabel('Posterior Probability'); 

        % Axis adjustment
        Max = 1.1; % Probability can be 1.0 max.
        Min = 0.0;         
        axis([time(1) stateTimes(end,1) Min Max]);  
                
        % Insert State lines        
        FillFlag = 0;   % no fill
        insertStates(stateTimes,Max,Min,FillFlag)   
%% My

    handle(SP_My)=subplot(3,2,SP_My);
    plot( time, posterior(1,:,My),'k',...     % FX - black
          time, posterior(2,:,My),'b',...     % CT - blue
          time, posterior(3,:,My),'w',...     % PS - white
          time, posterior(4,:,My),'c',...     % PL - cyan
          time, posterior(5,:,My),'m',...     % SH - magenta
          time, posterior(6,:,My),'r');       % AL - red   
      
        % Labels
        title('LLB Belief for My'); 
        xlabel('Time (secs)'); 
        ylabel('Posterior Probability'); 

        % Axis adjustment
        Max = 1.1; % Probability can be 1.0 max.
        Min = 0.0;         
        axis([time(1) stateTimes(end,1) Min Max]); 
                
        % Insert State lines        
        FillFlag = 0;   % no fill
        insertStates(stateTimes,Max,Min,FillFlag)   
%% Mz

    handle(SP_Mz)=subplot(3,2,SP_Mz);
    plot( time, posterior(1,:,Mz),'k',...     % FX - black
          time, posterior(2,:,Mz),'b',...     % CT - blue
          time, posterior(3,:,Mz),'w',...     % PS - white
          time, posterior(4,:,Mz),'c',...     % PL - cyan
          time, posterior(5,:,Mz),'m',...     % SH - magenta
          time, posterior(6,:,Mz),'r');       % AL - red                                  
        
        % Labels
        title('LLB Belief for Mz'); 
        xlabel('Time (secs)'); 
        ylabel('Posterior Probability'); 

        % Axis adjustment
        Max = 1.1; % Probability can be 1.0 max.
        Min = 0.0;         
        axis([time(1) stateTimes(end,1) Min Max]);        
        
        % Insert State lines        
        FillFlag = 0;   % no fill
        insertStates(stateTimes,Max,Min,FillFlag)    
    
%% Print a single legend. It will be associated with the last subplot:
    [legend_h,object_h,plot_h,text_strings]=legend('FX','CT','PS','PL','SH','AL','Orientation','horizontal');   
    
    % Get the legend's position
    lg = get(legend_h,'Position'); % 4 position vector ([left bottom width height]) 
    
    % Establish the new coordinates for left and bottom points of the
    % legend box. These were derived empirically. Only works right if the
    % plots are shown in FULLSCREEN. The coordinates are abosoluted, they
    % do not adjust in this mode.
    lg(1) = 0.3;
    lg(2) = 0.01;
    
    % Set the legend position
    set(legend_h,'Position',lg);    
    set(legend_h,'color',[0.89,0.89,0.89]);

%% Save plot to the results file
    if(ispc)
        % Make the Probability Folder
        Name = strcat(Path,StratTypeFolder,FolderName,'\\Probability');
        if(exist(Name,'dir')==0)
            mkdir(Name);
            
            % Add the LLB Belief folder
            Name = strcat(Name,'\\LLBBelief');
            mkdir(Name);
        else
            % Add the LLB Belief folder
            Name = strcat(Name,'\\LLBBelief');
            if(exist(Name,'dir')==0)
                mkdir(Name);
            end            
        end   
        
        % Set plot name
        %Name = strcat(Name,'\\llbBelief');
        Name = strcat(Name,'\\llbBelief_mod'); % 20120612 - decided to change keyLLB struc. Results will look diff. Want to separate them.
        
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