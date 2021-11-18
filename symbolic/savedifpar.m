function dparx = savedifpar(name, mdir1, rhs, model_type, numForce, wbHndl, inc)
% savedifpar(name, mdir, rhs, fpars)
%
% creates the file 'name'_dp.m 
% with the model's vector field derivatives by parameters
%
% mdir1 is the directory where the file will be created
% rhs is the right hand side of the model

global varsym vari parsym forcesym pari forcei dforcesym dforcei

if isempty(wbHndl)
    disp(['Creating dy/dp matrix, file ' name '_dp.m']);
end

rhsy = subs(rhs, str2sym(varsym), str2sym(vari));%Replace yn with y(n), but still has parameter and force sym names
dim = length(rhs);

%calc derivative with respect to parameter

for p = 1:length(parsym)
   pv(p) = sym(parsym{p}); 
end

%pv = sym(parsym); %failed if par name clashed with built in MUPAD name 

dparx = jacobian(rhsy,pv);


%now with respect to forces
for i = 1:length(forcesym)
    pv = sym(forcesym{i});
    df = jacobian(rhsy, pv);
    %with repect to dawn, dy/ddawn is dy/dforce * dforce/ddawn
    ddawn = df .* sym(['df_ddawn' num2str(i)]);
    %and dusk
    ddusk = df .* sym(['df_ddusk' num2str(i)]);
    dparx = [dparx ddawn ddusk];
end

if ~isempty(wbHndl)
    updatebar(wbHndl, inc/2);
end

% replace symbolic variables with variables used by matlab
[dim,lpar]=size(dparx);
for i=1:dim       % for all in line
    f = dparx(i,:);
    %now replace parmeter and force sym names, and force derivatives
    f = fastsubs(f,[parsym forcesym dforcesym], [pari forcei dforcei]);
    jac(i,:) = f;
    
    if ~isempty(wbHndl)
        updatebar(wbHndl, inc/(dim*2));
    end
end


file = fopen(fullfile(mdir1, [name '_dp.m']),'w');

fileheader(file, name,'- dy/dp derivatives by parameters');

% writting the derivatives by parameters
fprintf(file,'\n\nfunction dpar = %s_dp(t,y,p,ModelForce,CP)\n\n', name);

if numForce > 0
    fprintf(file, '\tforce = get_force(t, ModelForce, CP, ''%s'');\n\n', model_type);
    fprintf(file, '\t[df_ddawn df_ddusk] = get_dforce_ddawn(t, ModelForce, CP, ''%s'');\n\n', model_type);
end

fprintf(file,'dpar = [\n');
for i=1:lpar
    fprintf(file,'     [');
    for j=1:dim
        fprintf(file,' (%s) ',char(jac(j,i)));
    end
    fprintf(file,'];\n');

    if ~isempty(wbHndl)
        updatebar(wbHndl, inc/(lpar*2));
    end
end
fprintf(file,'];\n\n');
fprintf(file, 'check_for_complex_values = false;\n');
fprintf(file, 'if any(isnan(dpar(:))) || any(isinf(dpar(:)))  || (check_for_complex_values && any(imag(dpar(:))))\n');
fprintf(file, '\tmydir = fileparts(mfilename(''fullpath''));\n');
fprintf(file, '\tinfo_file = fullfile(mydir, ''%s'');\n', [name '_eqn_info.mat']);
fprintf(file, '\tderivative_error(dpar, y, t, p, force, 2, info_file, [df_ddawn, df_ddusk])\n');
fprintf(file, 'end\n');
fclose(file);

