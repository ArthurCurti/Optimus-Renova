function chrChan = ConvertNumberColToCharCol( numChan )
   % This function is used to convert a column number to an equivalent Excel Alpha column label
   % Excel uses A, B, C, ..., Z, AA, AB, ..., AZ, BA, BB, ...
   % This is limited to ZZ colums of data, or 26^2 channels
   
   if ( numChan < 1 )
      beep
      error( 'Use must provide a channel index > 0.' );
   end
   
      
   alphaMultiplier = floor( (numChan-1) / 26 );
   alphaRemainder  = mod( (numChan-1), 26 );
   if ( alphaMultiplier > 0  )
      chrChan = [char(alphaMultiplier + 64)  char(alphaRemainder + 65)];
   else   
      chrChan  =   char(numChan+64);
   end
   
end