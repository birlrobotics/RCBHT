%% ************************** Documentation *********************************
% Write to file, either of:
% (i) statistical data, (ii) motion composition data, (iii) LLB data, or (iv) HLB data. 
% 
% Data comes from the corresponding data structure used to represent a
% given abstraction.
%
% Input Variables:
% fPath             : path string to the "Results" directory
% StratTypeFolder   : path string to Position/Force Control and Straight Line
%                     approach or Pivot Approach.
% Foldername        : name of folder of data we are handling
% pType             : type of data to analyze: Fx,Fy,Fz,Mx,My,Mz. Not
%                     applicable to probabilities.
% saveData          : flag that indicates whether to save .mat to file
% data              : data to be saved. motComps 1x11, llBehStruc 1x17
% dataFlag          : indicates the kind of data to be saved.
%                     motComps      = 0;
%                     llbehStruc    = 1;
%                     hlbehStruc    = 2;
%                     llbBelief     = 3;
%
% Modifications:
% July 2012 - to facilitate the conversion from Matlab to C++ all cells
% have been eliminated. String2Int and Int2String conversions are done when
% necessary to avoid the use of cells. 
% We write to file data with string labels to make it easier to read. 
%**************************************************************************
function FileName=WriteCompositesToFile(WinPath,StratTypeFolder,FolderName,pType,saveData,data,dataFlag)

%% Globals
global armSide;             % This variable indicates whether an arm is available.                        
global currentArm;          % This variable indicates which one is the current arm. Declared in snapVerification. RightArm==2, LeftArm==1. 
global initWriteToFileFlag; % Tells us whether this is the first iteration or not.
%% Initialization
   
    % Structures
    motComps      = 0;
    llbehStruc    = 1;
    hlbehStruc    = 2;
    llbBelief     = 3;
    
    % Save MATs to file?
    saveMAT       = 0;

%% Create Directory According to Data
    
    if(dataFlag==motComps)
        Folder='Composites';        
    elseif(dataFlag==llbehStruc)
        Folder='llBehaviors';
    elseif(dataFlag==hlbehStruc)
        Folder='hlBehaviors';
    elseif(dataFlag==llbBelief)
        Folder='llbBelief';
    end        
    
%%  Generate the Directory fPath

    % Set path with new folder "Composites" in it.
    dir = strcat(WinPath,StratTypeFolder,FolderName,'/',Folder);                    

    % Check if directory exists, if not create a directory
    if(exist(dir,'dir')==0)
        mkdir(dir);
    end     
%% Write File Name with date
    
%   if(write2FileFlag)
    % Retrieve Data
%     date	= clock;                % y/m/d h:m:s
%     h       = num2str(date(4));     % hours
%     min     = date(5);              % minutes before 10 appear as '9', not '09'. 
%         
%     % Fix appearance of minutes when under the 10 minute mark
%     if(min<10)                              
%         min = strcat('0',num2str(min));
%     else
%         min = num2str(min);
%     end

%%  Create a time sensitive name for file according to data
    if(dataFlag==motComps)
        if(armSide(1,2) && currentArm==2) % Right Arm
            FileName    = strcat(dir,'/',Folder,'_',pType);%,h,min);
        elseif(armSide(1,1) && currentArm==1) % Left Arm
            FileName    = strcat(dir,'/',Folder,'_',pType,'_L');%,h,min);
        end

    elseif(dataFlag==llbehStruc)
        if(armSide(1,2) && currentArm==2) % Right Arm
            FileName    = strcat(dir,'/',Folder,'_',pType);%,h,min);
            %FileName_temp = strcat(dir,'/',Folder,'_',pType);      % File with no date/time, useful to open from other programs.
        elseif(armSide(1,1) && currentArm==1) % Left Arm
            FileName    = strcat(dir,'/',Folder,'_',pType,'_L');%,h,min);
        end

    elseif(dataFlag==hlbehStruc)
        if(armSide(1,2) && currentArm==2) % Right Arm
            FileName    = strcat(dir,'/',Folder);%,'_',pType);%,h,min);   
        elseif(armSide(1,1) && currentArm==1) % Left Arm
            FileName    = strcat(dir,'/',Folder,'_L');%,'_',pType);%,h,min);   
        end
        
    elseif(dataFlag==llbBelief)
        if(armSide(1,2) && currentArm==2) % Right Arm
            FileName = strcat(dir,'/Data');                % File with no date/time, useful to open from other programs
        elseif(armSide(1,1) && currentArm==1) % Left Arm
            FileName = strcat(dir,'/Data','_L');                % File with no date/time, useful to open from other programs
        end
    end
    
    FileExtension = strcat(FileName,'.txt');
%        Change flag
%        write2FileFlag = false;
    
%% Check for existence and Open the file
    % IF it exists and it is our first round delete
    if(exist(FileExtension,'file')==2 && initWriteToFileFlag==0)
        delete(FileExtension);
        initWriteToFileFlag = 1;
    end
    
%% Open the file    
    if(dataFlag~=llbBelief)
        fid = fopen(FileExtension, 'a+t');	% Open/create new file 4 writing in text mode 't'
                                            % Append data to end of file.
        while(fid<0)
            pause(0.100);                   % Wait 0.1 secs
            fid = fopen(FileExtension, 'a+t');
        end
        
%% Print the data to screen and to file (except for dataFlag=llbBelief)
        r= size(data); %rows
        if(fid>0)
                if(dataFlag==motComps)
                    for i=1:r(1)
                        fprintf(fid, 'Iteration     : %d\n',   i);
                        fprintf(fid, 'Label         : %s\n',   actionInt2actionLbl(data(i,1)));
                        fprintf(fid, 'Average Val   : %.5f\n', data(i,2));
                        fprintf(fid, 'RMS Val       : %.5f\n', data(i,3));
                        fprintf(fid, 'Amplitude Val : %.5f\n', data(i,4));
                        fprintf(fid, 'Label 1       : %s\n',   gradInt2gradLbl(data(i,5))); % Modified July 2012
                        fprintf(fid, 'Label 2       : %s\n',   gradInt2gradLbl(data(i,6)));
                        fprintf(fid, 't1Start       : %.5f\n', data(i,7));
                        fprintf(fid, 't1End         : %.5f\n', data(i,8));            
                        fprintf(fid, 't2Start       : %.5f\n', data(i,9));
                        fprintf(fid, 't2End         : %.5f\n', data(i,10));            
                        fprintf(fid, 'tAvgIndex     : %.5f\n', data(i,11));
                        fprintf(fid, '\n');    
                    end   
                elseif(dataFlag==llbehStruc)
                    for i=1:r(1)
                        fprintf(fid, 'Iteration     : %d\n',   i);
                        fprintf(fid, 'CompLabel     : %s\n',   llbInt2llbLbl(data(i,1)));
                        fprintf(fid, 'averageVal1   : %.5f\n', data(i,2));
                        fprintf(fid, 'averageVal2   : %.5f\n', data(i,3));
                        fprintf(fid, 'AVG_MAG_VAL   : %.5f\n', data(i,4));                    
                        fprintf(fid, 'rmsVal1       : %.5f\n', data(i,5));
                        fprintf(fid, 'rmsVal2       : %.5f\n', data(i,6));
                        fprintf(fid, 'AVG_RMS_Val   : %.5f\n', data(i,7));                    
                        fprintf(fid, 'amplitudeVal1 : %.5f\n', data(i,8));
                        fprintf(fid, 'amplitudeVal2 : %.5f\n', data(i,9));
                        fprintf(fid, 'AVG_AMP_VAL   : %.5f\n', data(i,10));                    
                        fprintf(fid, 'Label 1       : %s\n',   gradInt2gradLbl(data(i,11)));
                        fprintf(fid, 'Label 2       : %s\n',   gradInt2gradLbl(data(i,12)));
                        fprintf(fid, 't1Start       : %.5f\n', data(i,13));
                        fprintf(fid, 't1End         : %.5f\n', data(i,14));            
                        fprintf(fid, 't2Start       : %.5f\n', data(i,15));
                        fprintf(fid, 't2End         : %.5f\n', data(i,16));            
                        fprintf(fid, 'tAvgIndex     : %.5f\n', data(i,17));
                        fprintf(fid, '\n');    
                    end                   
                elseif(dataFlag==hlbehStruc)
                    r=length(data);
                    if(r==1)
                        fprintf(fid,'%d\t%d\t%d\t%d\t',data(1));
                    elseif(r==2)
                        fprintf(fid,'%d\t%d\t%d\t%d\t',data(1),data(2));
                    elseif(r==3)
                        fprintf(fid,'%d\t%d\t%d\t%d\t',data(1),data(2),data(3));
                    elseif(r==4)
                        fprintf(fid,'%d\t%d\t%d\t%d\t',data(1),data(2),data(3),data(4));
                    end
                end
        else
            fprintf('FileID null. FID is: %s\nFileName is: %s\nSegmentIndes is: %s.',num2str(fid),FileExtension,num2str(segmentIndex));
        end
    end
    
%%  Save to composites folder
    if(saveMAT)
        if(armSide(1,2)) % Right arm
            % Save motcomps.mat to Composites folder 
            % save filename content stores only those variables specified by content in file filename
            save(strcat(FileName,'.mat'),'data');
        elseif(armSide(1,1)) % Left Arm
            save(strcat(FileName,'_L','.mat'),'data');
        end
        
%         if(dataFlag==llbehStruc)
%             save(strcat(FileName_temp,'.mat'),'data');
%         end
    end     
%% Close the file
    if(dataFlag~=llbBelief)
        fclose(fid);  
    end
end