% updateHistStateData
% Loads the selected historically averaged data, and it then
% performes averaging and counter updating with the new data and then
% saves the file as a file.
%
% Output
% histData:        outputs the col vec with ctr and times info
%--------------------------------------------------------------------------
function histData=updateHistData(fPath,StratTypeFolder,data,matName)
    
%% --------------------- SUCCESSFUL -------------------------------------------------
% xDir-------------------------------------------------------------------------------
    if(strcmp(matName,    's_histMyRotAvgMag.mat') )
        % Load the historical stateData structure
        [s_histMyRotAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
        s_histMyRotAvgMag = averageHistData(data,s_histMyRotAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'s_histMyRotAvgMag');
        
    elseif(strcmp(matName,'s_histFzRotAvgMag.mat') )
        % Load the historical stateData structure
        [s_histFzRotAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         s_histFzRotAvgMag= averageHistData(data,s_histFzRotAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'s_histFzRotAvgMag');
        
% yDirPos----------------------------------------------------------------------------        
    elseif(strcmp(matName,'s_histMzRotPosAvgMag.mat') )
        % Load the historical stateData structure
        [s_histMzRotPosAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         s_histMzRotPosAvgMag= averageHistData(data,s_histMzRotPosAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'s_histMzRotPosAvgMag');
        
% yDirMin----------------------------------------------------------------------------        
    elseif(strcmp(matName,'s_histMzRotMinAvgMag.mat') )
        % Load the historical stateData structure
        [s_histMzRotMinAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         s_histMzRotMinAvgMag= averageHistData(data,s_histMzRotMinAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'s_histMzRotMinAvgMag');
    
% xRollDirPos-------------------------------------------------------------------------        
    elseif(strcmp(matName,'s_histFxAppPosAvgMag.mat') )
        % Load the historical stateData structure
        [s_histFxAppPosAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         s_histFxAppPosAvgMag= averageHistData(data,s_histFxAppPosAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'s_histFxAppPosAvgMag'); 
        
    elseif(strcmp(matName,'s_histFzAppPosAvgMag.mat') )
        % Load the historical stateData structure
        [s_histFzAppPosAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         s_histFzAppPosAvgMag= averageHistData(data,s_histFzAppPosAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'s_histFzAppPosAvgMag');
        
% xRollDirMin----------------------------------------------------------------------------         
        
    elseif(strcmp(matName,'s_histFxAppMinAvgMag.mat') )
        % Load the historical stateData structure
        [s_histFxAppMinAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         s_histFxAppMinAvgMag= averageHistData(data,s_histFxAppMinAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'s_histFxAppMinAvgMag');         
             
    elseif(strcmp(matName,'s_histFzAppMinAvgMag.mat') )
        % Load the historical stateData structure
        [s_histFzAppMinAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         s_histFzAppMinAvgMag= averageHistData(data,s_histFzAppMinAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'s_histFzAppMinAvgMag');        
        
%%-------------------------- Failure --------------------------------------------------
% xDir-------------------------------------------------------------------------------
    elseif(strcmp(matName,'f_histMyRotAvgMag.mat') )
        % Load the historical stateData structure
        [f_histMyRotAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         f_histMyRotAvgMag= averageHistData(data,f_histMyRotAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'f_histMyRotAvgMag');   
        
    elseif(strcmp(matName,'f_histFzRotAvgMag.mat') )
        % Load the historical stateData structure
        [f_histFzRotAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         f_histFzRotAvgMag= averageHistData(data,f_histFzRotAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'f_histFzRotAvgMag'); 
        
% yDirPos----------------------------------------------------------------------------        
    elseif(strcmp(matName,'f_histMzRotPosAvgMag.mat') )
        % Load the historical stateData structure
        [f_histMzRotPosAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         f_histMzRotPosAvgMag= averageHistData(data,f_histMzRotPosAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'f_histMzRotPosAvgMag');
% yDirMin-------------------------------------------------------------------------------        
    elseif(strcmp(matName,'f_histMzRotMinAvgMag.mat') )
        % Load the historical stateData structure
        [f_histMzRotMinAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         f_histMzRotMinAvgMag= averageHistData(data,f_histMzRotMinAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'f_histMzRotMinAvgMag');        
        
% xRollDir-Pos-------------------------------------------------------------------------        
    elseif(strcmp(matName,'f_histFxAppPosAvgMag.mat') )
        % Load the historical stateData structure
        [f_histFxAppPosAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         f_histFxAppPosAvgMag= averageHistData(data,f_histFxAppPosAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'f_histFxAppPosAvgMag'); 
        
    elseif(strcmp(matName,'f_histFzAppPosAvgMag.mat') )
        % Load the historical stateData structure
        [f_histFzAppPosAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         f_histFzAppPosAvgMag= averageHistData(data,f_histFzAppPosAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'f_histFzAppPosAvgMag');          
        
% xRollDir-Min------------------------------------------------------------------------        

    elseif(strcmp(matName,'f_histFxAppMinAvgMag.mat') )
        % Load the historical stateData structure
        [f_histFxAppMinAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         f_histFxAppMinAvgMag= averageHistData(data,f_histFxAppMinAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'f_histFxAppMinAvgMag');         
            
    elseif(strcmp(matName,'f_histFzAppMinAvgMag.mat') )
        % Load the historical stateData structure
        [f_histFzAppMinAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         f_histFzAppMinAvgMag= averageHistData(data,f_histFzAppMinAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'f_histFzAppMinAvgMag');         
    else
        data=-1;
    end
    
end