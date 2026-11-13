function [errStat, errMsg] = verify_fileinfo( info, infoR )
   % verify that the current and restored FileInfo structures match
   % R = restored
   
   errStat = 0;
   errMsg  = '';
   
   % Logic for needing to verify info is as follows:
   % 1) Does the new file contain a listing of new time-series data files?
   % if 
   
      % If the new settings file includes a new set of time-series data
      % files, then we need to verify things like channels names and units.
   if (info.TotalFiles > 0 ) 
      
      % Since the new settings file lists at least one new time-series,
      % it will contain a list of ChanNames, and possible Units and
      % Calculated channels.  We must test these for consistency with the
      % restored information
      
      nChannels  = length( info.ChanNames );
      nChannelsR = length( infoR.ChanNames );

      if ( nChannels ~= nChannelsR )
         errMsg = sprintf('Number of channels in the new settings file or input files does not match the number of channels in the restored data: %d.\n', nChannelsR );
         errStat = 4;
      else
         for i = 1:nChannels
            if ( ~strcmp( info.ChanNames{i},infoR.ChanNames{i} ) )
               % NOTE: This error could occurr if the channels are not in
               % the same order.
               errMsg2 = sprintf('Restored channel name, %s, does not match current settings file name, %s.\n', infoR.Names{i},info.Names{i} );
               errMsg  = [errMsg, errMsg2];
               errStat = 4;
            end
         end
      end
      if ( info.HaveUnits ~= infoR.HaveUnits )
         if ( infoR.HaveUnits )
            errMsg2 = sprintf('Restored results have units, but the current input data does not.\n' );
         else
            errMsg2 = sprintf('Current input data has units, but the restored results do not.\n' );
         end
         errMsg  = [errMsg, errMsg2];
         errStat = 4;
      end
      
      %TODO: Verify the unit labels are the same
      
      if ( info.NumCChan ~= infoR.NumCChan )
         errMsg2 = sprintf('The current Settings file value for the number of calculated channels does not match restored setting. New has: %d, Restored has: %d.\n', ...
                            info.NumCChan, infoR.NumCChan);
         errMsg  = [errMsg, errMsg2];
         errStat = 4;
      else
         %TODO: Verify the calculated channels are the same
        % for iChan = 1:info.NumCChan
        % end
      end   
      
      % Verify that the same windspeed channel is specified
      if ( infoR.WSChan       ~= info.WSChan )
         errMsg2 = sprintf('Settings file value of WSChan parameter must match restored setting. New has: %d, Restored has: %d.\n', info.WSChan, infoR.WSChan);
         errMsg  = [errMsg, errMsg2];
         errStat = 4;
      end

      % Since some files are being restored, we need to match the FindPeaks
      % flag
      if ( infoR.FindPeaks ~= info.FindPeaks )
         errMsg2 = sprintf('Settings file value of FindPeaks parameter must match Restored setting.\n');
         errMsg  = [errMsg, errMsg2];
         errStat = 4;
      end
   
      % Need to verify that the any new files are not repeats of existing
      % files in the restored data

      for iNewFile = 1:info.TotalFiles
         for iOldFile = 1:infoR.TotalFiles
            if strcmp( info.FileList{iNewFile},infoR.FileList{iOldFile} )
               errMsg2 = sprintf('Found existing file, %s, in both the new filelist and the restored filelist.\n', info.FileList{iNewFile});
               errMsg  = [errMsg, errMsg2];
               errStat = 4;
            end
         end
      end
   
   else
      
      
      
      
   end
   
   

   
   
   
end