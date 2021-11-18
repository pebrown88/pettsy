function writeVarnFile(Name, Species)

fileID = fopen([Name '.varn'], 'w');

for i = 1:length(Species)
    fprintf(fileID, '%s\t%f\t%s\n', Species(i).sassyname, Species(i).initialValue, Species(i).Description);
end

fclose(fileID);