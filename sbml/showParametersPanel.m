function r = showParametersPanel(varargin)


persistent myDir panel tblHndl sbml_model species parameters 
 
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
   
    uicontrol('Fontweight', 'bold', 'HorizontalAlignment', 'left','Parent',panel,'string', 'Model parameters' ,'Units','centimeters','Style','text', 'position',[0.5 panelheight-1.1 panelwidth-4 0.7],'Visible', 'on','FontUnits', 'points', 'FontSize', title_fontsize, 'Backgroundcolor',maincol);

     uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', ['The SBML model contains the following parameters which will appear in the PeTTSy par file. ' ...
       'Check the Force column to indicate if any are external forces. These parameters will be replaced in the ' ...
       'model equations by a call to the PeTTSy force function.'], ...
       'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-2.5 panelwidth-1 1.2],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
    
   tblpos = [0.5 0.5 panelwidth-1 panelheight-3.5];
   tblwidth = tblpos(3);
   pixels_per_cm = get(0, 'screenpixelsperinch')/2.54;
   tblwidth = tblwidth * pixels_per_cm;
  tblHndl = uitable('Units','centimeters', 'fontunits', 'points', 'fontsize', 10,...
       'parent', panel, 'position', tblpos, ...
       'ColumnName', {'Name', 'Description', 'Value', 'Force'}, 'ColumnWidth', {tblwidth*0.2 tblwidth*0.4 tblwidth*0.2 tblwidth*0.1}, 'ColumnEditable', [true true true true]);

   
    
    r = panel;
    
elseif strcmp(action, 'show')
    
    %show controls and pass in data to be used to set them.
    
    if nargin > 1
        %moving to this panelfrom a previous one so data is passed
        %set controls according to this data
        data = varargin{2};
        sbml_model = data{1};
        species = data{2};
        parameters = data{3};
        
        
        tbldata = cell(length(parameters), 4);
        for s = 1:length(parameters)
           
           tbldata{s, 1} = char(parameters(s).Name); 
           tbldata{s, 2} = parameters(s).Description;
           tbldata{s, 3} = parameters(s).Value;
           if regexpi(tbldata{s, 1}, 'force')
                tbldata{s, 4} = true; %guess if a parameter is force
           else
            tbldata{s, 4} = false;
           end
        end
       
        set(tblHndl, 'data', tbldata);
    end
    %otherwise, we a moving to this panel by going back. No data is passed
    
    set(panel, 'visible', 'on'); 

elseif strcmp(action, 'gonext')

    %called when user click Next.
   r = [];
    
    %note forces
    tbldata = get(tblHndl, 'data');

    
    %reocrd user edits, keeping original names that appear in reactions
    
    for p = 1:size(tbldata, 1)
        
        
        [ok, errmsg] =isGoodName(tbldata{p,1});
        if ~ok
            ShowError(['Row ' num2str(p) ', ' errmsg]);
            return;
        end
    
        parameters(p).sassyname = tbldata{p,1}; %record users edit, keeping original name that is in reactions
   
        %TO DO:check for illegal name, ie matlab keyword
        
        parameters(p).Description = tbldata{p,2};
 
        if isnan(tbldata{p,3}) || ~isnumeric(tbldata{p,3}) || isempty(tbldata{p,3});
            ShowError(['Row ' num2str(p) ', please enter a numeric value.']);
            return;
        end
        parameters(p).Value = tbldata{p,3};
        parameters(p).isforce = tbldata{p,4};
    end
    
    %check for duplicates
    all_param_names = {parameters(:).sassyname};
    [~, uidx] = unique(all_param_names);
    duplicates = setdiff(1:length(parameters), uidx);
    
    if ~isempty(duplicates)
       ShowError(['Duplicate parameter name found at row ' num2str(duplicates(1))]);
       return;
    end
    
    %make sure none match species name
    
    all_species_names = {species(:).sassyname};
    [~, idx] = intersect(all_param_names, all_species_names);
    if ~isempty(idx)
       ShowError(['Parameter ' all_param_names{idx(1)} ' at row ' num2str(idx(1)) ' matches a species name.']);
       return;
    end
    %not force, force1, ...force9
    defined_forces = [parameters(:).isforce];
    matches=regexp(all_param_names, '^force\d?$');
    goodnames = cellfun(@isempty, matches);
    idx = find(~goodnames & ~defined_forces);
    if ~isempty(idx)
       ShowError(['Parameter at row ' num2str(idx(1)) ' cannot have the name ' all_param_names{idx(1)} ' if it is not an external force']);
       return;
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


