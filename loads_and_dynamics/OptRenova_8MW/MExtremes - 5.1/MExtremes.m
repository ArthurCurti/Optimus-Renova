function [Settings] = MExtremes ( SettingsFile )
% Find extreme events of data in multiple files.
%
% Syntax is:  MExtremes( SettingsFile );
%
% Example:
%     MExtremes( 'MySettings.mext' );
%
% See also    ParseEESettingsFile, validate_path, RestoreSaveFileInfo, 
%             ProcessEESettings, GenerateExtremes, ProcessExtremes, 
%             GenerateScatterPlots, GenerateTables, GenerateCharts, WrExtEvts
%

   ProgName = 'MExtremes (v1.01.00a-gjh, 20-Oct-2015)';

   fprintf( '\n  Running %s\n\n', ProgName );

      % set dataDirectory and outputDirectory to the location of settingsFile
   [outputDirectory, outputRoot, ~] = fileparts(SettingsFile);
   if (~isempty(outputDirectory))
      oldDir = cd(outputDirectory);
      
   else
      oldDir = pwd();
      outputDirectory = oldDir;
      %outputFileRoot  = outputRoot;
   end
   
   outputDirectory = validate_path(outputDirectory);        
   outputFileRoot  = [ outputDirectory outputRoot ]; 
      
      % First parse the entire settings file and record any parsing errors
      % then we will check the input file data for self-consistency and
      % viability, given specific parameter choices.
      % By parsing first, we can correctly generate an echo file and record
      % any parsing errors to the user prior to addressing self-consistency
      % issues.
   [Settings, FileInfo, EEvTable, EEvChart, errStat, errMsg] = ParseEESettingsFile(SettingsFile);

   if ( errStat > 0 )
       error(errMsg);
       cd(oldDir);
       return
   end
   
      % See if we need to restore the information related to a previous set
      % of saved data.  
   if ( Settings.restoreState )      
      [FileInfoRestored, errStat, errMsg] =  RestoreSaveFileInfo(Settings.restoreFilename);
      if ( errStat > 0 )
         error(errMsg);
         cd(oldDir);
         return
      end
      
         % We'll then find out if the current settings file
         % parameters are consistent with what was previously saved.
      if (FileInfo.NumDLCs == 0) 
         [FileInfo, errStat, errMsg] = ProcessEESettings(FileInfoRestored);
      else
         [FileInfo, errStat, errMsg] = ProcessEESettings(FileInfo, FileInfoRestored);
      end
   else
         % Or we'll simply validate the current parameters on their own.
      [FileInfo, errStat, errMsg] = ProcessEESettings(FileInfo);
   end
   
   if ( errStat > 0 )
       error(errMsg);
       cd(oldDir);
       return
   end
   
         % Loop over the files in each DLC and create the extreme events 
         % for each time-series input file    
   [FileInfo, ElapsedTime, FileMeanWindSpeed, ChanMinAssocValues, ChanMaxAssocValues, errStat, errMsg] = GenerateExtremes(Settings, FileInfo);

   if ( errStat > 0 )
       error(errMsg);
       cd(oldDir);
       return
   end
   
      % Save the file-based extreme data and associated information to file
   if (Settings.saveState)
         % This is to be used if we wind up appending data to this save file.
      FileInfo.iFileOffset = FileInfo.TotalFiles + 1;  
      
      % TODO: Need to analyze the saveFilename. If it is a relative path, make
      % sure it is valid from a matlab stand point.  If it is absolute,
      % then likewise, check that the path portion is ok, if it is simply a
      % filename and no path, then prepend the current path to the name
      save(Settings.saveFilename, 'ChanMinAssocValues', 'ChanMaxAssocValues', 'FileInfo', 'ElapsedTime', 'FileMeanWindSpeed');
   end

      % Did the user request any charts or tables?  If not, then we are finished
   if (Settings.NumEECharts + Settings.NumEETables  > 0 )
      
         % At this point we have recorded all the extremes for: restored data plus any new data  
         % Now we need to process them based on the DLC binning model used
      [Results, errStat, errMsg] = ProcessExtremes(Settings.nEEvChans, Settings.AllEEvChans, FileInfo.ChanNames, ChanMinAssocValues, ChanMaxAssocValues, FileInfo.NumDLCs, FileInfo.DLCs, FileInfo.DLCMask, FileInfo.BinEvents, ElapsedTime, Settings.WSmin, Settings.WSmax, Settings.WSMaxBinSize, FileMeanWindSpeed);
   
         % Create scatter plots for all channels included in the requested tables and charts
      if ( Settings.ScatterPlots )
         GenerateScatterPlots(outputFileRoot, SettingsFile, FileInfo, Settings, ChanMinAssocValues, ChanMaxAssocValues, FileMeanWindSpeed, Results);
      end
      
         % Create the requested table information (this does not write the
         % information to a file
      [EEvTable] = GenerateTables(Settings,FileInfo,EEvTable, ChanMinAssocValues, ChanMaxAssocValues, Results.MinInds, Results.MaxInds, Results.MinVals, Results.MaxVals);
   
         % Create the charts and save them
      if ( Settings.NumEECharts > 0 )
         GenerateCharts(outputFileRoot, Settings, FileInfo, EEvChart, ChanMinAssocValues, ChanMaxAssocValues);
      end

         % Write the table results to a file(s)
      if ( Settings.NumEETables > 0 )
         WrExtEvts( outputFileRoot, SettingsFile, EEvTable, ProgName, Settings, FileInfo, FileInfo.FindPeaks, Settings.WrEEvtsTxt, Settings.RealFmt, Settings.WrEEvtsXLS, Settings.XLStype, Settings.ThemeColor, Settings.HeadTnS, Settings.DiagTnS );
      end
      
   end    % if (Settings.NumEECharts + Settings.NumEETables  > 0 )
  
   
   
   fprintf( '\n  MExtremes processing complete.\n\n' );
   cd(oldDir);

end % function MExtremes ( SettingsFile )
