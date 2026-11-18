function [errStat, errMsg] = GenerateScatterPlots(outputFileRoot, SettingsFile, FileInfo, Settings, ChanMinAssocValues, ChanMaxAssocValues, FileMeanWindSpeed, Results)

%       Results.NumWSbins     
%       Results.WSBinSize      
%       Results.WSBinInds   
%       Results.WSBins      
%       
%       Results.KeepBinMinFile
%       Results.KeepBinMaxFile 
%       Results.MinBinVals   
%       Results.MaxBinVals   
%       Results.BinnedFileMins 
%       Results.BinnedFileMaxs
%       Results.MinVals     
%       Results.MaxVals      
      
% WSbins is an array containing the central windspeed value for each,
% equal-sized windspeed bin
% BinnedData is a cell array of size (NumWSbins, nEEvChans, NumDLCs)
% For now, we will produce one plot for each channel, with the DLCs
% plotted together for a given channel.  We will also show the DLC's bin
% mean according to the binning model used.

% NOTE: There are a few indexing schemes used in the code.  One is
% based on the FileInfo.FileList array of time-series files, and another is
% based on all the channels in a file, and another is based on all the file
% channels that are used for extreme event results (table/plots/charts).

   nBins  = length(Results.WSBins);
   nChans = Settings.nEEvChans;
   nDLCs  = FileInfo.NumDLCs;
   colors = distinguishable_colors(nDLCs+1);
   overallColor = colors(nDLCs+1,:);
   errStat = 0;
   errMsg  = '';
   
   
   
   for iChan = 1:nChans
      hmin = [];
      hmax = [];
      maxLegend = [];
      minLegend = [];
      count = 1;
      ChanName = FileInfo.ChanNames(Settings.AllEEvChans(iChan));
      
      hFigMin = figure();
      set(hFigMin, 'Visible', 'off');
      title('Minimum Extremes by Windspeed (Bin)');
      ylabel(ChanName);
      xlabel('Windspeed (Bin) Value');
      
      hold on;
      
      
      
      
      hFigMax = figure();
      set(hFigMax, 'Visible', 'off');
      title('Maximum Extremes by Windspeed (Bin)');
      ylabel(ChanName);
      xlabel('Windspeed (Bin) Value');
      hold on;
      
      
      
         % Now overlay the data associated with each DLC for this channel.
      for iDLC = 1:nDLCs
         DLC_Name  = FileInfo.DLCs(iDLC).DLC_Name;
          
         if ( FileInfo.DLCs(iDLC).BinModel == 0 )
            
            fileInds = find(FileInfo.DLCMask == iDLC);
            
            if (~isempty(fileInds) )
               nFileInds = length(fileInds);
               figure(hFigMin);
               iFileListInd = Settings.AllEEvChans(iChan);
               chanData = reshape(ChanMinAssocValues(iFileListInd, iFileListInd, fileInds),nFileInds,1);
               wsData   = reshape(ChanMinAssocValues(FileInfo.WSChan, FileInfo.WSChan, fileInds),nFileInds,1);
               hmin(count) = scatter(wsData, chanData, 50, colors(iDLC,:));
               if ( isempty(minLegend) )
                  minLegend = {[DLC_Name,' Unbinned']};
                  maxLegend = {[DLC_Name,' Unbinned']};
               else
                  minLegend = [minLegend; {[DLC_Name,' Unbinned']}];
                  maxLegend = [maxLegend; {[DLC_Name,' Unbinned']}];
               end
               
               figure(hFigMax);
               chanData = reshape(ChanMaxAssocValues(iFileListInd, iFileListInd, fileInds),nFileInds,1);
               wsData   = reshape(ChanMaxAssocValues(FileInfo.WSChan, FileInfo.WSChan, fileInds),nFileInds,1);
               hmax(count) = scatter(wsData, chanData, 50, colors(iDLC,:));
               count = count + 1;
               
               
            end
          
         else
            if ( isempty(minLegend) )
               minLegend = [{DLC_Name}; {[DLC_Name,' Bin Mean']}];
               maxLegend = [{DLC_Name}; {[DLC_Name,' Bin Mean']}];
            else
               minLegend = [maxLegend; {DLC_Name}; {[DLC_Name,' Bin Mean']}];
               maxLegend = [maxLegend; {DLC_Name}; {[DLC_Name,' Bin Mean']}];
            end
            figure(hFigMin);
            [hmin, errStat, errMsg] = PlotBinnedExtremes(hmin, iChan, iDLC, Results.WSBins, Results.BinnedFileMins, Results.MinBinVals, colors(iDLC,:));
           
            figure(hFigMax);
            [hmax, errStat, errMsg] = PlotBinnedExtremes(hmax, iChan, iDLC, Results.WSBins, Results.BinnedFileMaxs, Results.MaxBinVals, colors(iDLC,:));
            
            count = count + 2;
         end
      end
      
      
      % Plot the overall extreme value across all DLCs and possible
      % windspeeds
      
      % Files associated with overall extremes of this channel
      EEminFileInd = Results.MinInds(iChan);
      DLC_EEmin      = FileInfo.DLCMask(EEminFileInd);
      if (FileInfo.DLCs(DLC_EEmin).BinModel > 0)
            % Use the windspeed bin as the x-axis value
         wsValEEmin = Results.WSBins(Results.WSBinInds(EEminFileInd)); 
         
      else
            % Use the windspeed of the event
         wsValEEmin = ChanMinAssocValues(FileInfo.WSChan, FileInfo.WSChan, EEminFileInd);
         
      end
      
      figure(hFigMin);
      pointsize   = 100;
      hmin(count) =scatter(wsValEEmin, ChanMinAssocValues(Settings.AllEEvChans(iChan), Settings.AllEEvChans(iChan), EEminFileInd), pointsize, overallColor);
      minLegend = [minLegend; {'Minimum Extreme Event'}];
      
      pointsize   = 100;
      hmin(count+1) =scatter(wsValEEmin, Results.MinVals(iChan), pointsize, overallColor,'MarkerFaceColor',overallColor);
     
      minLegend = [minLegend; {'Minimum Calculated Extreme'}];
      
      
      % Plot the overall extreme value across all DLCs and possible
      % windspeeds
      
      
      EEmaxFileInd = Results.MaxInds(iChan);
      
      DLC_EEmax      = FileInfo.DLCMask(EEmaxFileInd);
      if (FileInfo.DLCs(DLC_EEmax).BinModel > 0)
            % Use the windspeed bin as the x-axis value 
         wsValEEmax = Results.WSBins(Results.WSBinInds(EEmaxFileInd)); 
      else
            % Use the windspeed of the event
         wsValEEmax = ChanMaxAssocValues(FileInfo.WSChan, FileInfo.WSChan, EEmaxFileInd);
      end
      
      figure(hFigMax);
      pointsize   = 100;
      hmax(count) =scatter(wsValEEmax, ChanMaxAssocValues(Settings.AllEEvChans(iChan), Settings.AllEEvChans(iChan),EEmaxFileInd), pointsize, overallColor);
      maxLegend = [maxLegend; {'Maximum Extreme Event'}];
      
      pointsize   = 100;
      hmax(count+1) =scatter(wsValEEmax, Results.MaxVals(iChan), pointsize, overallColor,  'MarkerFaceColor',overallColor);
      maxLegend = [maxLegend; {'Maximum Calculated Extreme'}];
      
         % Save these figures to file.
      if ( Settings.PlotFormat == 1 ) 
         minFigName = strcat( outputFileRoot, '_', ChanName, '_Mins.png' ); 
         maxFigName = strcat( outputFileRoot, '_', ChanName, '_Maxs.png' ); 
      else
         minFigName = strcat( outputFileRoot, '_', ChanName, '_Mins.fig' ); 
         maxFigName = strcat( outputFileRoot, '_', ChanName, '_Maxs.fig' ); 
      end   
      
     figure(hFigMin);
     hleg = legend(hmin, minLegend,'Location','SouthOutside');
     saveas(hFigMin,minFigName{1});
     
     figure(hFigMax); 
     hleg = legend(hmax, maxLegend,'Location','SouthOutside');
     saveas(hFigMax,maxFigName{1});
     
     close(hFigMin);
     close(hFigMax);
     
   end
end