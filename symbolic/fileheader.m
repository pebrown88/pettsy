function fileheader(file, name, ext)
% fheader(file, name, ext)
%
% creates a header for the generated model files
% file is the file handle
% name is the model's name
% ext  is a brief description of the file


fprintf(file,'%% -------------------------------------------------------------\n');
fprintf(file,'%%                  %s\n', [name,' ',ext]);
fprintf(file,'%% -------------------------------------------------------------\n');
%fprintf(file,'%% generated by make.m from file %s\n %% %s\n\n\n', [name, '_model.m'], date);
fprintf(file,'%% generated by make.m from file %s on %s\n\n', [name, '_model.m'], datestr(now));