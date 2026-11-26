function [ FileInfo, errStat, errMsg ] = GrabInputFileHeaderInfo( FileInfo )
   errStat = 0;
   errMsg  = '';
   dataFileName = FileInfo.FileList{1,1};
   if (FileInfo.FileFormat == 2)
      try
         [Channels, ChanNames, ChanUnit, FileID] = ReadFASTbinary(dataFileName);
         FileInfo.ChanNames = { ChanNames{:} };  % convert to needed format
         FileInfo.Units = { ChanUnit{:} };  % convert to needed format
         FileInfo.NumChans   = size( Channels, 2 );
      catch err
      end
   else
            
      % try ascii
      fidData = fopen( FileInfo.FileList{1}, 'rt' );

      while ( fidData < 0 )
         beep;
         %HdlDgl = warndlg( sprintf( 'Please close "%s" if it is open in another program such as Excel.', DataFileName ), 'File Locked!', 'replace' );
         choice = questdlg( sprintf( 'Please close "%s" if it is open in another program such as Excel.', dataFileName ), 'File Locked!', 'Retry','Abort','Retry' );
         %uiwait( HdlDgl );
         switch (choice)
            case 'Retry'     
               fidData = fopen( dataFileName, 'rt' );
            case 'Abort'
               error('Aborting MExtremes, unable to open file: %s.\n',dataFileName);
         end
      end % while

      if (FileInfo.NamesLine > 0 )
         HeadLines  = textscan( fidData, '%s', FileInfo.NamesLine, 'delimiter', '\n' );
      end
      DataLines =  textscan( fidData, '%s', FileInfo.FirstDataLine, 'delimiter', '\n' );
      fclose( fidData );
      temp       = textscan( DataLines{1}{FileInfo.FirstDataLine}, '%s' );
      FileInfo.NumChans   = size( temp{1}, 1 );
      FileInfo.ChanNames  = cell( 1, FileInfo.NumChans );
      if (FileInfo.NamesLine > 0 )
         temp       = textscan( HeadLines{1}{FileInfo.NamesLine}, '%s' );


         for Ch=1:FileInfo.NumChans
            FileInfo.ChanNames{Ch} = temp{1}{Ch};
         end % for Ch
      else
         % Set channel names using a default naming convention
         for Ch=1:FileInfo.NumChans
            FileInfo.ChanNames{Ch} = sprintf('Chan%d',Ch);
         end % for Ch
      end
      FileInfo.ChanNames = FileInfo.ChanNames; 
   end  
   
      % Add the calculated channel names to the list of channels.

  % for Ch=1:FileInfo.NumCChan
  %    FileInfo.ChanNames{FileInfo.NumChans+Ch} = FileInfo.CalcChan(Ch).Name;
  %    FileInfo.Units{FileInfo.NumChans+Ch} = FileInfo.CalcChan(Ch).Units;
  % end % for

end