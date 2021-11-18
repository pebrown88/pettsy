function writeforce()

%writes the force options to file. Create the files
%<install_dir>/shared/get_force.m which provides force value,
%<install_dir>/shared/get_dforce_ddawn.m which provides dforce_ddawn and dforce_ddusk
%<install_dir>/shared/force_is_constant.m which detects whether force is a
%function of time or not
%<install_dir>/shared/get_all_force_types.m returns a list of all current forces
%available

%Uses all those defined in get_force_exptr()

global tstr

forces_signal = [];
forces_oscillator = [];

%oscillator
tstr = cellstr('t-floor(t/CP)*CP');
i=1;
[force_name, ftype, force, df, df2, df3] = get_force_expr(i);
while(~isempty(force_name))
   forces_oscillator(i).name = force_name;
   forces_oscillator(i).const = ftype;
   forces_oscillator(i).expr = force;
   forces_oscillator(i).dfdd = df; %dforce_ddawn and dforce_ddus
   forces_oscillator(i).d2fdd2 = [df2(1) df2(2)]; %will be [d2force_ddawn2 d2force_ddusk2]
   forces_oscillator(i).dfdddd = [df3(1) df3(2)]; %will be [dforce_ddusk_ddawn dforce_ddawn_ddusk ]
   disp(['force ''' force_name ''' found']);
   i = i+1;
   [force_name, ftype, force, df, df2, df3] = get_force_expr(i);
end

%signal models
tstr = cellstr('t'); 
i=1;
[force_name, ftype, force, df, df2, df3] = get_force_expr(i);
while(~isempty(force_name))
   forces_signal(i).name = force_name;
   forces_signal(i).const = ftype;
   forces_signal(i).expr = force;
   forces_signal(i).dfdd = df; %dforce_ddawn and dforce_ddusk
   forces_signal(i).d2fdd2 = [df2(1) df2(2)]; %will be [d2force_ddawn2 d2force_ddusk2]
   forces_signal(i).dfdddd = [df3(1) df3(2)]; %will be [ dforce_ddusk_ddawn dforce_ddawn_ddusk]
   i = i+1;
   [force_name, ftype, force, df, df2, df3] = get_force_expr(i);
end
disp(['Found ' num2str(i-1) ' forces'])
%create the files
disp('Creating file ''get_force''...');
mydir = fileparts(mfilename('fullpath'));
file = fopen(fullfile(mydir, '..', 'force', 'get_force.m'), 'w');

fprintf(file, 'function force = get_force(t, ModelForce, CP, model_type)\n\n');
fprintf(file, '%%force definitions based on the content of get_force_expr()\n');
fprintf(file, '%%calculates force value at runtime\n\n');
fprintf(file, 'if strcmp(model_type, ''oscillator'')\n');
fprintf(file,'\tforce = get_force_oscillator(t, ModelForce, CP);\n');
fprintf(file,'else\n');
fprintf(file,'\tforce = get_force_signal(t, ModelForce, CP);\n');
fprintf(file,'end\n\n\n');
fprintf(file,'function force = get_force_oscillator(t, ModelForce, CP)\n\n');
fprintf(file, 'force = zeros(length(ModelForce),1);\n');
fprintf(file, 'for i = 1:length(ModelForce)\n');
fprintf(file, '\tdawn = ModelForce(i).dawn;\n');
fprintf(file, '\tdusk = ModelForce(i).dusk;\n');
fprintf(file, '\tforcename = ModelForce(i).name;\n');
fprintf(file,'\tswitch forcename\n');

for i = 1:length(forces_oscillator)
    fprintf(file,'\t\tcase ''%s''\n', forces_oscillator(i).name);
    fprintf(file,'\t\t\tforce(i)=%s;\n',char(forces_oscillator(i).expr));
end

fprintf(file,'\tend\n');
fprintf(file,'end\n\n\n');

fprintf(file,'function force = get_force_signal(t, ModelForce, CP)\n\n');
fprintf(file, 'force = zeros(length(ModelForce),1);\n');
fprintf(file, 'for i = 1:length(ModelForce)\n');
fprintf(file, '\tdawn = ModelForce(i).dawn;\n');
fprintf(file, '\tdusk = ModelForce(i).dusk;\n');
fprintf(file, '\tforcename = ModelForce(i).name;\n');
fprintf(file,'\tswitch forcename\n');

for i = 1:length(forces_signal)
    fprintf(file,'\t\tcase ''%s''\n', forces_signal(i).name);
    fprintf(file,'\t\t\tforce(i)=%s;\n',char(forces_signal(i).expr));
end

fprintf(file,'\tend\n');
fprintf(file,'end\n');
disp('done');
fclose(file);

%==========================================================================
disp('Creating file ''get_dforce_ddawn''...');
file = fopen(fullfile(mydir, '..', 'force', 'get_dforce_ddawn.m'), 'w');

fprintf(file, 'function [df_ddawn, df_ddusk, d2f_ddawn2, d2f_ddusk2, df_ddawn_ddusk, df_ddusk_ddawn] = get_dforce_ddawn(t, ModelForce, CP, model_type)\n\n');

fprintf(file, '%%force definitions based on the content of get_force_expr()\n');
fprintf(file, '%%calculates derivative of the model force with respect to dawn and dusk at runtime\n');
fprintf(file, '%%second derivatives not yey implemented\n\n');

fprintf(file,'if strcmp(model_type, ''oscillator'')\n');
fprintf(file,'\tif nargout > 2\n');
fprintf(file,'\t\t[df_ddawn, df_ddusk, d2f_ddawn2, d2f_ddusk2, df_ddawn_ddusk, df_ddusk_ddawn] = get_dforce_ddawn_oscillator(t, ModelForce, CP);\n');
fprintf(file,'\telse\n');
fprintf(file,'\t\t[df_ddawn, df_ddusk] = get_dforce_ddawn_oscillator(t, ModelForce, CP);\n');
fprintf(file,'\tend\n');
fprintf(file,'else\n');
fprintf(file,'\tif nargout > 2\n');
fprintf(file,'\t\t[df_ddawn, df_ddusk, d2f_ddawn2, d2f_ddusk2, df_ddawn_ddusk, df_ddusk_ddawn] = get_dforce_ddawn_signal(t, ModelForce, CP);\n');
fprintf(file,'\telse\n');
fprintf(file,'\t\t[df_ddawn, df_ddusk] = get_dforce_ddawn_signal(t, ModelForce, CP);\n');
fprintf(file,'\tend\n');
fprintf(file,'end\n\n\n');

fprintf(file,'function [df_ddawn, df_ddusk, d2f_ddawn2, d2f_ddusk2, df_ddawn_ddusk, df_ddusk_ddawn] = get_dforce_ddawn_oscillator(t, ModelForce, CP)\n\n');
fprintf(file, 'df_ddawn = zeros(length(ModelForce),1);\n');
fprintf(file, 'df_ddusk = zeros(length(ModelForce),1);\n');
fprintf(file, 'if nargout > 2\n');
fprintf(file, '\td2f_ddawn2 = zeros(length(ModelForce),1);\n');
fprintf(file, '\td2f_ddusk2 = zeros(length(ModelForce),1);\n');
fprintf(file, '\tdf_ddawn_ddusk = zeros(length(ModelForce),1);\n');
fprintf(file, '\tdf_ddusk_ddawn = zeros(length(ModelForce),1);\n');
fprintf(file, 'end\n');

fprintf(file, 'for i = 1:length(ModelForce)\n');
fprintf(file, '\tdawn = ModelForce(i).dawn;\n');
fprintf(file, '\tdusk = ModelForce(i).dusk;\n');
fprintf(file, '\tforcename = ModelForce(i).name;\n');
fprintf(file, '\tswitch forcename\n');

for i = 1:length(forces_oscillator)
    fprintf(file,'\t\tcase ''%s''\n', forces_oscillator(i).name);
    fprintf(file,'\t\t\tdf_ddawn(i)=%s;\n', char(forces_oscillator(i).dfdd(1)));
    fprintf(file,'\t\t\tdf_ddusk(i)=%s;\n', char(forces_oscillator(i).dfdd(2)));
    fprintf(file, '\t\t\tif nargout > 2\n');
    fprintf(file,'\t\t\t\td2f_ddawn2(i)=%s;\n', char(forces_oscillator(i).d2fdd2(1)));
    fprintf(file,'\t\t\t\td2f_ddusk2(i)=%s;\n', char(forces_oscillator(i).d2fdd2(2)));
    fprintf(file,'\t\t\t\tdf_ddusk_ddawn(i)=%s;\n', char(forces_oscillator(i).dfdddd(1)));
    fprintf(file,'\t\t\t\tdf_ddawn_ddusk(i)=%s;\n', char(forces_oscillator(i).dfdddd(2)));
    fprintf(file, '\t\t\tend\n');
end

fprintf(file,'\tend\n');
fprintf(file,'end\n\n\n');

fprintf(file,'function [df_ddawn, df_ddusk, d2f_ddawn2, d2f_ddusk2, df_ddawn_ddusk, df_ddusk_ddawn] = get_dforce_ddawn_signal(t, ModelForce, CP)\n\n');
fprintf(file, 'df_ddawn = zeros(length(ModelForce),1);\n');
fprintf(file, 'df_ddusk = zeros(length(ModelForce),1);\n');
fprintf(file, 'if nargout > 2\n');
fprintf(file, '\td2f_ddawn2 = zeros(length(ModelForce),1);\n');
fprintf(file, '\td2f_ddusk2 = zeros(length(ModelForce),1);\n');
fprintf(file, '\tdf_ddawn_ddusk = zeros(length(ModelForce),1);\n');
fprintf(file, '\tdf_ddusk_ddawn = zeros(length(ModelForce),1);\n');
fprintf(file, 'end\n');

fprintf(file, 'for i = 1:length(ModelForce)\n');
fprintf(file, '\tdawn = ModelForce(i).dawn;\n');
fprintf(file, '\tdusk = ModelForce(i).dusk;\n');
fprintf(file, '\tforcename = ModelForce(i).name;\n');
fprintf(file, '\tswitch forcename\n');

for i = 1:length(forces_signal)
    fprintf(file,'\t\tcase ''%s''\n', forces_signal(i).name);
    fprintf(file,'\t\t\tdf_ddawn(i)=%s;\n', char(forces_signal(i).dfdd(1)));
    fprintf(file,'\t\t\tdf_ddusk(i)=%s;\n', char(forces_signal(i).dfdd(2)));
    fprintf(file, '\t\t\tif nargout > 2\n');
    fprintf(file,'\t\t\t\td2f_ddawn2(i)=%s;\n', char(forces_signal(i).d2fdd2(1)));
    fprintf(file,'\t\t\t\td2f_ddusk2(i)=%s;\n', char(forces_signal(i).d2fdd2(2)));
    fprintf(file,'\t\t\t\tdf_ddusk_ddawn(i)=%s;\n', char(forces_signal(i).dfdddd(1)));
    fprintf(file,'\t\t\t\tdf_ddawn_ddusk(i)=%s;\n', char(forces_signal(i).dfdddd(2)));
    fprintf(file, '\t\t\tend\n');
end
fprintf(file,'\tend\n');
fprintf(file,'end\n');
fclose(file);
disp('done');
%==========================================================================
disp('Creating file ''force_is_constant''...');
file = fopen(fullfile(mydir, '..', 'force', 'force_is_constant.m'), 'w');

fprintf(file, 'function const = force_is_constant(forcename, model_type)\n\n');

fprintf(file, '%%force definitions based on the content of get_force_expr()\n\n');
fprintf(file,'if strcmp(model_type, ''oscillator'')\n');
fprintf(file,'\tconst = get_force_is_const_oscillator(forcename);\n');
fprintf(file,'else\n');
fprintf(file,'\tconst = get_force_is_const_signal(forcename);\n');
fprintf(file,'end\n\n\n');
fprintf(file,'function const = get_force_is_const_oscillator(forcename)\n\n');
fprintf(file, '\tswitch forcename\n');

for i = 1:length(forces_oscillator)
    fprintf(file,'\t\tcase ''%s''\n', forces_oscillator(i).name);
    fprintf(file,'\t\t\tconst=%d;\n',forces_oscillator(i).const);
end
fprintf(file,'\tend\n\n\n');

fprintf(file,'function const = get_force_is_const_signal(forcename)\n\n');
fprintf(file,'\tswitch forcename\n');

for i = 1:length(forces_signal)
    fprintf(file,'\t\tcase ''%s''\n', forces_signal(i).name);
    fprintf(file,'\t\t\tconst=%d;\n',forces_signal(i).const);
end
fprintf(file,'end\n');
fclose(file);
disp('done');

%==========================================================================

disp('Creating file ''get_all_force_types''...');
mydir = fileparts(mfilename('fullpath'));
file = fopen(fullfile(mydir, '..', 'force', 'get_all_force_types.m'), 'w');

fprintf(file, 'function forces = get_all_force_types()\n\n');
fprintf(file, '%%force definitions based on the content of get_force_expr()\n\n');
fprintf(file, 'forces = { ...\n');

    for i = 1:length(forces_oscillator) %names the same for oscillator and signal models so could use either
        fprintf(file,'\t''%s'' ...\n', forces_oscillator(i).name);
     
    end
fprintf(file,'};\n');
disp('done');
fclose(file);
