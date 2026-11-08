function sc = find_source_channels(str)
   sc = [];
   sc = recursive_channel_find(str, sc);
   return;
   
   function sc = recursive_channel_find(str, sc)
      timeLocations = strfind(str,'.Time');
      if (~isempty(timeLocations))
         str = str(timeLocations(1)+5:end);
         % look for a , and then a )
         commaLoc = strfind(str,',');
         parensLoc = strfind(str,')');
         substr = str(commaLoc(1)+1:parensLoc(1)-1);
         sc = union(sc,str2num(substr));
         str = str(parensLoc+1:end);
         sc = recursive_channel_find(str, sc);
      end
      return;
   end
end