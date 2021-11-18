function savesystem(name, mdir, rhs, model_type, numForce, wbHndl)
%
% creates the file 'name'.m with the model's ODE
% the created file will be used by integration routines such as ode45
%
% mdir is the directory where the file will be created
% rhs is the right hand side of the model
% vps stores the original variables, parameters and time
% vp stores the new variables, parameters and time

global conv parsym pari varsym vari forcesym forcei
global rhsp

if isempty(wbHndl)
    disp(['Creating system file ' name '.m']);
end

%replace param names  with p(n) and forcen with force(n)
rhsp = subs(rhs,[str2sym(parsym) str2sym(forcesym)], [str2sym(pari) str2sym(forcei)]);

%yn to y(n)
f = subs(rhsp, str2sym(varsym), str2sym(vari));

file = fopen(fullfile(mdir, [name '.m']),'w');
fileheader(file, name,'');

% writes the differential equations rhs
fprintf(file,'function [dydt, varargout] = %s(t,y,userdata)\n\n', name);

fprintf(file, 'p = userdata{1};\n');
fprintf(file, 'ModelForce = userdata{2};\n');
fprintf(file, 'CP = userdata{3};\n');

if numForce > 0
    fprintf(file, 'force = get_force(t, ModelForce, CP, ''%s'');\n', model_type);
end

fprintf(file,'dydt = [\n');
for i=1:length(rhs)
    fprintf(file,'\t%s;\n',char(f(i)));
end   
fprintf(file,'\n];\n\n');


fprintf(file, 'check_for_complex_values = false;\n');
fprintf(file, 'if any(isnan(dydt)) || any(isinf(dydt))  || (check_for_complex_values && any(imag(dydt)))\n');
fprintf(file, '\tmydir = fileparts(mfilename(''fullpath''));\n');
fprintf(file, '\tinfo_file = fullfile(mydir, ''derivatives'',  ''%s'');\n', [name '_eqn_info.mat']);
fprintf(file, '\tderivative_error(dydt, y, t, p, force, 0, info_file)\n');

fprintf(file, 'end\n\n');

fprintf(file, 'if nargout > 1\n');
fprintf(file,'\tvarargout{1} = 0;\n');
fprintf(file, '\tvarargout{2} = [];\n');
fprintf(file, 'end\n\n');

% writes the comments
for i=1:length(conv)
    fprintf(file,'%s\n',char(conv{i}));
end
fclose(file);
