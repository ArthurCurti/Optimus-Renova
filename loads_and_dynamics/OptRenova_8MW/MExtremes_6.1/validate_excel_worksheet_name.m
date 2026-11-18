function result = validate_excel_worksheet_name( name )
   result = 0;% default to bad
   if ( length(name) > 31 )
      return;
   end
   if strfind(name,'/')
      return;
   end
   if strfind(name,'\')
      return;
   end
   if strfind(name,'*')
      return;
   end
   if strfind(name,'?')
      return;
   end
   if strfind(name,'[')
      return;
   end
   if strfind(name,']')
      return;
   end
   if strfind(name,':')
      return;
   end
   result = 1 ; % Good
end