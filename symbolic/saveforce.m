function saveforce(name, mdir)

disp(['Creating force file ' name '_f.m']);

file = fopen([mdir,name,'_f.m'],'w');
fileheader(file, name,'');
fprintf(file,'function force = f(t, p, ModelForce, CP)\n\n');
%add the force options
writeforce(file);
fclose(file);




