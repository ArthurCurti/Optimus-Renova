function [FileInfo, ElapsedTime, FileMeanWindSpeed, ChanMinAssocValues, ChanMaxAssocValues, errStat, errMsg] = GenerateExtremes(Settings, FileInfo)
% Need to return FileInfo, because some quantities are updated/set as part
% of ReadOneFile
   
  % Initialize 

   FirstPass         = true;
   ElapsedTime       = 0;
   FileMeanWindSpeed = 0;
   errStat           = 0;
   errMsg            = '';
   
   % If we are restoring previously saved extreme data, do it now
   
   if ( Settings.restoreState )
         % This is only the data arrays, the associated data has already
         % been restored so that it could be checked for consistency with
         % the current settings
      try
            
         load( Settings.restoreFilename, '-mat', 'ChanMinAssocValues', 'ChanMaxAssocValues', 'ElapsedTime', 'FileMeanWindSpeed');
        
            % This needs to be set when the file was saved because we need it to process the
            % old and new data without having to restore the large arrays associated with the extremes.
         % FileInfo.iFileOffset = size(ElapsedTime,2) + 1; 
         
      catch err
         errStat = 4;
         errMsg  = sprintf('Could not restore the MExtremes save file: %s',Settings.restoreFilename);
         return
      end
   else
      ElapsedTime       = zeros(1,FileInfo.TotalFiles,'single');
      FileMeanWindSpeed = zeros(1,FileInfo.TotalFiles,'single');
   
         % Store the extreme values for each channel in each file and the associated timestep channel data for those extreme events
         % This allows for binning of the results even if the user has restored previously computed extreme events
      
         %NOTE: These arrays can get to be quite large and perhaps needs to
         %be re-thought. 500 Chan x 500 Chan x 10,000 files x 4 bytes per
         %record = 9.5 GB of data per array!  Perhaps we need to load and
         %unload file chunks from disk
      ChanMinAssocValues = zeros( FileInfo.TotalChans, FileInfo.TotalChans, FileInfo.TotalFiles,   'single' );
      ChanMaxAssocValues = zeros( FileInfo.TotalChans, FileInfo.TotalChans, FileInfo.TotalFiles,   'single' );
      FileInfo.iFileOffset         = 1;   
   end
  
   
   
        % Store the extreme values for each channel in each file and the associated timestep channel data for those extreme events
      % This allows for binning of the results even if the user has restored previously computed extreme events
      
    
   for iFile=FileInfo.iFileOffset:FileInfo.TotalFiles

         % the peak finding option is applied within ReadOneFile
      iDLC = FileInfo.DLCMask(iFile);
      [FileInfo, errStat, errMsg] = ReadOneFile( FileInfo.FileList(iFile), iDLC, FileInfo, Settings, FirstPass);    

      FirstPass           = false;

         % Determine the minima and maxima for all requested table and chart channels (AllEEvChans)

      [ ~, MinInds ]      = min(  FileInfo.Time(:,1:FileInfo.TotalChans) );
      [ ~, MaxInds ]      = max(  FileInfo.Time(:,1:FileInfo.TotalChans) );


      ElapsedTime(iFile)        = FileInfo.Time(end,FileInfo.TimeChan) - FileInfo.Time(1,FileInfo.TimeChan);
      FileMeanWindSpeed(iFile)   = mean( FileInfo.Time(:,FileInfo.WSChan) ); 


         % Store the extreme values in to appropriate location in the master storage arrays

      ChanMinAssocValues(:,:,iFile) = FileInfo.Time(MinInds,1:FileInfo.TotalChans);
      ChanMaxAssocValues(:,:,iFile) = FileInfo.Time(MaxInds,1:FileInfo.TotalChans);

   end % for File
      
  
   
end