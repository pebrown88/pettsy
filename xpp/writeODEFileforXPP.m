function ok = writeODEFileforXPP(model, params, init_c, force, t_len, xppdir)

%create an ode file for XPPAUTO when user launches xppauto from SASSY gui
%inputs are 
%model - the model structure
%params, cell array, col 1 is param names, col 2 values
%init_c, cell array col 1 variable names, col 2 values
%force is a cell array col 1 force name in equations, col 2 force function,
%col 3 dawn, col 4 dusk
%t_len is length of simulation
%xppdir is the directory to create the file in

%equations in symbolic form will have been saved when make was run on the model
ok = false;

fid = fopen(fullfile(xppdir, [model.name '.eqn']), 'rt');
if fid < 0
    ShowError(['Cannot find the model equation in directory ' xppdir]);
    return;
end

try
    eqn = cell(0);
    while ~feof(fid)
        eqn{end+1} = fgetl(fid);
    end
    fclose(fid);
    
    %create file with required paramters and initial conditions
    fid = fopen(fullfile(xppdir, [model.name '.ode']), 'wt');
    fprintf(fid, '# XPPAUT ode file.\n\n');
    fprintf(fid, '# Initial conditions\n');
    for v = 1:size(init_c, 1)
        fprintf(fid, 'init %s=%f\n', init_c{v, 1}, init_c{v, 2});
    end
    fprintf(fid, '\n# Parameters\n');
    for p = 1:size(params, 1)
        fprintf(fid, 'par %s=%f\n', params{p, 1}, params{p, 2});
    end
    fprintf(fid, 'par CP=%f\n', t_len);
    
    if ~isempty(force)
        global tstr
        if strcmp(model.orbit_type, 'oscillator')
            tstr = cellstr('t-floor(t/CP)*CP');
        else
           tstr = cellstr('t');
        end
        fprintf(fid, '\n# Forces\n');
        fprintf(fid, '# This is defined as a fixed variable for incorporation into the model equations,\n');
        fprintf(fid, '# and then as an auxilliary quantity to allow it to be output to the XPP GUI\n');
    
        forcenames = get_all_force_types();
        for f = 1:size(force, 1)
            fprintf(fid, '# %s is %s\n', force{f, 1}, force{f, 2});
            force_idx = find(strcmp(force{f, 2}, forcenames));
            %index in forcenames will match that in get_force_expr()
            [~, ~, force_eqn] = get_force_expr(force_idx);
            %must rename dawn and dusk in case there are multiple forces
            force_eqn = strrep(force_eqn, 'dawn', [force{f, 1} 'dawn']); %make sure these param names not more than 10 char long
            force_eqn = strrep(force_eqn, 'dusk', [force{f, 1} 'dusk']);
            
            %other changes required for xpp
            force_eqn = char(force_eqn);
            force_eqn = correct_for_XPP(force_eqn);
            
            fprintf(fid, '%s=%s\n', force{f, 1}, force_eqn);
            if strfind(force_eqn, [force{f, 1} 'dawn'])
                fprintf(fid, 'par %s=%f\n', [force{f, 1} 'dawn'], force{f, 3});
            end
            if strfind(force_eqn, [force{f, 1} 'dusk'])
                fprintf(fid, 'par %s=%f\n', [force{f, 1} 'dusk'], force{f, 4});
            end
            %allow xpp giui to output force
            fprintf(fid, 'aux ext_%s=%s\n', force{f, 1}, force{f, 1});
        end  
    end
    
    fprintf(fid, '\n# Model Equations\n');
    for i = 1:length(eqn)
       fprintf(fid, '%s\n', eqn{i}); 
    end
    
    fprintf(fid, '\n# Defult length of simulation is one period\n');
    fprintf(fid, '@ TOTAL=CP\n');
    fprintf(fid, '\ndone\n');
    
    fclose(fid);
    ok = true;
    return;
catch err
    ShowError('An error occurred creating the XPP ODE file.', err);
end

%==========================================================================

function result = correct_for_XPP(eqn)

%change MATLAB names into XPPAUTO names

%xpp                %MATLAB

%flr                floor
result = regexprep(eqn, 'floor\(([\w\.\+-\/\*\s]+)\)', 'flr($1)');


%Also, the following are keywords and cannot be used as variable names

%delay ln  then heav flr ran normal del_shft  hom_bcs
%arg1 ... arg9  @ $ + - / * ^ ** shift not \# sum of i'


%mor erestrictions on forces, name cant have illegal chars eg space
 
%don't use i as matlab symbolic stuff treatsit as imaginary number
%t is time, don't use
%pi is 3.14, don't use

%var names must begin with a letter

%can't name param after one of the force names

%only alphanumeric and underscore in force name

%param names can't be > 10 char long


