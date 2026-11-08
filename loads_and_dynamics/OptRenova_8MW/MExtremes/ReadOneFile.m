function [FileInfo, errStat, errMsg] = ReadOneFile( File, iDLC, FileInfo, Settings, FirstPass )
% Read one data file into the FileInfo structure.
%
% Notes:
%
%     Titles, names, and units must all be before the data and in that order.
%     Set TitleLine, NamesLine, and/or UnitsLine to zero if they do not exist.
%
%BUG: This routine assumes that there are at least 50 lines of data in each file.
%
% The created global structure has the following format:
%
%     FileInfo.TimeChan  - integer
%             .WSChan    - integer
%             .TotLines  - integer
%             .Title     - string array
%             .StartLine - integer
%             .NumLines  - integer
%             .Names     - cell array with NumCols+NumCChan strings
%             .Units     - cell array with NumCols+NumCChan strings
%             .FileName  - string array
%             .Time      - matrix with TotLines by NumCols+NumCChan single-precision data
%             .Stats     - array with 1 by NumCols doubles
%             .Scales    - array with 1 by NumCols doubles
%             .Offsets   - array with 1 by NumCols doubles
%             .PSFtype   - array with 1 by NumCols integers
%
% Syntax: ReadOneFile( File, TitleLine, NamesLine, UnitsLine, FirstDataLine, CalcChan )
%
%     where:
%        File           - A cell array containing a file name.
%        FileFormat     - Format of input file, 1 = ascii, 2 = binary
%        iDLC           - Design Load Case index which this file belongs to.
%        TitleLine      - A double scalar telling the number of the line that contains the
%                         file's descriptive title line.  Set to zero if there is none.
%        NamesLine      - A double scalar telling the number of the line that contains the
%                         channel names.  Set to zero if there is none.
%        UnitsLine      - A double scalar telling the number of the line that contains the
%                         channel units.  Set to zero if there is none.
%        FirstDataLine  - A double scalar telling the number of the line that contains the
%                         file's first line or data.
%        CalcChan       - A structure array containing information for generating calculated
%                         channels.  It must have the following format (all are strings):
%                              CalcChan(Chan).Name  - The calculated channel's name.
%                              CalcChan(Chan).Units - The calculated channel's units.
%                              CalcChan(Chan).Eqn   - The calculated channel's equation.
%        FirstPass      - A flag to allow doing some logic only the first time through.
%        AllEEvChans    - A list of all channel indices which are included in a table or chart
%        FindPeaks      - Should the peak finder be used? 0 = no, 1 = yes.
%
% Example:
%     ReadOneFile( 'FAST_Results.out', 2, 4, 5, 6, CalcChan, FirstPass )
%
% See also MExtremes, ReadSettings


   
   errStat = 0;
   errMsg  = '';

      % Estimate the number of lines in the files.

   LinePad   = 1.03;
   SampLines = uint32( 10 );


      % Preallocate some branches of the FileInfo structure.

   FileInfo.Title     = cell( 1 );
%   FileInfo.StartLine = zeros( 1, 1 );
%   FileInfo.NumLines  = zeros( 1, 1 );


      % How many calculated channels do we have?

   %NumCC = size( FileInfo.CalcChan, 2 );


      % Estimate the total number of lines.

   Info = dir( File{1} );

   if ( size( Info, 1 ) == 0 )
      beep
      error( '  Could not open "%s" for reading.', File{1} );
   end

   FileSize = Info.bytes;
   %NumCols = size( FileInfo.ChanNames, 2 );
   % NumIC   = NumCols - NumCC;
   FileInfo.FileName = File{1};

    % is the file is binary format?
   if ( FileInfo.FileFormat == 2 ) 
      [FileInfo.Time, ~, CellUnits, FileID] = ReadFASTbinary(File{1});
      FileInfo.Title = '';
      if ( FirstPass )
         if ( FileInfo.AutoUnits )            
            FileInfo.Units = { CellUnits{1}{:} };
         end % if ( FileInfo.HaveUnits )

         if ( ( FileInfo.NumCChan > 0 ) && FileInfo.HaveUnits )
            FileInfo.Units = { FileInfo.Units{:}, FileInfo.CalcChan(:).Units };
         end % if ( ( FileInfo.NumCChan > 0 ) && FileInfo.HaveUnits )

      end % if ( FrstPass )
      
   else
         % wasn't binary format, try ascii
      fid = fopen( File{1}, 'rt' );

      if ( fid < 0 )
         beep
         error( '  Could not open "%s" for reading.', File{1} );
      end


         % Skip header lines.  Read first SampLines data lines.  Get total number of characters.
         % Estimate total number of lines in file and multiply by LinePad.

      HeadLines = textscan( fid, '%s', FileInfo.FirstDataLine-1, 'delimiter', '\n' );
      HeadSize  = uint32( 0 );

      for L=1:FileInfo.FirstDataLine-1
         HeadSize = HeadSize + size( HeadLines{1,1}{L}, 2 );
      end

      DataLines = textscan( fid, '%s', SampLines, 'delimiter', '\n' );

      if ( size( DataLines{1,1}, 1 ) > SampLines )

         SampSize  = uint32( 0 );

         for L=1:SampLines
            SampSize = SampSize + size( DataLines{1,1}{L}, 2 );
         end

         FileInfo.NumLines = LinePad*SampLines*( FileSize - HeadSize )/SampSize;

      else

         FileInfo.NumLines = size( DataLines{1,1}, 1 );

      end % if

      fclose( fid );


         % If first pass, get the channel names and units from the header.

      if ( FirstPass )

   %       if ( FileInfo.AutoNames )
   %          CellNames      = textscan( HeadLines{1}{FileInfo.NamesLine}, '%s' );
   %          FileInfo.Names = { CellNames{1}{:} };
   %          NumCols        = size( FileInfo.Names, 2 );
   %       end % if
   %      NumIC        = size( FileInfo.ChanNames, 2 ) - NumCC;
   %       if ( ( NumCC > 0 ) && FileInfo.HaveNames )
   %          FileInfo.Names = { FileInfo.Names{:}, FileInfo.CalcChan(:).Name };
   %       end % if ( NumCC > 0 )

         if ( FileInfo.AutoUnits )
            CellUnits      = textscan( HeadLines{1}{FileInfo.UnitsLine}, '%s', FileInfo.NumChans );
            FileInfo.Units = { CellUnits{1}{:} };
         end % if ( FileInfo.HaveUnits )

         if ( ( FileInfo.NumCChan > 0 ) && FileInfo.HaveUnits )
            FileInfo.Units = { FileInfo.Units{:}, FileInfo.CalcChan(:).Units };
         end % if ( ( NumCC > 0 ) && FileInfo.HaveUnits )

      end % if ( FrstPass )

      
      

         % Allocate the file information arrays.  Reset the total number of lines.

      FileInfo.Time     = zeros( FileInfo.NumLines, FileInfo.TotalChans, 'single' );


         % Open a FAST-style data file.

      fid = fopen( File{1}, 'rt' );

      if ( fid < 0 )
         beep
         error( '  Could not open "%s" for reading.', File{1} );
      end

      fprintf( '  Reading "%s" (%f MB).\n', File{1}, FileSize/1024^2 );


         % Get the title line from header.  Store the starting line number for this file.

      HeadLines = textscan( fid, '%s', FileInfo.FirstDataLine-1, 'delimiter', '\n' );

      if ( FileInfo.TitleLine > 0 )
         FileInfo.Title = HeadLines{1}{FileInfo.TitleLine};
      end % if


         % Read the numeric data and store it in the time-series matrix.

      %TextData = textscan( fid, '' );
      temp = textscan(fid,repmat('%f ',1,FileInfo.NumChans),'CollectOutput',1);     
      FileInfo.Time = temp{1};
      temp =0;
      
         % Close the data file.

      fclose ( fid );
      
   end % if FileInfo.FileFormat
       
   
   if ( size( FileInfo.Time, 2 ) ~= FileInfo.NumChans )
      beep
      error( sprintf( [ '\n  Do you have white space in any of your channel names?  The number\n', ...
                        '  of channels expected differs from what is in the first file.\n' ] ) );
   end % if
   
   FileInfo.NumLines = size( FileInfo.Time, 1 );


      % If we specified the channel information in the parameter input file, we may need scales and offsets.
      % If the channel names came from the data files, we do not have that option.

   if ( FileInfo.UserNames )
      FileInfo.Time = repmat(FileInfo.Scales,FileInfo.NumLines,1).*FileInfo.Time + repmat(FileInfo.Offsets,FileInfo.NumLines,1);
      posPSF =  FileInfo.PSFtype > 0 ;
      if (sum(posPSF) > 0 )
         FileInfo.Time(:,posPSF) = FileInfo.Time(:,posPSF) .* repmat(FileInfo.DLCs(iDLC).PSF(FileInfo.PSFtype(posPSF)),FileInfo.NumLines,1);
      end
      %       if ( FileInfo.PSFtype(Col) > 0 )
%          FileInfo.Time = FileInfo.Time .* repmat(Settings.DLCs(iDLC).PSF(FileInfo.PSFtype),FileInfo.NumLines,1);
%       end
      %       for Col=1:NumIC
%          for Row=1:FileInfo.NumLines
%             FileInfo.Time(Row,Col) = FileInfo.Scales(Col)*single( TextData{Col}(Row) ) + FileInfo.Offsets(Col);
%             if ( FileInfo.PSFtype(Col) > 0 )
%                FileInfo.Time(Row,Col) = FileInfo.Time(Row,Col) * Settings.DLCs(iDLC).PSF(FileInfo.PSFtype(Col));
%             end
%          end % for Row
%       end % for Col
%   else
   %   FileInfo.Time(1:FileInfo.NumLines,1:NumIC) = single( [ TextData{:} ] );
   end % if

   fprintf( '    Rows=%d, Cols=%d\n', FileInfo.NumLines, FileInfo.TotalChans );


      
     
      
   % Perform peak finding on the non-calculated channels
   if ( FileInfo.FindPeaks )
     
          % Only filter the non-calculated channels 
      filterChans = [1:FileInfo.NumChans];
      FileInfo.Time(:,filterChans) = PeakFind( FileInfo.Time(:,filterChans) );
      

   end % if ( Settings.FindPeaks )

      % Add the calculated-channel data.

%   if ( NumCC > 0 )
%      for CC=1:NumCC
%         FileInfo.Time(:,NumIC+(CC)) = cell2mat( arrayfun( @(Chan)eval( FileInfo.CalcChan(Chan).Eqn ), CC, 'UniformOutput', false ) );
%      end % for CC
%   end % if ( NumCC > 0 )


      % Man, that was confusing, let's do it in a more-readable way.

   for Chan=1:FileInfo.NumCChan
      FileInfo.Time(:,FileInfo.NumChans+Chan) = eval( FileInfo.CalcChan(Chan).Eqn );      
   end % for


      % Delete the unused rows from the time series.

   FileInfo.Time((FileInfo.NumLines+1):size(FileInfo.Time,1),:) = [];


   fprintf( '  Done\n' );

   return

end % function ReadManyFiles
