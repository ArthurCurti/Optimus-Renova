function [Results, errStat, errMsg] = ProcessExtremes(nEEvChans, AllEEvChans, ChanNames, ChanMinAssocValues, ChanMaxAssocValues, NumDLCs, DLCs, DLCMask, BinEvents, ElapsedTime, WSmin, WSmax, WSMaxBinSize, FileMeanWindSpeed)

   %-------------------------------------------------------------------
   % BinModel - On a DLC-basis  and within a DLC, on a Windspeed-bin basis            
   %
   %   0	:  Do not bin extremes, instead take the extreme value across all DLCs for a given channel 
   %        (after applying any partial safety factors).  And a single extreme for a given DLC.
   %   1	:  On a DLC-basis, attach each input file (of a given DLC) to a wind speed bin.  Find the 
   %        extremes for each input file within a DLC and then sort these using wind speed bins.  
   %        Find the mean of the extremes for a given bin, and then find the ‘nearest’ actual extreme 
   %        to this mean.  This becomes the extreme value of the bin.  Then find the overall extreme 
   %        value for the DLC based on these mean values.  For max extremes take the closest extreme 
   %        which is larger than the mean.  For min extremes take the closest extreme which is smaller 
   %        than the mean. Also, for plotting and simplified reporting we will include the calculated mean 
   %        value, in addition to the closest actual data value to the mean.  We need the closest actual 
   %        value in order to report information about the event (when the event occurred in the dataset 
   %        as well as the values of other channels at that time)
   %   2	:  For DLC 2.1, 2.2 and 5.1, the extreme value will be based on Model 1, except that only the largest half 
   %        of the bin extremes will be used when computing the mean of the max and only the smallest half 
   %        of the bin extremes will be used when computing the mean of the min.
   %-------------------------------------------------------------------
      
   errStat           = 0;
   errMsg            = '';
   
      % Values of the overall minimum and maximum calculated extremes
   Results.MinInds = zeros(nEEvChans,1);
   Results.MaxInds = zeros(nEEvChans,1);
   Results.MinVals = zeros(nEEvChans,1) + 9e13;
   Results.MaxVals = zeros(nEEvChans,1) - 9e13;  
   
   
   
   
      %  binning files based on the file's mean wind speed?
   
   if ( BinEvents )
      
      MinDLCInds = zeros(nEEvChans,NumDLCs);
      MaxDLCInds = zeros(nEEvChans,NumDLCs);
      
      
      tol = 0.0001;   % tolerance for comparing event values to the computed mean
      
      % Group (bin) the files based on mean windspeed
      Results.NumWSbins      = ceil (( WSmax - WSmin ) / WSMaxBinSize) ;
      Results.WSBinSize      = ( (WSmax - WSmin) / Results.NumWSbins ) ;
      Results.WSBinInds      = ceil( (FileMeanWindSpeed - WSmin) ./ Results.WSBinSize );
      Results.WSBins         = [0:Results.NumWSbins-1]*Results.WSBinSize + 0.5*Results.WSBinSize + WSmin;
      
      Results.KeepBinMinFile = zeros(Results.NumWSbins, nEEvChans, NumDLCs);
      Results.KeepBinMaxFile = zeros(Results.NumWSbins, nEEvChans, NumDLCs);
      Results.MinBinVals     = zeros(Results.NumWSbins, nEEvChans, NumDLCs);
      Results.MaxBinVals     = zeros(Results.NumWSbins, nEEvChans, NumDLCs);
      Results.BinnedFileMins = cell (Results.NumWSbins, nEEvChans, NumDLCs);
      Results.BinnedFileMaxs = cell (Results.NumWSbins, nEEvChans, NumDLCs);
     
      
      
      
      % Loop over the DLCs
      for iDLC = 1:NumDLCs
         DLCFileInds = find(DLCMask == iDLC);
         if (isempty(DLCFileInds))
            continue;
         end
         if ( DLCs(iDLC).BinModel == 0)
               % Find the min and max indices across all files in the DLC
               % without considering windspeed bins
               
            for iChan = 1:nEEvChans
               [MinDLC(iChan,iDLC),tmpInd] = min(ChanMinAssocValues(AllEEvChans(iChan),AllEEvChans(iChan),DLCFileInds));
               MinDLCInds(iChan,iDLC) = DLCFileInds(tmpInd);
               [MaxDLC(iChan,iDLC),tmpInd] = max(ChanMaxAssocValues(AllEEvChans(iChan),AllEEvChans(iChan),DLCFileInds));
               MaxDLCInds(iChan,iDLC) = DLCFileInds(tmpInd);
               
                  % Is this min the smallest, yet 
               if ( MinDLC(iChan,iDLC) < Results.MinVals(iChan) )
                  Results.MinVals(iChan) = MinDLC(iChan,iDLC);
                     %Store the associated event to this min                
                  Results.MinInds(iChan) = MinDLCInds(iChan,iDLC);
               end
               
                  % Is this max the largest, yet 
               if ( MaxDLC(iChan,iDLC) > Results.MaxVals(iChan) )
                  Results.MaxVals(iChan) = MaxDLC(iChan,iDLC);
                     %Store the associated event to this min
                  Results.MaxInds(iChan) = MaxDLCInds(iChan,iDLC);
               end
               
            end
            
         elseif ( DLCs(iDLC).BinModel == 1)
            
            binHasData = zeros(Results.NumWSbins,1);
            
            for iBin = 1:Results.NumWSbins
         
              FileInds = find(Results.WSBinInds == iBin & DLCMask == iDLC); %(WSBinInds == iBin);   
              nBinFiles = sum(Results.WSBinInds == iBin & DLCMask == iDLC);

              if ( nBinFiles > 0 )
                  binHasData(iBin) = 1;
                  TotalElapsedBinTime = sum( ElapsedTime(FileInds) );

                  for iChan = 1:nEEvChans

                     % Compute the mean extreme value for each channel in this bin

                     % NOTE:  This accounts for elasped times of each file when
                     % computing the mean

                        % Mean of Mins for this windspeed bin
                     data = double(reshape(ChanMinAssocValues(AllEEvChans(iChan),AllEEvChans(iChan),FileInds),1,nBinFiles));
                     Results.BinnedFileMins(iBin,iChan,iDLC) = {data};
                     MeanExtremeMin = sum( data .* ElapsedTime(FileInds) ) / double(TotalElapsedBinTime);
                     
                     
                     Results.MinBinVals(iBin, iChan, iDLC)  = MeanExtremeMin;
                     MinDiffs       = data - MeanExtremeMin;                 
                     belowMeanInds  = find( MinDiffs <= tol );
                     
                        % Find closest extreme below mean
                     [~, ind]       = min(abs(MinDiffs(belowMeanInds)));

                        % store the file index that corresponds with the closest smaller value than the calculated mean               
                     Results.KeepBinMinFile(iBin, iChan, iDLC) = FileInds(belowMeanInds(ind)); 

                        % Is this min the smallest, yet 
                     if ( MeanExtremeMin < Results.MinVals(iChan) )
                        Results.MinVals(iChan) = MeanExtremeMin;
                           %Store the associated event to this min                
                        Results.MinInds(iChan) = FileInds(belowMeanInds(ind));
                     end
                             
                        % Mean of Maxes
                     data = double(reshape(ChanMaxAssocValues(AllEEvChans(iChan),AllEEvChans(iChan),FileInds), 1, nBinFiles));
                     Results.BinnedFileMaxs(iBin,iChan,iDLC) = {data};
                     MeanExtremeMax = sum( data .* ElapsedTime(FileInds) ) / double(TotalElapsedBinTime);
                     Results.MaxBinVals(iBin, iChan, iDLC)  = MeanExtremeMax;
                     MaxDiffs       = data - MeanExtremeMax;
                     aboveMeanInds  = find( MaxDiffs >= -tol );
                        % Find closest extreme above mean
                     [~, ind]       = min(MaxDiffs(aboveMeanInds));

                        % store the file index that corresponds with the closest larger value than the calculated mean               
                     Results.KeepBinMaxFile(iBin, iChan, iDLC) = FileInds(aboveMeanInds(ind)); % where is this file in the full filelist?

                        % Is this max the largest, yet 
                     if ( MeanExtremeMax > Results.MaxVals(iChan) )
                        Results.MaxVals(iChan) = MeanExtremeMax;
                           %Store the associated event to this min                
                        Results.MaxInds(iChan) = FileInds(aboveMeanInds(ind));
                     end
                     
                  end % for iChan
            
              end % if nBinFiles > 0
        
            end % for iBin         
            
         elseif ( DLCs(iDLC).BinModel == 2)
            binHasData = zeros(Results.NumWSbins,1);
            for iBin = 1:Results.NumWSbins
         
               FileInds = find(Results.WSBinInds == iBin & DLCMask == iDLC); %(WSBinInds == iBin);   
               nBinFiles = sum(Results.WSBinInds == iBin & DLCMask == iDLC);

               if ( nBinFiles > 0 )
                  binHasData(iBin) = 1;
                  % We cannot determine the total
                  %TotalElapsedBinTime = sum( ElapsedTime(FileInds) );

                  for iChan = 1:nEEvChans

                     % Compute the mean extreme value for each channel in this bin

                     % NOTE:  This accounts for elasped times of each file when
                     % computing the mean

                        % Mean of Mins
                     data = double(reshape(ChanMinAssocValues(AllEEvChans(iChan),AllEEvChans(iChan),FileInds),1,nBinFiles));
                     half = ceil(length(data)/2);
                        % Sort the data smallest to largest.
                     [sortedData, sortInds] =  sort(data);
                     TotalElapsedBinTime = sum(ElapsedTime(FileInds(sortInds(1:half))));
                     Results.BinnedFileMins(iBin,iChan,iDLC) = {data};
                     MeanExtremeMin = sum( sortedData(1:half) .* ElapsedTime(FileInds(sortInds(1:half))) ) / double(TotalElapsedBinTime);
                     Results.MinBinVals(iBin, iChan, iDLC)  = MeanExtremeMin;
                     MinDiffs       = data - MeanExtremeMin;                 
                     belowMeanInds  = find( MinDiffs <= tol );
                        % Find closest extreme below mean
                     [~, ind]       = min(abs(MinDiffs(belowMeanInds)));

                        % store the file index that corresponds with the closest smaller value than the calculated mean               
                     Results.KeepBinMinFile(iBin, iChan, iDLC) = FileInds(belowMeanInds(ind)); 

                        % Is this min the smallest, yet 
                     if ( MeanExtremeMin < Results.MinVals(iChan) )
                        Results.MinVals(iChan) = MeanExtremeMin;
                           %Store the associated event to this min                
                        Results.MinInds(iChan) = FileInds(belowMeanInds(ind));
                     end
                     
                        % Mean of Maxes
                     data = double(reshape(ChanMaxAssocValues(AllEEvChans(iChan),AllEEvChans(iChan),FileInds), 1, nBinFiles));
                     
                        % Sort the data largest to smallest.
                     [sortedData, sortInds] =  sort(data,'descend');
                     TotalElapsedBinTime = sum(ElapsedTime(FileInds(sortInds(1:half))));
                     Results.BinnedFileMaxs(iBin,iChan,iDLC) = {data};
                     MeanExtremeMax = sum( sortedData(1:half) .* ElapsedTime(FileInds(sortInds(1:half))) ) / double(TotalElapsedBinTime);
                     Results.MaxBinVals(iBin, iChan, iDLC)  = MeanExtremeMax;
                     MaxDiffs       = data - MeanExtremeMax;
                     aboveMeanInds  = find( MaxDiffs >= -tol );
                        % Find closest extreme above mean
                     [~, ind]       = min(MaxDiffs(aboveMeanInds));

                        % store the file index that corresponds with the closest larger value than the calculated mean               
                     Results.KeepBinMaxFile(iBin, iChan, iDLC) = FileInds(aboveMeanInds(ind)); % where is this file in the full filelist?

                        % Is this max the largest, yet 
                     if ( MeanExtremeMax > Results.MaxVals(iChan) )
                        Results.MaxVals(iChan) = MeanExtremeMax;
                           %Store the associated event to this min                
                        Results.MaxInds(iChan) = FileInds(aboveMeanInds(ind));
                     end
                     
                  end % for iChan
            
              end % if nBinFiles > 0
        
            end % for iBin          
      
         end  % if ( DLCs(iDLC).BinModel == 0)
      
      % Find the mean value of the extreme events within each bin
      
      
      
      end %for iDLC = 1:NumDLCs
      
   else
      Results.WSBins         = [];
      Results.BinnedFileMins = [];
      Results.MinBinVals     = [];
      Results.BinnedFileMaxs = [];
      Results.MaxBinVals     = [];
     
      % No binning used for any of the DLCs
      for iChan = 1:nEEvChans
            % Find the min and max indices the result is the file where the
            % extreme event occurs
         [~,Results.MinInds(iChan)] = min(ChanMinAssocValues(AllEEvChans(iChan),AllEEvChans(iChan),:));
         [~,Results.MaxInds(iChan)] = max(ChanMaxAssocValues(AllEEvChans(iChan),AllEEvChans(iChan),:));
         Results.MinVals(iChan) = ChanMinAssocValues(AllEEvChans(iChan),AllEEvChans(iChan),Results.MinInds(iChan));
         Results.MaxVals(iChan) = ChanMaxAssocValues(AllEEvChans(iChan),AllEEvChans(iChan),Results.MaxInds(iChan));
      end
   end % BinEvents  
  
   
end