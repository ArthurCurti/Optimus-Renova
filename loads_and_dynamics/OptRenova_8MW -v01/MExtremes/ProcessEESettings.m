function [FileInfo, errStat, errMsg] = ProcessEESettings( FileInfo, FileInfoRestored )

   if (nargout < 3)
      error('ProcessEESettings requires 3 outputs: FileInfo, errStat, and errMsg');
   end
   
   errStat = 0;
   errMsg  = '';
   
   %if ( ~FileInfo.UserNames )
   %   % Need to grab channel names and units from one of the input files
   %   [ FileInfo, errStat, errMsg ] = GrabInputFileHeaderInfo( FileInfo );
      
   %end
   
   if (nargin == 2)
   
   
   % First we need to check if there is data we will be restoring.  And
   % we'll compare the saved FileInfo structure with that one we generated
   % via the settings file.  
      
      % Verify same settings are being used for this new run.

      [errStat, errMsg] = verify_fileinfo( FileInfo, FileInfoRestored );
      if ( errStat > 0 )
         return
      end

      
         % append restore with current

      FileInfo.iFileOffset =  FileInfoRestored.iFileOffset;
      FileInfo.TotalFiles  =  FileInfo.TotalFiles + FileInfoRestored.TotalFiles;
      FileInfo.FileList    =  [FileInfoRestored.FileList; FileInfo.FileList];
      
         % Process new DLC entries and match them to previous entries if
         % possible
      foundDLC = zeros(FileInfo.NumDLCs,1);
      for iDLC=1:FileInfo.NumDLCs
         for oldDLC=1:FileInfoRestored.NumDLCs
            startIndex = regexpi(FileInfo.DLCs(iDLC).DLC_Name, FileInfoRestored.DLCs(oldDLC).DLC_Name);
            if ( ~isempty( startIndex ) )   
               foundDLC(iDLC) = oldDLC;  % ASSUMES UNIQUE LABELS FOR OLD DLCs
               % Verify that the PSFs match
               for j=1:4
                  if (FileInfo.DLCs(iDLC).PSF(j) ~= FileInfoRestored.DLCs(oldDLC).PSF(j))
                     errMsg2 = sprintf('The partial safety factor in the "%s" DLC does not match the restored value.  New has: %f, Restored has: %f\n',...
                        FileInfo.DLCs(iDLC).DLC_Name, FileInfo.DLCs(iDLC).PSF(j),FileInfoRestored.DLCs(oldDLC).PSF(j));
                     errMsg = [errMsg, errMsg2];
                     errStat = 4;
                  end
               end
               if (errStat > 0)
                  return
               end
            end
         end        
      end
      newDLCs = FileInfoRestored.DLCs;
      newNumDLCs = FileInfoRestored.NumDLCs;
      iNewDLCIndx = FileInfoRestored.NumDLCs + 1;
      newDLCMask = FileInfoRestored.DLCMask;
      for iDLC=1:FileInfo.NumDLCs
         if (foundDLC(iDLC) > 0 )
            origNum = newDLCs(foundDLC(iDLC)).NumFiles;
            newNum  = FileInfo.DLCs(iDLC).NumFiles;
            if (newNum > 0 )
               % We are adding files to this existing DLC, the location of
               % these files in the overall master list of files
               % (FileInfo.FileList) is given by the fileIndx array
               newDLCs(foundDLC(iDLC)).fileIndx(origNum+1:origNum+newNum) = FileInfo.DLCs(iDLC).fileIndx + FileInfoRestored.iFileOffset - 1;
            end   
            newDLCs(foundDLC(iDLC)).NumFiles = origNum + newNum;
            newDLCs(foundDLC(iDLC)).BinModel  = FileInfo.DLCs(iDLC).BinModel;
            FileInfo.DLCMask(newDLCs(foundDLC(iDLC)).fileIndx) = foundDLC(iDLC);
         else
            if (FileInfo.DLCs(iDLC).NumFiles > 0 )
                  % add this new to the end of the newDLCs array
               newDLCs(iNewDLCIndx) =  FileInfo.DLCs(iDLC);
               newDLCs(iNewDLCIndx).fileIndx = FileInfo.DLCs(iDLC).fileIndx + FileInfoRestored.iFileOffset - 1;
                  % create DLCMask entries for all the files associated with
                  % this DLC

               newDLCMask.DLCMask(newDLCs(iNewDLCIndx).fileIndx) = iNewDLCIndx;
               iNewDLCIndx = iNewDLCIndx  + 1;
            end
         end
         
      end
      FileInfo.DLCs = newDLCs;
      FileInfo.NumDLCs = iNewDLCIndx - 1;
      FileInfo.DLCMask = newDLCMask;
   end % if we are processing a restored save file
   
   
   % We need to search for DLCs which do not contain any files and remove
   % them
   goodDLCs = ones(FileInfo.NumDLCs,1);
   goodDLCcount = 0;
   for iDLC = 1:FileInfo.NumDLCs
      fileInds = find(FileInfo.DLCMask == iDLC);
      if ( isempty(fileInds) )
         goodDLCs(iDLC) = 0;
      else
         goodDLCcount = goodDLCcount + 1;
      end
   end
   if (goodDLCcount == 0)
      errMsg = 'None of the DLCs contain any files!';
      errStat = 4;
      return
   end
   goodDLCInds = find(goodDLCs == 1);
   FileInfo.DLCs = FileInfo.DLCs(goodDLCInds);
   FileInfo.NumDLCs = goodDLCcount;
   % Now process the remaining parameters for self-consistency

   FileInfo.BinEvents = false;
   
   for iDLC=1:FileInfo.NumDLCs
      if (FileInfo.DLCs(iDLC).BinModel > 0 ) 
         FileInfo.BinEvents = true;
      end
   end

end