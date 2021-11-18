function writeParFile(Name, parameters)

fileID = fopen([Name '.par'], 'w');

for i = 1:length(parameters)
    if ~parameters(i).isforce
        fprintf(fileID, '%s\t%f\t%s\n', parameters(i).sassyname, parameters(i).Value, parameters(i).Description);
    end
end

fclose(fileID);