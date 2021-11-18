function jac1 = savejac(name, mdir1, model_type, numForce, wbHndl, inc)
%
% creates the file 'name'_jac.m with the model's jacobian
%
% rhs is the right hand side of the model

if isempty(wbHndl)
    disp(['Creating model jacobian, file ' name '_jac.m']);
end

global rhsp
global varsym vari

dim = length(rhsp);

syms y;
for i=1:dim
  y(i) = (['y',num2str(i)]);
end
% computing the jacobian
jac1 = jacobian(rhsp,y); %rhsp has had parameter and force symbolic names replaced, but still has variable sym names
 

Jpat = zeros(dim);
for i=1:dim
    for j=1:dim
        if ~(jac1(i,j)==0)
            Jpat(i,j)=1;        % Jpat gives the scarcity pattern for jac1
        end;
    end;

    if ~isempty(wbHndl)
        updatebar(wbHndl, inc/(dim*2));
    end
end;



for i=1:dim
    f = jac1(i,:);%Boris' fastsubs() can cope with an input being zero, matlab subs() cannot
    %must now replace sym var names with y(n)
    f = fastsubs(f,varsym, vari);%replace yn with y(n)
    jac(i,:) = f;

    if ~isempty(wbHndl)
        updatebar(wbHndl, inc/(dim*4));
    end
end


file = fopen(fullfile(mdir1, [name '_jac.m']),'w');
fileheader(file, name,'jacobian');

% writing the jacobian
fprintf(file,'\n\nfunction jac = %s_jac(t,y,p,ModelForce,CP)\n\n', name);
%add the force options


if numForce > 0
    fprintf(file, 'force = get_force(t, ModelForce, CP, ''%s'');\n', model_type);
end

fprintf(file, '%%Model jacobian dy/dy\n\n');
fprintf(file,'jac = [\n');
for i=1:dim  
    fprintf(file,'     [');
    for j=1:dim
        fprintf(file,' (%s) ',char(jac(i,j)));
    end
    fprintf(file,'];\n');
end   
fprintf(file,'];\n\n');
fprintf(file, 'check_for_complex_values = false;\n');
fprintf(file, 'if any(isnan(jac(:))) || any(isinf(jac(:))) || (check_for_complex_values && any(imag(jac(:))))\n');
fprintf(file, '\tmydir = fileparts(mfilename(''fullpath''));\n');
fprintf(file, '\tinfo_file = fullfile(mydir, ''%s'');\n', [name '_eqn_info.mat']);
fprintf(file, '\tderivative_error(jac, y, t, p, force, 1, info_file)\n');
fprintf(file, 'end\n');
    
fclose(file);

file = fopen(fullfile(mdir1, [name '_jac_pattern.m']),'w');
fileheader(file, name,'jacobian');

% writting the jacobian pattern
fprintf(file,'\n\nfunction jac_pat = %s_jac_pattern()\n\n', name);
fprintf(file,'jac_pat = [\n');
for i=1:dim  
    fprintf(file,'     [');
    for j=1:dim
        fprintf(file,' %d ',Jpat(i,j));
    end
    fprintf(file,'];\n');
    if ~isempty(wbHndl)
        updatebar(wbHndl, inc/(dim*4));
    end
end   
fprintf(file,'];\n');
fclose(file);

