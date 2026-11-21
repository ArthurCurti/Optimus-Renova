function [SettingsData, FileInfo, EEvTable, EEvChart, errStat, errMsg] = ParseEESettingsFile ( SettingsFile )


      % Parses the settings file and returns the parsed data
      
      % Initialize data
   SettingsData              = []; 
   FileInfo                  = [];
   EEvTable                  = [];
   EEvChart                  = [];
   errMsg                    = '';
   errStat                   =  0;  % none
  
   fnName                    = 'ParseEESettingsFile';
   SettingsData.restoreState = false;
   SettingsData.saveState    = false;
   restoreLine               = 0;
   saveLine                  = 0;
   FileInfo.NumDLCs      = -1;
   
      % Open the settings file.
   unPa = fopen( SettingsFile, 'rt' );
   if ( unPa < 1 )
      errMsg  = sprintf('  %s: Could not open "%s" for reading.', fnName, SettingsFile) ;
      errStat = 4; % Fatal
      return
   end 


      % Read the settings file into a cell array.
   try 
      paramFile = textscan( unPa, '%s', 'delimiter', '\n' );
      fclose( unPa );
   catch err
      errMsg  = sprintf('  %s: %s',fnName, err.identifier);
      errStat = 4;
      fclose( unPa );
      return
   end
   
      % Here we look to see if his settings file is up to the latest
      % version
   [errStat, errMsg] = VerifySettingsVersion(paramFile);
   if (errStat > 0)
      return
   end
   
      % Search file for @Restore command   
   for pLine=1:size( paramFile{1}, 1 )
      if ( ~isempty( strfind( paramFile{1}{pLine}, '@Restore' ) ) )
            % Found a restore
         SettingsData.restoreState = true;
         temp = ReadVal( paramFile{1}{pLine}, 'string' , 2, '', '' ) ;
         SettingsData.restoreFilename = temp{2};
         restoreLine = pLine;  % This will be used to echo this line
         if ( SettingsData.restoreState )      
             [FileInfoRestored, errStat, errMsg] =  RestoreSaveFileInfo(SettingsData.restoreFilename);
             if ( errStat > 0 )
                return
             end
         end
         break
      end 
   end % for pLine
   
      % Search file for @Save command  
   for pLine=1:size( paramFile{1}, 1 )
      if ( ~isempty( strfind( paramFile{1}{pLine}, '@Save' ) ) )
            % Found a save
         SettingsData.saveState = true;
         temp = ReadVal( paramFile{1}{pLine}, 'string' , 2, '', '' ) ;
         % TODO: This filename needs to get processed to make sure it is valid
         SettingsData.saveFilename = temp{2};
         saveLine = pLine;   % This will be used to echo this line
         break
      end 
   end % for pLine
   
      % Search for number of DLCs
   for pLine=1:size( paramFile{1}, 1 )
      startIndex = regexpi(paramFile{1}{pLine},'NumDLCs');
      if ( ~isempty( startIndex ) )   % strfind( paramFile{1}{pLine}, 'NumDLCs' ) ) )
            % Found a line with the string NumDLCs
         try
               % This is trying to make sure what we found is acually the
               % correct parameter line and not simply a comment string
            temp = textscan( paramFile{1}{pLine}, '%d%s', 1 );
            temp = regexpi(temp{2},'NumDLCs');
            if ( ~isempty( temp{1} ) )
               FileInfo.NumDLCs = cell2mat( ReadVal( paramFile{1}{pLine}, 'integer', 1, 'NumDLCs',  'The number of Design Load Cases.' ) ); 
               FileInfo.FileFormat = cell2mat( ReadVal( paramFile{1}{pLine-1}, 'integer', 1, 'FileFormat', 'Flag determining input file format.  1 = ascii, 2 = binary' ) );
               dlcLine = pLine;
               break
            end
            % This actually wasn't the parameter line for NumDLCs !!!!
            % continue looking
         catch err
            % This actually wasn't the parameter line for NumDLCs !!!!
            % continue looking
         end  
      end 
   end % for pLine
   
   if ( FileInfo.NumDLCs < 0) 
      errMsg = sprintf('  %s: The settings file must contain the parameter NumDLCs, but it was not found in "%s"', fnName, SettingsFile);
      errStat = 4;
      return
   end
   
   if (  FileInfo.NumDLCs == 0 )
      if ( ~SettingsData.restoreState )
         errMsg = sprintf('  %s: The settings file must contain at least 1 valid DLC and its associated files if you are not using the @Restore feature.', fnName);
         errStat = 4;
         return
      elseif (SettingsData.saveState)
         warnMsg = sprintf('  %s: The @Save command is not needed when using @Restore and NumDLCs = 0.', fnName);
         fprintf(warnMsg);
      end
   end
   
      % Now let's parse the files associated with any DLCs and make sure we
      % have a least one valid file for each DLC listed
   if ( FileInfo.NumDLCs > 0 ) 
      FileInfo.DLCs =  repmat( struct( 'NumFiles',0, 'BinModel',0, 'PSF',zeros(1,4,'single'),'DLC_Name','' ), 1, double( FileInfo.NumDLCs ) );
      PLine = dlcLine + 1;
      TLine = PLine;
      FileInfo.TotalFiles = 0.0;
      for iDLC = 1:FileInfo.NumDLCs
         try
            temp = textscan( paramFile{1}{TLine}, '%d %f %f %f %f %d %q', 1 );
         catch err
            errMsg = sprintf('  %s: Could not correctly parse first line associated with DLC number %d.', fnName, iDLC);
            errStat = 4;
            return
         end
         if (isempty(temp{1}) || isempty(temp{2}) || isempty(temp{3}) || isempty(temp{4}) || isempty(temp{5}) || isempty(temp{6}) || isempty(temp{7}) )
            errMsg = sprintf('  %s: Could not correctly parse first line associated with DLC number %d.  Check the contents of this line for errors.  This line needs to contain: NumDLCfiles, PSF1, PSF2, PSF3, PSF4, BinModel, DLC_Name', fnName, iDLC);
            if (iDLC > 1)
               errMsg = sprintf(' %s  Also, make sure the previous DLCs have the correct number of lines for input files.',errMsg);
            end
            errStat = 4;
            return
         end
         FileInfo.DLCs(iDLC).NumFiles = temp{1};
         if (temp{1} < 1 && ~SettingsData.restoreState) 
            errMsg = sprintf('  %s: DLC number %d needs to contain at least one file.', fnName, iDLC);
            errStat = 4;
            return
         end
         FileInfo.DLCs(iDLC).DLCIndx       = iDLC;
         FileInfo.DLCs(iDLC).PSF(1)     = temp{2};
         FileInfo.DLCs(iDLC).PSF(2)     = temp{3};
         FileInfo.DLCs(iDLC).PSF(3)     = temp{4};
         FileInfo.DLCs(iDLC).PSF(4)     = temp{5};
         FileInfo.DLCs(iDLC).BinModel   = temp{6};
         FileInfo.DLCs(iDLC).DLC_Name   = temp{7}{1};
         FileInfo.DLCs(iDLC).fileIndx   = (1:temp{1}) + FileInfo.TotalFiles;
         FileInfo.TotalFiles = FileInfo.TotalFiles + temp{1};
         TLine = TLine + FileInfo.DLCs(iDLC).NumFiles + 1;
      end % for iDLC
      FileInfo.FileList = cell( FileInfo.TotalFiles, 1 );
      iCount = 1;
      for iDLC = 1:FileInfo.NumDLCs
         for iFile=1:FileInfo.DLCs(iDLC).NumFiles
            FileInfo.DLCMask(iCount)    = iDLC;
            FileInfo.FileList{iCount,1} = cell2mat( ReadVal( paramFile{1}{PLine+iFile}, 'string' , 1, '', '' ) );
            try
                  % Open the data file.
               unInp = fopen( FileInfo.FileList{iCount,1}, 'rt' );
               if ( unInp < 1 )
                  errMsg  = sprintf('  %s: Could not open "%s" for reading.', fnName, FileInfo.FileList{iCount,1}) ;
                  errStat = 4; % Fatal
                  return
               end 
               fclose(unInp);
            catch err
               errMsg  = sprintf('  %s: Could not open "%s" for reading.', fnName, FileInfo.FileList{iCount,1}) ;
               errStat = 4; % Fatal
               return
            end
            iCount = iCount + 1;
         end % for File
         PLine = PLine + FileInfo.DLCs(iDLC).NumFiles + 1;
      end % for iDLC    
   end
    
SettingsData.StrNames  = cell2mat( ReadVal( paramFile{1}{ 5}, 'logical', 1, '' , '' ) );

%if (FileInfo.NumDLCs > 0 )
      
   
   FileInfo.NumChans  = cell2mat( ReadVal( paramFile{1}{12}, 'integer', 1, '' , '' ) );   

      % See if the user supplied channel names in the parameter-input file or if
      % we should parse them from the last data file.

   if ( FileInfo.NumChans == 0 )
      FileInfo.UserNames = false;
   elseif ( FileInfo.NumChans > 0 )
      FileInfo.UserNames = true;
   else
      errMsg = sprintf('  %s: In the Input-Data Layout section of the parameter file, NumChans must be >= 0.', fnName );
      errStat = 4; % Fatal
      return
   end % if


      % Determine the number of calculated channels and where the list of channels begins.

   FileInfo.NumCChan = cell2mat( ReadVal( paramFile{1}{FileInfo.NumChans+15}, 'integer', 1, '' , '' ) );
   FirstCC  = FileInfo.NumChans + 18;

   if ( FileInfo.UserNames )


         % Channel names specified in the parameter file.
         % Read them from the cell array containing the parameter file text.

      FileInfo.ChanNames = cell( FileInfo.NumChans+FileInfo.NumCChan, 1 );
     % FileInfo.ChanNames = cell( FileInfo.NumChans, 1 );


      for Chan=1:FileInfo.NumChans
         temp            = textscan( paramFile{1}{Chan+13}, '%q', 1 );
         FileInfo.ChanNames{Chan} = cell2mat( temp{1} );
      end % for Chan

   else
      

         % Channel names specified in the header(s) of the data file(s).
         % Or if no data files are provided in this settings file, then
         % use the restored data information to generate the necessary
         % information
      
         FileInfo.NamesLine = cell2mat( ReadVal( paramFile{1}{9}, 'integer', 1, '' , '' ) );
         FileInfo.FirstDataLine = cell2mat( ReadVal( paramFile{1}{11}, 'integer', 1, 'FirstDataLine', 'The first row of data.'                ) );
         if ( ~SettingsData.restoreState )      

            [ FileInfo, errStat, errMsg ] = GrabInputFileHeaderInfo( FileInfo );
      
         end
     
     
   end % if ( UserNames )

      % Add the calculated channel names to the list of channels.
   if ( ~SettingsData.restoreState )    
      
      for Ch=1:FileInfo.NumCChan
         FileInfo.ChanNames{FileInfo.NumChans+Ch} = cell2mat( ReadVal( paramFile{1}{FirstCC+Ch-1}, 'string' , 1, '' , '' ) );
      end % for
  
      FileInfo.TotalChans = FileInfo.NumChans + FileInfo.NumCChan;
   else
      FileInfo.ChanNames  = FileInfoRestored.ChanNames;
      FileInfo.NumChans   = FileInfoRestored.NumChans;
      FileInfo.TotalChans = FileInfoRestored.TotalChans;
      FileInfo.Units      = FileInfoRestored.Units;
   end
   
% else
%          if ( SettingsData.restoreState )      
%             [FileInfoRestored, errStat, errMsg] =  RestoreSaveFileInfo(SettingsData.restoreFilename);
%             if ( errStat > 0 )
%                return
%             end
%             
%                % Use the restored FileInfo structure to set the channel
%                % related data for the current session.
%                FileInfo.ChanNames  = FileInfoRestored.ChanNames;
%                FileInfo.NumCChan   = FileInfoRestored.NumCChan;
%                FileInfo.FileList   = FileInfoRestored.FileList;
%                FileInfo.HaveUnits  = FileInfoRestored.HaveUnits;
%                if ( FileInfoRestored.HaveUnits )
%                   FileInfo.Units   = FileInfoRestored.Units;
%                end
%                FileInfo.NumChans   = FileInfoRestored.NumChans;
%                FileInfo.DLCMask    = FileInfoRestored.DLCMask;
%                FileInfo.NumDLCs    = FileInfoRestored.NumDLCs;
%                FileInfo.DLCs       = FileInfoRestored.DLCs;
%                FileInfo.TotalChans = FileInfoRestored.TotalChans;
%                FileInfo.NumCChan   = FileInfoRestored.NumCChan;
%                FileInfo.TimeChan   = FileInfoRestored.TimeChan;
%                FileInfo.WSChan     = FileInfoRestored.WSChan;
%                FileInfo.FindPeaks  = FileInfoRestored.FindPeaks;
%                FileInfo.CalcChan   = FileInfoRestored.CalcChan;
%                FileInfo.FileFormat = FileInfoRestored.FileFormat;
%                FileInfo.UserNames  = false;
%          else
%             errMsg = 'If the current settings file does not contain new input files, then you must be restoring previously saved data via the @Restore parameter';
%             errStat = 4;
%             return
%          end
% end

   if ( SettingsData.StrNames )


         % Create an cell array of index strings.

      ChanInds = cell( FileInfo.TotalChans, 1 );

      for Ch=1:FileInfo.TotalChans
         ChanInds{Ch} = num2str( Ch, '%u' );
      end % for Ch


         % Processing the ParamFile cell array, replace all the "$<ChanName>$" strings with
         % the appropriate indices.

      for Ch=1:FileInfo.TotalChans
         for PLine=1:size( paramFile{1}, 1 )
            paramFile{1}{PLine} = strrep( paramFile{1}{PLine}, [ '$', FileInfo.ChanNames{Ch}, '$' ], ChanInds{Ch} );
         end % for PLine
      end % for Ch

   end % if (SettingsData.StrNames)
  
      %=================================================================
      % Skip the header.  Read the job options.
      %=================================================================

   PLine   = 4;
   EchoInp = cell2mat( ReadVal( paramFile{1}{PLine}, 'logical', 1, 'EchoInp' , 'Echo input to <rootname>.echo as this file is being read.' ) );
   UnEc    = -1;
   if ( EchoInp )
      UnEc = fopen( [ GetRoot( SettingsFile ), '.echo' ], 'wt' );
      fprintf( UnEc, 'Echoing contents of "%s".\n', SettingsFile );
      for PLine=2:4
         fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
      end % for
   end % if

   PLine    = 4;
   SettingsData.StrNames     = cell2mat( ReadVal( paramFile{1}{PLine+1}, 'logical', 1, 'StrNames', 'Use quoted strings of actual channel names instead of numbers?', UnEc       ) );
   SettingsData.RealFmt      = cell2mat( ReadVal( paramFile{1}{PLine+2}, 'string' , 1, 'RealFmt' , 'Format for outputting floating-point values in the plain-text files.', UnEc ) );

   PLine   = PLine + 3;


      %=================================================================
      % Read the layout of the input data.
      %=================================================================

   if ( EchoInp )   
      fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
   end % if

   FileInfo.TitleLine     = cell2mat( ReadVal( paramFile{1}{PLine+1}, 'integer', 1, 'TitleLine'    , 'The row with the file title on it.', UnEc    ) );
   FileInfo.NamesLine     = cell2mat( ReadVal( paramFile{1}{PLine+2}, 'integer', 1, 'NamesLine'    , 'The row with the channel names on it.', UnEc ) );
   FileInfo.UnitsLine     = cell2mat( ReadVal( paramFile{1}{PLine+3}, 'integer', 1, 'UnitsLine'    , 'The row with the channel units on it.', UnEc ) );
   FileInfo.FirstDataLine = cell2mat( ReadVal( paramFile{1}{PLine+4}, 'integer', 1, 'FirstDataLine', 'The first row of data.', UnEc                ) );

   if ( FileInfo.NamesLine > 0 )
      FileInfo.AutoNames = true;
      FileInfo.HaveNames = true;
   else
      FileInfo.AutoNames = false;
      FileInfo.HaveNames = false;
   end % if

   if ( FileInfo.UnitsLine > 0 )
      FileInfo.AutoUnits = true;
      FileInfo.HaveUnits = true;
   else
      FileInfo.AutoUnits = false;
      FileInfo.HaveUnits = false;
   end % if

   if ( FileInfo.HaveNames && ( FileInfo.TitleLine >= FileInfo.NamesLine ) )
      beep
      if ( EchoInp )
         fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
         fclose( UnEc );
      end % if
      fclose( UnPa );
      error( '  NamesLine (%d) must be greater than TitleLine (%d) unless NamesLine is zero.', FileInfo.NamesLine, FileInfo.TitleLine );
   end % if

   if ( ( FileInfo.UnitsLine > 0 ) && ( FileInfo.TitleLine >= FileInfo.UnitsLine ) )
      beep
      if ( EchoInp )
         fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
         fclose( UnEc );
      end % if
      
      error( '  UnitsLine (%d) must be greater than TitleLine (%d) unless UnitsLine is zero.', FileInfo.UnitsLine, FileInfo.TitleLine );
   end % if

   if ( ( FileInfo.UnitsLine > 0 ) && ( FileInfo.NamesLine >= FileInfo.UnitsLine ) )
      beep
      if ( EchoInp )
         fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
         fclose( UnEc );
      end % if
     
      error( '  UnitsLine (%d) must be greater than NamesLine (%d) unless UnitsLine is zero.', FileInfo.UnitsLine, FileInfo.NamesLine );
   end % if

   if ( FileInfo.TitleLine >= FileInfo.FirstDataLine )
      beep
      if ( EchoInp )
         fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
         fclose( UnEc );
      end % if
     
      error( '  FirstDataLine (%d) must be greater than TitleLine (%d).', FileInfo.FirstDataLine, FileInfo.TitleLine );
   end % if

   if ( FileInfo.NamesLine >= FileInfo.FirstDataLine )
      beep
      if ( EchoInp )
         fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
         fclose( UnEc );
      end % if
      
      error( '  FirstDataLine (%d) must be greater than NamesLine (%d).', FileInfo.FirstDataLine, FileInfo.NamesLine );
   end % if

   if ( FileInfo.UnitsLine >= FileInfo.FirstDataLine )
      beep
      if ( EchoInp )
         fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
         fclose( UnEc );
      end % if
      
      error( '  FirstDataLine (%d) must be greater than UnitsLine (%d).', FileInfo.FirstDataLine, FileInfo.UnitsLine );
   end % if

   PLine = PLine + 6;

   if ( EchoInp )
      fprintf( UnEc, '%s\n', paramFile{1}{12} );
      fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
   end % if

   if ( FileInfo.UserNames )

      FileInfo.HaveNames = true;
      FileInfo.HaveUnits = true;

      for Chan=1:FileInfo.NumChans

         temp = textscan( paramFile{1}{PLine+Chan}, '%q %q %f %f %d', 1 );

         FileInfo.ChanNames  (Chan) = temp{1};
         FileInfo.Units  (Chan) = temp{2};
         FileInfo.Scales (Chan) = temp{3};
         FileInfo.Offsets(Chan) = temp{4};
         if ~( isempty(temp{5}) )
            FileInfo.PSFtype(Chan) = temp{5};   % This is new  need to verify, what if nothing is present?
         else
            FileInfo.PSFtype(Chan) = 0;
         end
         if ( EchoInp )
            fprintf( UnEc, '%s\n', paramFile{1}{PLine+Chan} );
         end % if

      end % for Chan

      PLine = PLine + FileInfo.NumChans + 1;

   else
      % We are going to defer obtaining the Channel names and Units, etc.
      PLine = PLine + 1;

   end % if


      %=================================================================
      % Read the calculated-channels information.
      %=================================================================

   if ( EchoInp )
      fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
      fprintf( UnEc, '%s\n', paramFile{1}{PLine+1} );
   end % if

   Seed     = cell2mat( ReadVal( paramFile{1}{PLine+2}, 'integer', 1, 'Seed'    , 'The integer seed for the random number generator.', UnEc ) );
   PLine    = PLine + 3;

   if ( EchoInp )
      fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
   end % if

   FileInfo.CalcChan = repmat( struct( 'Name','', 'Units','', 'Eqn','' ), 1, double( FileInfo.NumCChan ) );
   sourceChannels = [];
   for Chan=1:FileInfo.NumCChan
      temp = ReadVal( paramFile{1}{PLine+Chan}, 'string' , 3, '', '', UnEc );
      FileInfo.CalcChan(Chan).Name  = temp{1};
      FileInfo.CalcChan(Chan).Units = temp{2};
      FileInfo.CalcChan(Chan).Eqn   = temp{3};
      sourceChannels = union(sourceChannels,find_source_channels(FileInfo.CalcChan(Chan).Eqn));
      
   end
   
   %if ( FileInfo.NumCChan > 0 )
   %   FileInfo.ChanNames = { FileInfo.ChanNames{:}, FileInfo.CalcChan(:).Name };
   %end
   PLine = PLine + FileInfo.NumCChan + 1;


      %=================================================================
      % Read the information for statistics and extreme events.
      %=================================================================

   if ( EchoInp )
      fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
   end % if

   SettingsData.NumEETables = cell2mat( ReadVal( paramFile{1}{PLine+1}, 'integer', 1, 'NumEETables'  , 'Number of tables of extreme events.', UnEc                                                     ) );
   SettingsData.NumEECharts = cell2mat( ReadVal( paramFile{1}{PLine+2}, 'integer', 1, 'NumEECharts'  , 'Number of charts of extreme events.', UnEc                                                     ) );
   FileInfo.FindPeaks       = cell2mat( ReadVal( paramFile{1}{PLine+3}, 'logical', 1, 'FindPeaks'    , 'Should we use the peak finder?', UnEc                                                          ) );
   FileInfo.TimeChan        = cell2mat( ReadVal( paramFile{1}{PLine+4}, 'integer', 1, 'TimeChan'     , 'The time step channel (used for computing average extreme values, 0 for none)', UnEc           ) );
   FileInfo.WSChan          = cell2mat( ReadVal( paramFile{1}{PLine+5}, 'integer', 1, 'WSChan'       , 'The primary wind-speed channel (used for mean wind speed and turbulence intensity, 0 for none)', UnEc ) );
   SettingsData.WSmin       = cell2mat( ReadVal( paramFile{1}{PLine+6}, 'float'  , 1, 'WSmin  '      , 'Minimum wind speed to use when binning extreme events.  Input time series with mean wind speeds less than WSmin will be discarded', UnEc ) );
   SettingsData.WSmax       = cell2mat( ReadVal( paramFile{1}{PLine+7}, 'float'  , 1, 'WSmax  '      , 'Maximum wind speed to use when binning extreme events.  Input time series with mean wind speeds greater than WSmax will be discarded', UnEc ) );
   SettingsData.WSMaxBinSize= cell2mat( ReadVal( paramFile{1}{PLine+8}, 'float'  , 1, 'WSMaxBinSize' , 'Maximum wind speed bin width.', UnEc                                                           ) );
   SettingsData.ScatterPlots= cell2mat( ReadVal( paramFile{1}{PLine+9}, 'logical', 1, 'ScatterPlots' , 'Generate Scatter Plots of Extreme Events?', UnEc                                    ) );
   SettingsData.PlotFormat  = cell2mat( ReadVal( paramFile{1}{PLine+10}, 'integer', 1, 'PlotFormat'   , 'Format for saving any of the requested ScatterPlots or Charts. [ 1 = PNG, 2 = MatLab figure ]', UnEc ) );
   SettingsData.WrEEvtsTxt  = cell2mat( ReadVal( paramFile{1}{PLine+11},'logical', 1, 'WrEEvtsTxt'   , 'Write the extreme-event tables to a plain-text file?', UnEc                                    ) );
   SettingsData.WrEEvtsXLS  = cell2mat( ReadVal( paramFile{1}{PLine+12}, 'logical', 1, 'WrEEvtsXLS'   , 'Write the extreme-event tables to an Excel file?', UnEc                                       ) );
   SettingsData.XLStype     = cell2mat( ReadVal( paramFile{1}{PLine+13}, 'string' , 1, 'XLStype'      , 'Type of Excel file (xls=2003, xlsx=2007).', UnEc                                              ) );
   SettingsData.ThemeColor  = cell2mat( ReadVal( paramFile{1}{PLine+14}, 'integer', 1, 'ThemeColor'   , 'Excel color theme to use.  In Excel 2007, it is the column of the color chart (1-8).', UnEc   ) );
   SettingsData.HeadTnS     = cell2mat( ReadVal( paramFile{1}{PLine+15}, 'float'  , 1, 'HeadTnS'      , 'Tint and shade of the header area (-1.0 to 1.0), with -1 being darkest and 1 lightest.', UnEc ) );
   SettingsData.DiagTnS     = cell2mat( ReadVal( paramFile{1}{PLine+16}, 'float'  , 1, 'DiagTnS'      , 'Tint and shade of the diagonal (-1.0 to 1.0), with -1 being darkest and 1 lightest.', UnEc    ) );

   if ( EchoInp )
      fprintf( UnEc, '%s\n', paramFile{1}{PLine+17} );
   end % if

   if ( SettingsData.NumEETables < 1 && SettingsData.NumEECharts < 1 && ~SettingsData.ScatterPlots && ~SettingsData.saveState )
      beep
      if ( EchoInp )
         fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
         fclose( UnEc );
      end % if
     
      error( '  You are not saving data via the @Save command, and NumEETables = NumEECharts = 0 and you are not requesting ScatterPlots. You have not requested MExtremes to produce any results!', SettingsData.NumEETables );
   end % if

   if ( ( SettingsData.WrEEvtsTxt == false ) && ( SettingsData.WrEEvtsXLS == false ) && (SettingsData.NumEECharts == 0) && ~SettingsData.ScatterPlots && ~SettingsData.saveState )
      beep
      if ( EchoInp )
         fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
         fclose( UnEc );
      end % if
      
      error( '  ScatterPlots, WrEEvtsTxt, WrEEvtsXLS, cannot all be false if NumEECharts is also zero, and you are not using the @Save command.  At least one must be true or NumEECharts must be greater than zero.' );
   end % if

   if ( ( SettingsData.PlotFormat < 1 ) || ( SettingsData.PlotFormat > 2 ) )
      beep
      if ( EchoInp )
         fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
         fclose( UnEc );
      end % if
     
      error( '  PlotFormat must be 1 (PNG) or 2 (MatLab figure).' );
   end % if
   
   if ( ( SettingsData.ThemeColor < 1 ) || ( SettingsData.ThemeColor > 10 ) )
      beep
      if ( EchoInp )
         fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
         fclose( UnEc );
      end % if
     
      error( '  ThemeColor must be between 1 and 10 (inclusive).' );
   end % if

   if ( ( SettingsData.HeadTnS < -1.0 ) || ( SettingsData.HeadTnS > 1.0 ) )
      beep
      if ( EchoInp )
         fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
         fclose( UnEc );
      end % if
     
      error( '  HeadTnS must be between -1.0 and 1.0 (inclusive).' );
   end % if

   if ( ( SettingsData.DiagTnS < -1.0 ) || ( SettingsData.DiagTnS > 1.0 ) )
      beep
      if ( EchoInp )
         fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
         fclose( UnEc );
      end % if
     
      error( '  DiagTnS must be between -1.0 and 1.0 (inclusive).' );
   end % if

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   EEvTable = repmat( struct( 'Name','', 'Chans',0, 'InfChans',0 ), 1, double( SettingsData.NumEETables ) );
   
   PLine = PLine + 17;

   
   for Tab=1:SettingsData.NumEETables

      temp = textscan( paramFile{1}{PLine+Tab}, '%q %f', 1 );

      if ( EchoInp )
         fprintf( UnEc, '%s\n', paramFile{1}{PLine+Tab} );
      end % if

      EEvTable(Tab).Name = temp{1}{1};
      if ( ( ~validate_excel_worksheet_name(EEvTable(Tab).Name) ) && SettingsData.WrEEvtsXLS )
         if ( EchoInp )
            fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
            fclose( UnEc );
         end % if
         
         error('Table name, %s, cannot exceed 31 characters or contain any of the characters  * \\ / ? [ ] : ',EEvTable(Tab).Name);
      end
      NumChans           = temp{2};

      Fmt = [ '%*q %*f', repmat( ' %f', 1, NumChans ), ' %f' ];   % No commas allowed in channel list!

      EEvTable(Tab).Chans = cell2mat( textscan( paramFile{1}{PLine+Tab}, Fmt, 1 ) );
      NumInfoChans        = EEvTable(Tab).Chans(NumChans+1);
      EEvTable(Tab).Chans = EEvTable(Tab).Chans(1:NumChans);

      Fmt = [ '%*q %*f', repmat( ' %*f', 1, NumChans+1 ), repmat( ' %f', 1, NumInfoChans ) ];   % No commas allowed in channel list!

      EEvTable(Tab).InfChans = cell2mat( textscan( paramFile{1}{PLine+Tab}, Fmt, 1 ) );

   end % for Tab

if ( SettingsData.NumEETables > 0 )
      % Let's get a list of all the unique (some may be used in more than one table) EE channels we will need to process.

   SettingsData.EETableChans = EEvTable(1).Chans;
   SettingsData.EETableInfChans = EEvTable(1).InfChans;
   for Tab=2:SettingsData.NumEETables
       SettingsData.EETableChans = [ SettingsData.EETableChans, EEvTable(Tab).Chans ];
       SettingsData.EETableInfChans = [SettingsData.EETableInfChans, EEvTable(Tab).InfChans];
   end % for Tab

   SettingsData.EETableChans                = unique( SettingsData.EETableChans );
   SettingsData.EETableInfChans                = unique( SettingsData.EETableInfChans );
   %NumUnEEChans           = size( SettingsData.EETableChans, 2 );
   AllChans               = ( 1:FileInfo.TotalChans );
   [ ~, SettingsData.EEChanLocs ] = ismember( AllChans, SettingsData.EETableChans );
   [ ~, SettingsData.EEInfChanLocs ]   = ismember( AllChans, SettingsData.EETableInfChans );
   SettingsData.AllEEvChans = SettingsData.EETableChans;
      % For the channels in each EEv table, where are they located in the EEChans array?

%    for Tab=1:SettingsData.NumEETables
%       [ unused, EEvTable(Tab).EEUnChanLocs ] = ismember( EEvTable(Tab).Chans, EETableChans );
%    end % for Tab
end

   PLine = PLine + SettingsData.NumEETables + 1;
   if ( EchoInp )
      fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
   end % if
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Extreme Events Charts
   EEvChart = 0;  % This is needed for the save/restore in case SettingsData.NumEECharts == 0  
   if ( SettingsData.NumEECharts > 0 )
      EEvChart = repmat( struct( 'Name','', 'YLabel','', 'Type',1,'Chans',0  ), 1, double( SettingsData.NumEECharts ) );
      for iChart=1:SettingsData.NumEECharts
         
         temp = textscan( paramFile{1}{PLine+iChart}, '%q %q %q %f', 1 );

         if ( EchoInp )
            fprintf( UnEc, '%s\n', paramFile{1}{PLine+iChart} );
         end % if

         EEvChart(iChart).Name   = temp{1}{1};
         EEvChart(iChart).YLabel = temp{2}{1};
         if ( strcmpi(temp{3}{1},'max_abs') )
              EEvChart(iChart).Type = 1;
         elseif ( strcmpi(temp{3}{1},'max') )
              EEvChart(iChart).Type = 2;
         elseif ( strcmpi(temp{3}{1},'min') )
              EEvChart(iChart).Type = 3;
         else
            %error
         end
              
         NumChans           = temp{4};

         Fmt = [ '%*q %*q %*q %*f', repmat( ' %f', 1, NumChans ) ];   % No commas allowed in channel list!

         EEvChart(iChart).Chans = cell2mat( textscan( paramFile{1}{PLine+iChart}, Fmt, 1 ) );
         EEvChart(iChart).Chans = EEvChart(iChart).Chans(1:NumChans);

      end % for iChart
      
          % Let's get a list of all the unique (some may be used in more than one table) EE channels we will need to process.

      SettingsData.EEChartChans = EEvChart(1).Chans;

      for iChart=2:SettingsData.NumEECharts
          SettingsData.EEChartChans = [ SettingsData.EEChartChans, EEvChart(iChart).Chans ];
      end % for iChart

      SettingsData.EEChartChans                = unique( SettingsData.EEChartChans );
      %SettingsData.NumUnEEChartChans           = size( EEChartChans, 2 );
      AllChans               = ( 1:FileInfo.TotalChans );
     % [ ~, EEChartChanLocs ] = ismember( AllChans, EEChartChans );

     if ( SettingsData.NumEETables > 0 )
         SettingsData.AllEEvChans = union(SettingsData.EETableChans, SettingsData.EEChartChans);
         
     else
        SettingsData.AllEEvChans = SettingsData.EEChartChans;
     end
     
     [ ~, SettingsData.EEChanLocs ] = ismember( AllChans, SettingsData.AllEEvChans );
      
         % For the channels in each EEv table, where are they located in the EEChans array?

%       for iChart=1:SettingsData.NumEECharts
%          [ unused, EEvChart(iChart).EEUnChanLocs ] = ismember( EEvChart(iChart).Chans, AllEEvChans );
%       end % for iChart
%    
%       for Tab=1:SettingsData.NumEETables
%          [ unused, EEvTable(Tab).EEUnChanLocs ] = ismember( EEvTable(Tab).Chans, AllEEvChans );
%       end % for Tab
      
      
   
   end % if ( SettingsData.NumEECharts > 1 )
      %=================================================================
      % Read the list of input files.
      %=================================================================
   PLine = PLine + SettingsData.NumEECharts + 1;
   if ( EchoInp )
      fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
   end % if
   %TODO: FIX The following with stored line number!!!
  % if (SettingsData.restoreState)
  %    PLine = PLine + 1;
  % end
   FileInfo.FileFormat = cell2mat( ReadVal( paramFile{1}{PLine+1}, 'integer', 1, 'FileFormat', 'Flag determining input file format.  1 = ascii, 2 = binary', UnEc ) );
   FileInfo.NumDLCs    = cell2mat( ReadVal( paramFile{1}{PLine+2}, 'integer', 1, 'NumDLCs',  'The number of Design Load Cases.', UnEc                           ) );
   PLine = PLine + 3;
  
   
   
   iCount = 1;
   for iDLC = 1:FileInfo.NumDLCs
      
      % Data has actually already been read up above in this routine
      
         
      if ( EchoInp )
         fprintf( UnEc, '%s\n', paramFile{1}{PLine} );
      end
      
      for iFile=1:FileInfo.DLCs(iDLC).NumFiles
         iCount = iCount + 1;
         
  
         if ( EchoInp )
            fprintf( UnEc, '%s\n', paramFile{1}{PLine + iFile} );
         end
         
         
         
      end % for File
      PLine = PLine + FileInfo.DLCs(iDLC).NumFiles + 1;

   end % for iDLC
   
   if ( EchoInp )
      iCount = 1;
      if (SettingsData.restoreState)
         iCount = iCount + 1;
      end
      if (SettingsData.saveState)
         iCount = iCount + 1;
      end   
      for iLine=1:iCount
         fprintf( UnEc, '%s\n', paramFile{1}{PLine+iLine-1} );
      end
      fclose( UnEc );
   end % if
   

       % All the unique channels which are used in both the tables and charts without considering the table information channels
   if (SettingsData.NumEECharts + SettingsData.NumEETables  > 0 ) 
      SettingsData.nEEvChans         = length(SettingsData.AllEEvChans);
   
      if (SettingsData.NumEETables > 0 )
         % All the unique channels used in both the tables and charts including the information channels
         SettingsData.AllEEPlusInfChans = [SettingsData.AllEEvChans, SettingsData.EETableInfChans];
      else
         SettingsData.AllEEPlusInfChans = SettingsData.AllEEvChans;
      end
      
      SettingsData.nEEvInfPlusChans  = length(SettingsData.AllEEPlusInfChans);
   end
   
   return

end