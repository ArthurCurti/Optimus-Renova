function GenerateCharts(outputFileRoot, Settings, FileInfo, EEvChart, ChanMinAssocValues, ChanMaxAssocValues)

   if ( Settings.NumEECharts > 0 )
      
      hasFiles = zeros(1,FileInfo.NumDLCs);
      
      for iChart=1:Settings.NumEECharts  
         
         NumEEvChartChans  = size( EEvChart(iChart).Chans   , 2 );
         EEvChart(iChart).absMax = repmat(-realmax('single'),FileInfo.NumDLCs, NumEEvChartChans);
         EEvChart(iChart).Maxima = repmat(-realmax('single'),FileInfo.NumDLCs, NumEEvChartChans);
         EEvChart(iChart).Minima = repmat( realmax('single'),FileInfo.NumDLCs, NumEEvChartChans);

         for iDLC=1:FileInfo.NumDLCs

            for iChan=1:NumEEvChartChans
               
               iCh = Settings.EEChanLocs( EEvChart(iChart).Chans(iChan) );
               iDLCFileInds = find( FileInfo.DLCMask == iDLC );
               nDLCFileInds = sum(  FileInfo.DLCMask == iDLC);
               
               if (nDLCFileInds > 0) % this is needed because initially all DLCs are not required to have files (Save/Restore requirement)
                  
                  EEvChart(iChart).absMax(iDLC,iChan) = max( max ( abs(ChanMinAssocValues(Settings.AllEEvChans(iCh), Settings.AllEEvChans(iCh), iDLCFileInds)) ), max ( abs(ChanMaxAssocValues(Settings.AllEEvChans(iCh), Settings.AllEEvChans(iCh), iDLCFileInds)) ) );
                  EEvChart(iChart).Minima(iDLC,iChan) = min(ChanMinAssocValues(Settings.AllEEvChans(iCh), Settings.AllEEvChans(iCh), iDLCFileInds));
                  EEvChart(iChart).Maxima(iDLC,iChan) = max(ChanMaxAssocValues(Settings.AllEEvChans(iCh), Settings.AllEEvChans(iCh), iDLCFileInds));
                     % determine which DLCs have actual results
                     % this is needed because initially all DLCs are not required to have files (Save/Restore requirement)
                  hasFiles(iDLC) = 1;
               end
         
            end % for iChan
            
         end % for iDLC
         
         goodDLCs = find(hasFiles);
   
         if ( EEvChart(iChart).Type == 1 )
            plot_load_cases_maximums(outputFileRoot, iChart, Settings.PlotFormat, EEvChart(iChart).absMax(goodDLCs,:), {FileInfo.DLCs(goodDLCs).DLC_Name}, FileInfo.ChanNames(EEvChart(iChart).Chans)', EEvChart(iChart).Name, EEvChart(iChart).YLabel);
         elseif ( EEvChart(iChart).Type == 2 )
            plot_load_cases_maximums(outputFileRoot, iChart, Settings.PlotFormat, EEvChart(iChart).Maxima(goodDLCs,:), {FileInfo.DLCs(goodDLCs).DLC_Name}, FileInfo.ChanNames(EEvChart(iChart).Chans)', EEvChart(iChart).Name, EEvChart(iChart).YLabel);
         elseif ( EEvChart(iChart).Type == 3 )
            plot_load_cases_maximums(outputFileRoot, iChart, Settings.PlotFormat, EEvChart(iChart).Minima(goodDLCs,:), {FileInfo.DLCs(goodDLCs).DLC_Name}, FileInfo.Names(EEvChart(iChart).Chans)', EEvChart(iChart).Name, EEvChart(iChart).YLabel);
         end   % if ( EEvChart(iChart).Type == 1 )
         
      end      % for iChart=1:NumEECharts
      
   end         % if ( NumEECharts > 0 )
   
end
