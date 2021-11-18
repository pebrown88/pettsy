

function r = showSpeciesPanel(varargin)


persistent myDir panel tblHndl sbml_model species
 
global title_fontsize
 
action = varargin{1};
r = [];

if strcmp(action, 'init')

    %creates controls on the first panel
    myDir = varargin{2};
    pos = varargin{3};
    fig = varargin{4};
    
    maincol = get(fig, 'Color');
    
    panel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', maincol, ...
        'Units','centimeters', ...
        'Position',pos, ...
        'HandleVisibility', 'on', ...
        'visible', 'off', ...
        'Parent', fig);
    
    panelwidth = pos(3);panelheight=pos(4);
   
    uicontrol('Fontweight', 'bold', 'HorizontalAlignment', 'left','Parent',panel,'string', 'Model species' ,'Units','centimeters','Style','text', 'position',[0.5 panelheight-1.1 panelwidth-4 0.7],'Visible', 'on','FontUnits', 'points', 'FontSize', title_fontsize, 'Backgroundcolor',maincol);

    
   uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', 'The SBML model contains the following Species, which will be converted into PeTTSy variables.' ,'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-2 panelwidth-1 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    
   tblpos = [0.5 0.5 panelwidth-1 panelheight-3];
   tblwidth = tblpos(3);
   pixels_per_cm = get(0, 'screenpixelsperinch')/2.54;
   tblwidth = tblwidth * pixels_per_cm;
   tblHndl = uitable('Units','centimeters', 'fontunits', 'points', 'fontsize', 10,...
       'parent', panel, 'position', tblpos, ...
       'ColumnName', {'Name', 'Description', 'Initial value'}, 'ColumnWidth', {tblwidth*0.2 tblwidth*0.5 tblwidth*0.2}, 'ColumnEditable', [true true true]);

   
    
    r = panel;
    
elseif strcmp(action, 'show')
    
    %show controls and pass in data to be used to set them.
    
    if nargin > 1
        %moving to this panelfrom a previous one so data is passed
        %set controls according to this data
        data = varargin{2};
        sbml_model = data{1};
        species = data{2};
        
        tbldata = cell(length(species), 3);
        for s = 1:length(species)
           tbldata{s, 1} = char(species(s).Name);       
           tbldata{s, 2} = species(s).Description;
           tbldata{s, 3} = species(s).initialValue;
        end
       
        set(tblHndl, 'data', tbldata);
    end
    %otherwise, we a moving to this panel by going back. No data is passed
    
    set(panel, 'visible', 'on'); 

elseif strcmp(action, 'gonext')

    %called when user click Next.
   
    r = [];
    tbldata = get(tblHndl, 'data');
    for s = 1:size(tbldata, 1)
        [ok, errmsg] =isGoodName(tbldata{s,1});
        if ~ok
            ShowError(['Row ' num2str(s) ', ' errmsg]);
            return;
        end
  
        species(s).sassyname = tbldata{s,1}; %record users edit, keeping original name that is in reactions
        species(s).Description = tbldata{s,2}; %record users edit
        if isnan(tbldata{s,3}) || ~isnumeric(tbldata{s,3}) || isempty(tbldata{s,3});
            ShowError(['Row ' num2str(s) ', please enter a numeric value.']);
            return;
        end
        species(s).initialValue = tbldata{s,3};
        species(s).sassy_vec_name = ['y(' num2str(s) ')'];
        
    end
    all_sassy_names = {species(:).sassyname};
    [~, uidx] = unique(all_sassy_names);
    duplicates = setdiff(1:length(species), uidx);
    
    if ~isempty(duplicates)
       ShowError(['Duplicate species name found at row ' num2str(duplicates(1))]);
       return;
    end
    
    matches=regexp(all_sassy_names, '^force\d?$');
    goodnames = cellfun(@isempty, matches);
    idx = find(~goodnames);
    if ~isempty(idx)
       ShowError(['Species at row ' num2str(idx(1)) ' cannot have the name ' all_sassy_names{idx(1)} ' as it is not an external force']);
       return;
    end
    
    %TO DO check for illegal names, eg matlab keywords

    %TO DO progress bar
    
    %now analyse model params for next screen
    [ParameterNames, ParameterValues] = GetAllParametersForSASSy(sbml_model);
    parameters = [];
    for i = 1:length(ParameterNames)
        parameters(i).Name = ParameterNames{i};%comes from ID attribute
        parameters(i).Value = ParameterValues(i);
        
        %Only works for global parameters at top level, ie <model><listOfParameters> ... </listOfParameters></model>
        %Doesn't look at <reaction><kineticlaw><listOfParameters> ...
        %</listOfParameters></kineticlaw></reaction>
        
       
    end
    
    for i = 1:length(sbml_model.parameter)
        
        if strcmp( parameters(i).Name, sbml_model.parameter(i).id)
            parameters(i).Description = sbml_model.parameter(i).name; 
        else
            parameters(i).Description = parameters(i).Name;
        end
        
        notes = regexprep(sbml_model.parameter(i).notes, '<[^>]+>', '');
        notes = strrep(notes, sprintf('\n'), '');
       
        if ~isempty(notes) 
              notes = strtrim(notes);
            notes = notes(1:min(length(notes),100));
           parameters(i).Description = [parameters(i).Description ', ' notes];
        end
        
        %name NOT READ from FILE by libSBML
        
    end
    
    r{1} = sbml_model;
    r{2} = species;
    r{3} = parameters;
    
    set(panel, 'visible', 'off');

    
elseif strcmp(action, 'goback') 
   
    set(panel, 'visible', 'off');
    
elseif strcmp(action, 'isvisible') 
    
    r = get(panel, 'visible');
    if strcmp(r, 'on')
        r = 1;
    else
        r = 0;
    end 
    

end


