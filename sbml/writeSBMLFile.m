function ok = writeSBMLFile(model, sbmlFile)

%PEB Nov 2015
%generates sbml from the model structure, as modified by the export wizard
%forms

global tstr %used in get_force_expr to get force equation

try
    wbHndl = waitbar(0.0,'', 'Name', 'PeTTSy', 'pointer', 'watch', 'resize', 'off');
    set(wbHndl, 'userdata', 0);
    
    %generate MathML for ODEs. Use xpp file as this contains eqns in
    %symbolic form
    
    fp = fopen(fullfile(model.dir, 'xpp', [model.name '.eqn']), 'rt');
    model_equations = textscan(fp, '%s', 'Delimiter', '\n');
    fclose(fp);
    model_equations = model_equations{1};
    mathML_eqns = cell(1, length(model_equations));
    
    %progress bar
    num_increments = length(model_equations) + model.numforce + 2;
    inc = 1/num_increments;
    
    
    %convert odes to mathml
    for i = 1:length(model_equations)
        
        updatebar(wbHndl, 0, ['Converting equation ' num2str(i) ' of ' num2str(length(model_equations)) '...']);
        eqn_rhs = char(regexp(model_equations{i}, '=\s*(.*)', 'tokens', 'once'));
        [mathML, ok, msg] = ODEToMathML(eqn_rhs);
        
        if ~ok
            
            [mathML, ok, msg] = ODEToMathML(eqn_rhs, true); %try the fix
            
            if ~ok
                
                ShowError(['There was an error generating content MathML for the rate rule for species ' num2str(i)]);
                ShowError(msg);
                delete(wbHndl);
                return;
            else
                 mathML_eqns{i} = mathML;
            end
        else
            mathML_eqns{i} = mathML;
        end
        updatebar(wbHndl, inc);
    end
    
    %convert force function(s)
    all_force_names = get_all_force_types();
    mathML_force = [];
    
    if strcmp(model.orbit_type, 'oscillator')
        tstr = cellstr('t-floor(t/CP)*CP');
    else
        tstr = cellstr('t');
    end
    
    for i = 1:model.numforce
        
        updatebar(wbHndl, 0, ['Converting external force function ' num2str(i) ' of ' num2str(model.numforce) '...']);
        
        force_name = model.sbml_force(i).type; %'photo', 'cts' etc ...
        force_idx = find(strcmp(force_name, all_force_names));
        [~, ~, force_eqn] = get_force_expr(force_idx);
        
        [function_body, function_call, force_params, ok, msg] = functionToMathML(char(force_eqn), model.sbml_force(i), model.sbml_cp.name);
        
        if ~ok
            ShowError(['There was an error generating content MathML for the force ' force_name '. Please go back and select a different value']);
            ShowError(msg);
            delete(wbHndl);
            return
        else
            mathML_force(i).body = function_body;
            mathML_force(i).call = function_call;
            mathML_force(i).usesParams = force_params;
            
        end
        
        updatebar(wbHndl, inc);
        
    end
    
    updatebar(wbHndl, inc, 'Writing output file...');
    
    sbmlfp = fopen(sbmlFile, 'wt');
    
    %headings and notes
    fprintf(sbmlfp, '<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n\n');
    fprintf(sbmlfp,'<!-- This mode exported from PeTTSy model %s on %s -->\n\n', model.name, datestr(now));
    fprintf(sbmlfp, '<sbml xmlns="http://www.sbml.org/sbml/level2/version4" level="2" version="4">\n');
    fprintf(sbmlfp, '\t<model id="%s" name="%s">\n', model.name, model.sbmlname);
    fprintf(sbmlfp, '\t\t<notes>\n');
    fprintf(sbmlfp, '\t\t\t<body xmlns="http://www.w3.org/1999/xhtml">\n');
    fprintf(sbmlfp, '\t\t\t%s\n', model.notes);
    fprintf(sbmlfp, '\t\t\t</body>\n');
    fprintf(sbmlfp, '\t\t</notes>\n');
    
     %functions. THese will be forces
    if model.numforce > 0
        fprintf(sbmlfp, '\t\t<listOfFunctionDefinitions>\n');
        for i = 1:length(model.sbml_force)
            fprintf(sbmlfp, '\t\t\t<functionDefinition id="%s" name="%s">\n', model.sbml_force(i).name, model.sbml_force(i).notes);
            fprintf(sbmlfp, '\t\t\t\t<math xmlns="http://www.w3.org/1998/Math/MathML">\n');
            fprintf(sbmlfp, ['\t\t\t\t\t' mathML_force(i).body '\n']);
            fprintf(sbmlfp, '\t\t\t\t</math>\n');
            fprintf(sbmlfp, '\t\t\t</functionDefinition>\n');
        end
        fprintf(sbmlfp, '\t\t</listOfFunctionDefinitions>\n');
    end
    
    
    %units
    fprintf(sbmlfp, '\t\t<listOfUnitDefinitions>\n');
    %species units
    fprintf(sbmlfp, '\t\t\t<unitDefinition id="substance" name="%s">\n', model.speciesUnitsName);
    fprintf(sbmlfp, '\t\t\t\t<listOfUnits>\n');
    fprintf(sbmlfp, '\t\t\t\t\t<unit scale="%d" kind="mole"/>\n',model.speciesUnitsScale);
    fprintf(sbmlfp, '\t\t\t\t</listOfUnits>\n');
    fprintf(sbmlfp, '\t\t\t</unitDefinition>\n');
    %time units
    fprintf(sbmlfp, '\t\t\t<unitDefinition id="time" name="%s">\n', model.timeUnitsName);
    fprintf(sbmlfp, '\t\t\t\t<listOfUnits>\n');
    fprintf(sbmlfp, '\t\t\t\t\t<unit multiplier="%f" kind="second"/>\n', model.timeUnitsMultiplier);
    fprintf(sbmlfp, '\t\t\t\t</listOfUnits>\n');
    fprintf(sbmlfp, '\t\t\t</unitDefinition>\n');
    
    fprintf(sbmlfp, '\t\t</listOfUnitDefinitions>\n');
    
    %sbml must have a compartment
    fprintf(sbmlfp, '\t\t<listOfCompartments>\n');
    fprintf(sbmlfp, '\t\t\t<compartment id="compartment" size="1">\n');
    fprintf(sbmlfp, '\t\t\t</compartment>\n');
    fprintf(sbmlfp, '\t\t</listOfCompartments>\n');
    
    %species
    if strcmp(model.speciesUnitsType, 'concentration')
        initialType = 'initialConcentration';
    else
        initialType = 'initialAmount';
    end
    
    fprintf(sbmlfp, '\t\t<listOfSpecies>\n');
    for i = 1:length(model.vnames)
        fprintf(sbmlfp, '\t\t\t<species id="%s" %s="%f" name="%s" compartment="compartment">\n',model.vnames{i}, initialType, model.init_cond(i), model.vardesc{i});
        fprintf(sbmlfp, '\t\t\t</species>\n');
    end
    fprintf(sbmlfp, '\t\t</listOfSpecies>\n');
    
    %parameters
    fprintf(sbmlfp, '\t\t<listOfParameters>\n');
    for i = 1:length(model.parn)
        fprintf(sbmlfp, '\t\t\t<parameter id="%s" name="%s" value="%f"/>\n', model.parn{i}, model.parnames{i}, model.parv(i));
    end
    if model.numforce > 0
        not_got_cp = true;
        for i = 1:length(model.sbml_force)
            %check if force i uses these params
            force_params = mathML_force(i).usesParams;
            if force_params.hasDawn
                fprintf(sbmlfp, '\t\t\t<parameter id="%s" name="%s" value="%f"/>\n', model.sbml_force(i).dawnname, model.sbml_force(i).dawnnotes, model.sbml_force(i).dawnvalue);
            end
            if force_params.hasDusk
                fprintf(sbmlfp, '\t\t\t<parameter id="%s" name="%s" value="%f"/>\n', model.sbml_force(i).duskname, model.sbml_force(i).dusknotes, model.sbml_force(i).duskvalue);
            end
            
            if force_params.hasCP && not_got_cp
                fprintf(sbmlfp, '\t\t\t<parameter id="%s" name="%s" value="%f"/>\n', model.sbml_cp.name, model.sbml_cp.notes, model.sbml_cp.value);
                not_got_cp = false;
            end
        end
    end
    
    fprintf(sbmlfp, '\t\t</listOfParameters>\n');
    
    
   
    
    %equations as rate rules
    fprintf(sbmlfp, '\t\t<listOfRules>\n');
    
    for i = 1:length(mathML_eqns)
        fprintf(sbmlfp, '\t\t\t<rateRule variable="%s">\n', model.vnames{i});
        fprintf(sbmlfp, '\t\t\t\t<math xmlns="http://www.w3.org/1998/Math/MathML">\n');
        
        rate_rule = mathML_eqns{i};
        %replace force with call to function
        for j = 1:model.numforce
            rate_rule = regexprep(rate_rule, ['<ci>' model.sbml_force(j).petssy_name '</ci>'], mathML_force(j).call);
        end
        
        fprintf(sbmlfp, '\t\t\t\t\t%s\n', rate_rule);
        fprintf(sbmlfp, '\t\t\t\t</math>\n');
        fprintf(sbmlfp, '\t\t\t</rateRule>\n');
    end
    
    fprintf(sbmlfp, '\t\t</listOfRules>\n');
    
    fprintf(sbmlfp, '\t</model>\n');
    fprintf(sbmlfp, '</sbml>');
    
    fclose(sbmlfp);
    
    updatebar(wbHndl, inc, 'done');
    
catch err
    delete(wbHndl);
    ShowError('There was an error creating the SBML file', err);
    ok = false;
    return;
end

delete(wbHndl);

ok = true;


