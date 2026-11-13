function [h, errStat, errMsg] = PlotBinnedExtremes( h, iChan, iDLC, WSbins, BinnedData, BinMeans, colorDLC )

% Plot all the extremes from files which are for a single channel (iChan),
% and a single DLC (iDLC).  This data is plotted against the windspeed bin
% values associated with those extreme events.

% WSbins is an array containing the central windspeed value for each,
% equal-sized windspeed bin
% BinnedData is a cell array of size (NumWSbins, nEEvChans, NumDLCs)
% For now, we will produce one plot for each channel, with the DLCs
% plotted together for a given channel.  We will also show the DLC's bin
% mean according to the binning model used.

   nBins  = length(WSbins);
   
   errStat = 0;
   errMsg  = '';
   
   count = length(h) + 1;

   for iBin = 1:nBins

      pointsize   = 50;
      dataPts     = cell2mat(BinnedData(iBin,iChan,iDLC));
      if ( isempty(dataPts) )
         continue;
      end
      nPts        = length(dataPts);
      x           = repmat(WSbins(iBin),nPts,1);
      h(count)    = scatter(x, dataPts, pointsize, colorDLC);
      pointsize   = 75;
      h(count+1)  = scatter(WSbins(iBin),  BinMeans(iBin, iChan, iDLC), pointsize, colorDLC, 'MarkerFaceColor',colorDLC);
      
   end
   
   

end