function [EEvTables] = GenerateTables(Settings, FileInfo, EEvTables, ChanMinAssocValues, ChanMaxAssocValues, MinInds, MaxInds, MinVals, MaxVals) %FileList, Settings, NumEETables, EEvTables, MinInds, MaxInds)


if (Settings.NumEETables > 0)
  % Preallocate the substructures for the channel values at the minima and maxima for this table.
     
   for Tab=1:Settings.NumEETables
      
      NumTabEEvChans               = size( EEvTables(Tab).Chans   , 2 );
      NumTabInfoChans              = size( EEvTables(Tab).InfChans, 2 );
      TotTabEEvChans               = NumTabEEvChans + NumTabInfoChans;
      EEvTables(Tab).Chan           = repmat( struct( 'ChanMinVals',zeros(1,TotTabEEvChans), 'ChanMaxVals',zeros(1,TotTabEEvChans) ), 1, NumTabEEvChans );
      

         % For the min or max of each EEv channel, save the values of
         % the other channels that occurred at the same time.  Also save
         % the row and file.

      for Chan=1:NumTabEEvChans

         Ch = Settings.EEChanLocs( EEvTables(Tab).Chans(Chan) );
         EEvTables(Tab).Chan(Chan).MinVal = MinVals(Ch);
         EEvTables(Tab).Chan(Chan).MaxVal = MaxVals(Ch);
         
         for TCh=1:NumTabEEvChans
            
            Ch2 = Settings.EEChanLocs( EEvTables(Tab).Chans(TCh) );
            EEvTables(Tab).Chan(Chan).ChanMinVals(TCh) = ChanMinAssocValues(Settings.AllEEvChans(Ch),Settings.AllEEvChans(Ch2),MinInds(Ch));
            EEvTables(Tab).Chan(Chan).ChanMaxVals(TCh) = ChanMaxAssocValues(Settings.AllEEvChans(Ch),Settings.AllEEvChans(Ch2),MaxInds(Ch));
            
         end % for TCh
         
         for TCh=1:NumTabInfoChans
            
            InfCh = Settings.EEInfChanLocs( EEvTables(Tab).InfChans(TCh));
            EEvTables(Tab).Chan(Chan).ChanMinVals(NumTabEEvChans+TCh) = ChanMinAssocValues(Settings.AllEEvChans(Ch),Settings.AllEEPlusInfChans(Settings.nEEvChans+InfCh),MinInds(Ch));
            EEvTables(Tab).Chan(Chan).ChanMaxVals(NumTabEEvChans+TCh) = ChanMaxAssocValues(Settings.AllEEvChans(Ch),Settings.AllEEPlusInfChans(Settings.nEEvChans+InfCh),MaxInds(Ch));
            
         end % for TCh

         EEvTables(Tab).Chan(Chan).MinFilename = FileInfo.FileList(MinInds(Ch));
         EEvTables(Tab).Chan(Chan).MaxFilename = FileInfo.FileList(MaxInds(Ch));
         EEvTables(Tab).Chan(Chan).MinDLCname  = FileInfo.DLCs(FileInfo.DLCMask(MinInds(Ch))).DLC_Name ;
         EEvTables(Tab).Chan(Chan).MaxDLCname  = FileInfo.DLCs(FileInfo.DLCMask(MaxInds(Ch))).DLC_Name ;
        % EEvTables(Tab).Chan(Chan).MinRow  = Row;
        
      end % for Chan
    
   end % for Tab
   
end
end