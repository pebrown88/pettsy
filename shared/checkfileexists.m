function result = checkfileexists(fname)

%returns 1 if file does not exist or user wishes to replace. Zero to keep
%existing file

global force_overwrite

if force_overwrite || (exist([fname], 'file') ~= 2)
    result = 1;
else
   disp(['The model file ', fname, ' already exists'] );
   reply = input('Enter Y to replace the existing file, or N to keep it >> ', 's');
   if ~strcmp(reply, 'Y') && ~strcmp(reply, 'y')
       result = 0;
   else
       result = 1;
   end
end