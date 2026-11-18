function [FileInfo, errStat, errMsg] =  RestoreSaveFileInfo(restoreFilename)
    
    % Place data from current settings file into copies so that they can be compared with the restored data
    fnName = 'RestoreSaveFile'; 
    errMsg = '';
    errStat= 0;
    FileInfo = [];
         % Restore the previously saved state
    try     
      load(restoreFilename, '-mat', 'FileInfo');
    catch err
       errMsg = sprintf('  %s: Could not restore the saved MExtremes data file: %s.',fnName, restoreFilename);
       errStat= 4;
       
    end
    
      
end