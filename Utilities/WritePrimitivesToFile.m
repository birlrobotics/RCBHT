%% ************************** Documentation *********************************
% TODO: write all data to file in one passing instead of opening and
% closing the file per every data point. 
% 
% Write to file, statistical data used in fitRegressionCurves to analyze 
% segmented portions of force-moment data.
%
% Input Variables:
% Path              : path string to the "Results" directory
% StratTypeFolder   : path string to Position/Force Control and Straight Line
%                     approach or Pivot Approach.
% Foldername        : name of folder of data we are handling
% Type              : type of data to analyze: Fx,Fy,Fz,Mx,My,Mz
% segmentIndex      : index of segmented block number
% dAvg              : mean value of data
% dMax              : max value of data
% dMin              : min value of data
% dStart            : starting time value of current segmented block
% dFinish           : finishing time value of current segmented block
% dGradient         : gradient of fitted curve for segmented block
% dLabel            : integer gradient label indicating whether big+/-, moderate
%                     +/-, or small +/-. it's an int.
%
% Modifications:
% July 2012 - to facilitate the conversion from Matlab to C++ all cells
% have been eliminated. String2Int and Int2String conversions are done when
% necessary to avoid the use of cells. 
% We write to file data with string labels to make it easier to read. 
%----------------------------------------------------------------------------------------------------------
function [FileName,write2FileFlag]=WritePrimitivesToFile(WinPath,StratTypeFolder,FolderName,...
                                               Type,FileName,write2FileFlag,...
                                               segmentIndex,dAvg,dMax,dMin,dStart,dFinish,dGradient,dLabel)

%% Global Variables
    global armSide;             % This variable indicates if an arm is available; 
    global currentArm;          % This variable indicates if it is the current arm. Useful to plot figures and save data to file.
    global initWriteToFileFlag;
%% Create Directory   

        % Set path with new folder "Segments" in it.
        SegmentFolder='/Segments';
        dir          = strcat(WinPath,StratTypeFolder,FolderName,SegmentFolder);        
        
        % Check if directory exists, if not create a directory
        if(exist(dir,'dir')==0)
            mkdir(dir);
        end
  
%% Write File Name with date
    
    if(write2FileFlag)
        % Retrieve Data // Comment out date inclusion for text file. 
        %date    = clock;            % y/m/d h:m:s
        %h       = num2str(date(4));
        %min     = date(5);                     % minutes before 10 appear as '9', not '09'. 

    % Fix appearance of minutes
        %if(min<10)                             % If before 10 minutes
        %    min = strcat('0',num2str(min));
        %else
        %    min = num2str(min);
        %end
        % Create a time sensitive name for file
        
        % Write FileName according to whether it is a right or left arm
        if(armSide(1,2) && currentArm==2) % RightArm
            FileName = strcat(dir,'/Segement_',Type,'.txt'); %h,min,'.txt');                                                  
        end
        if(armSide(1,1) && currentArm==1) % Left Arm
            FileName = strcat(dir,'/Segement_',Type,'_L','.txt'); %h,min,'.txt');                                                  
        end
       % Change flag
       write2FileFlag = false;
    end
   
%% Check for existence of files
    % IF it exists and it is our first round delete
    if(exist(FileName,'file')==2 && initWriteToFileFlag==0)
        delete(FileName);
        initWriteToFileFlag = 1;
    end
    
%% Open the file    
    fid = fopen(FileName, 'a+t');	% Open/create new file 4 writing in text mode 't'
                                    % Append data to end of file.
    if(fid<0)
        pause(0.100);               % Wait 0.1 secs
        fid = fopen(FileName, 'a+t');
        if(fid<0)
            exit;
        end
    end
        
%% Print the data to screen and to file
    if(fid>0)
        fprintf(fid, 'Iteration : %d\n',   segmentIndex);
        fprintf(fid, 'Average   : %.5f\n', dAvg);
        fprintf(fid, 'Max Val   : %.5f\n', dMax);
        fprintf(fid, 'Min Val   : %.5f\n', dMin);
        fprintf(fid, 'Start     : %.5f\n', dStart);
        fprintf(fid, 'Finish    : %.5f\n', dFinish);
        fprintf(fid, 'Gradient  : %.5f\n', dGradient);               
        
        % Convert dLabel to a string
        if(ischar(dGradient))
            fprintf(fid, 'Grad Label: %s  \n', dLabel);
        else
            dLabel = gradInt2gradLbl(dLabel);
            fprintf(fid, 'Grad Label: %s  \n', dLabel);
            fprintf(fid, '\n');    
        end
    else
        msgbox('FileID null. FID is: ', num2str(fid),...
               '\nFileName is: ',       FileName,...
               '\nSegmentIndes is: ',   num2str(segmentIndex));
    end
    
%% Close the file
    fclose(fid);   
end