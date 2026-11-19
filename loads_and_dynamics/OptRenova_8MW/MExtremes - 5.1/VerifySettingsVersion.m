function [errStat, errMsg] = VerifySettingsVersion(paramFile)

   errStat = 0;
   errMsg = '';
   
   
   
   % Search file for BinEvents parameter
   foundBinEvents = false;
   for pLine=1:size( paramFile{1}, 1 )
      if ( ~isempty( strfind( paramFile{1}{pLine}, 'BinEvents' ) ) )
            % Found a parameter
         foundBinEvents = true;
         break
      end 
   end % for pLine
   
   if ( foundBinEvents ) 
      errStat = 4;
      errMsg = 'The new settings file format no longer uses the parameter: BinEvents.  ';
      
   end
   
   % Search file for TimeChan parameter
   foundTimeChan = false;
   for pLine=1:size( paramFile{1}, 1 )
      if ( ~isempty( strfind( paramFile{1}{pLine}, 'TimeChan' ) ) )
            % Found a parameter
         foundTimeChan = true;
         break
      end 
   end % for pLine
   
   if ( ~foundTimeChan ) 
      errStat = 4;
      errMsg  = [errMsg,'Could not find new settings file parameter: TimeChan.  '];
      
   end
   
   % Search file for WSChan parameter
   foundWSChan = false;
   for pLine=1:size( paramFile{1}, 1 )
      if ( ~isempty( strfind( paramFile{1}{pLine}, 'WSChan' ) ) )
            % Found a parameter
         foundWSChan = true;
         break
      end 
   end % for pLine
   
   if ( ~foundWSChan ) 
      errStat = 4;
      errMsg  = [errMsg,'Could not find new settings file parameter: WSChan.  '];
      
   end
   
   % Search file for WSmin parameter
   foundWSmin = false;
   for pLine=1:size( paramFile{1}, 1 )
      if ( ~isempty( strfind( paramFile{1}{pLine}, 'WSmin' ) ) )
            % Found a parameter
         foundWSmin = true;
         break
      end 
   end % for pLine
   
   if ( ~foundWSmin ) 
      errStat = 4;
      errMsg  = [errMsg,'Could not find new settings file parameter: WSmin.  '];
      
   end
   
   % Search file for WSmax flag
   foundWSmax = false;
   for pLine=1:size( paramFile{1}, 1 )
      if ( ~isempty( strfind( paramFile{1}{pLine}, 'WSmax' ) ) )
            % Found a parameter
         foundWSmax = true;
         break
      end 
   end % for pLine
   
   if ( ~foundWSmax ) 
      errStat = 4;
      errMsg  = [errMsg,' Could not find new settings file parameter: WSmax.  '];
     
   end
   
   % Search file for WSMaxBinSize flag
   foundWSMaxBinSize = false;
   for pLine=1:size( paramFile{1}, 1 )
      if ( ~isempty( strfind( paramFile{1}{pLine}, 'WSMaxBinSize' ) ) )
            % Found a parameter
         foundWSMaxBinSize = true;
         break
      end 
   end % for pLine
   
   if ( ~foundWSMaxBinSize ) 
      errStat = 4;
      errMsg = [errMsg,' Could not find new settings file parameter: WSMaxBinSize.  '];
      
   end
   
   % Search file for FileFormat flag
   foundFileFormat = false;
   for pLine=1:size( paramFile{1}, 1 )
      if ( ~isempty( strfind( paramFile{1}{pLine}, 'FileFormat' ) ) )
            % Found a restore
         foundFileFormat = true;
         break
      end 
   end % for pLine
   
   if ( ~foundFileFormat ) 
      errStat = 4;
      errMsg = [errMsg,' Could not find new settings file parameter: FileFormat.  '];
      
   end
   
   % Search file for ScatterPlots flag
   foundScatterPlots = false;
   for pLine=1:size( paramFile{1}, 1 )
      if ( ~isempty( strfind( paramFile{1}{pLine}, 'ScatterPlots' ) ) )
            % Found a parameter
         foundScatterPlots = true;
         break
      end 
   end % for pLine
   
   if ( ~foundScatterPlots ) 
      errStat = 4;
      errMsg = [errMsg,' Could not find new settings file parameter: ScatterPlots.  '];
     
   end
   
  % Search file for PlotFormat parameter
   foundPlotFormat = false;
   for pLine=1:size( paramFile{1}, 1 )
      if ( ~isempty( strfind( paramFile{1}{pLine}, 'PlotFormat' ) ) )
            % Found a parameter
         foundPlotFormat = true;
         break
      end 
   end % for pLine
   
   if ( ~foundPlotFormat ) 
      errStat = 4;
      errMsg = [errMsg,' Could not find new settings file parameter: PlotFormat.  '];
     
   end
   
  % Search file for ChartName line for Charts
   foundChartName = false;
   for pLine=1:size( paramFile{1}, 1 )
      if ( ~isempty( strfind( paramFile{1}{pLine}, 'ChartName' ) ) )
            % Found a restore
         foundChartName = true;
         break
      end 
   end % for pLine
   
   if ( ~foundChartName ) 
      errStat = 4;
      errMsg = [errMsg,' Could not find header line for the Charts table.  This version requires the header line even if NumEECharts = 0.  '];
      
   end
   
   if (errStat > 0 )
     errMsg = [errMsg,'  Please look at the NREL CertTest folder for example settings files for this version of MExtremes.'];
   end
end