%% savePlot
%
% This function saves the plot for linux/pc OSs. For PC it will save the
% plot in three types: .png, .fig, and .epsc. 
%
% Inputs:
% fPath              - File path trunk where your results are saved.
% StratTypeFodler   - Strategy Specific Folder
% handle            - Handle for plot you want to save
% plotName          - Name you want to assign the plot in the file
%%
function savePlot(fPath, StratTypeFolder, FolderName, handle, plotName)


%% Global Variables
global armSide;         % This variable helps us to know which arms are available.
global currentArm;      % Tells if the current arm is right (2) or left (1)
                        
%%  Set Directory    
%    if(ispc)
        % Make matlab folder
        dir = strcat(fPath,StratTypeFolder,FolderName);
        
        % Check if directory exists, if not create a directory
        if(exist(strcat(dir,'/',plotName),'dir')==0)
            mkdir(dir,plotName);
        end
        
%%      Select Handles        
        if(length(handle)>1)
            hdl = handle(1);
            axes(hdl);
        else
            hdl = handle;
            %axes(hdl);
        end
        
%% Get Time
        date    = clock;            % y/m/d h:m:s
        h       = num2str(date(4));
        min     = date(5);          % minutes before 10 appear as '9', not '09'. 

    % Fix appearance of minutes
        if(min<10)                              % If before 10 minutes
            min = strcat('0',num2str(min));
        else
            min = num2str(min);
        end
        
%%      Save      
        % Right Arm
        if(armSide(1,2) && currentArm==2)
            nm = strcat(fPath,StratTypeFolder,FolderName,'/',plotName,'/',FolderName);      %'plot',num2str(h),num2str(min));
        end
        
        % Left Arm
        if(armSide(1,1) && currentArm==1)
            nm = strcat(fPath,StratTypeFolder,FolderName,'/',plotName,'/',FolderName,'_L'); %'plot',num2str(h),num2str(min));            
        end
        
        if(strcmp(FolderName(1,end),'/'))
            nm = nm(1,1:end-1);
        end
        p = strcat(nm,'.png');
        f = strcat(nm,'.fig');
        saveas(hdl,p,'png');         
        saveas(hdl,f,'fig');
        %saveas(hdl,FolderName,'epsc');        
%     else
%         print -depsc    diffPlot.eps;
%         print -dpslatex diffPlot.eps;
%         print -dfig     diffPlot.fig;
%         print -dpng     diffPlot.png;
% %        print '\home\juan\Documents\Results\PivotApproach' -depsc Multiplot.eps
%     end
end