function r = exportForcePanel(varargin)


persistent myDir panel tblHndl model  parTblHndl fFileHndl
 
global title_fontsize
 
action = varargin{1};
r = [];

if strcmp(action, 'init')

    %creates controls on the first panel
    myDir = varargin{2};
    pos = varargin{3};
    fig = varargin{4 };
    
    maincol = get(fig, 'Color');
    
    panel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', maincol, ...
        'Units','centimeters', ...
        'Position',pos, ...
        'HandleVisibility', 'on', ...
        'visible', 'off', ...
        'Parent', fig);
    
    panelwidth = pos(3);panelheight=pos(4);
   
    uicontrol('Fontweight', 'bold', 'HorizontalAlignment', 'left','Parent',panel,'string', 'External force' ,'Units','centimeters','Style','text', 'position',[0.5 panelheight-1.1 panelwidth-4 0.7],'Visible', 'on','FontUnits', 'points', 'FontSize', title_fontsize, 'Backgroundcolor',maincol);

     uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', ['The model contains one or more external forces. These will be converted into SBML functions. You can change the name of these functions, add a description and select a force type which will provide the function body.'], ...
       'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-2.5 panelwidth-1 1.2],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
    
   tblpos = [0.5 panelheight-5.75 (panelwidth-1) 3];
   tblwidth = tblpos(3);
   pixels_per_cm = get(0, 'screenpixelsperinch')/2.54;
   tblwidth = tblwidth * pixels_per_cm;
   tblHndl = uitable('Units','centimeters', 'fontunits', 'points', 'fontsize', 10,...
       'parent', panel, 'position', tblpos, ...
       'ColumnName', {'Name', 'Description', 'Type'}, 'ColumnFormat', {'char', 'char', get_all_force_types()}, ... 
        'ColumnWidth', {tblwidth*0.2 tblwidth*0.5 tblwidth*0.2}, 'ColumnEditable', [true true true]);
    
     uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', ['The following force parameters will be converted into SBML parameters if they are relevant to the selected force type.'], ...
       'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-8.25 panelwidth-1 1.2],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
    uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string' ,'Select a file to provide their values:', 'units','centimeters','Style','text', ...
       'position',[0.5 panelheight-8.75 (panelwidth-1)/2 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
    fFileHndl=uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', {'-none-'} , 'value', 1, 'Units','centimeters','Style','popup', ...
       'position',[panelwidth/2 panelheight-8.65 4 0.7],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10);
   
   
    uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', ['You can edit the parameters below.'], ...
       'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-10 panelwidth-1 1.2],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
   tblpos = [0.5 panelheight-13.5 (panelwidth-1) 4];
   tblwidth = tblpos(3);
   pixels_per_cm = get(0, 'screenpixelsperinch')/2.54;
   tblwidth = tblwidth * pixels_per_cm;
   parTblHndl = uitable('Units','centimeters', 'fontunits', 'points', 'fontsize', 10,...
       'parent', panel, 'position', tblpos, ...
       'ColumnName', {'Name', 'Description', 'Value'}, 'ColumnWidth', {tblwidth*0.2 tblwidth*0.5 tblwidth*0.2}, 'ColumnEditable', [true true true]);

   
   
  
    
    r = panel;
    
elseif strcmp(action, 'show')
    
    %show controls and pass in data to be used to set them.
    
    if nargin > 1
        %moving to this panelfrom a previous one so data is passed
        %set controls according to this data
        model = varargin{2};
       
        tbldata = cell(model.numforce, 2);
        parTblData = cell(model.numforce*2+1, 3);
        for s = 1:model.numforce
           
           tbldata{s, 1} = model.force_type(s).name;
           tbldata{s, 3} = model.force_type(s).type; 
           
           parTblData{s*2-1, 1} = [model.force_type(s).name  '_dawn'];
           parTblData{s*2-1, 3} = model.force_type(s).dawn; 
           parTblData{s*2, 1} = [model.force_type(s).name  '_dusk'];
           parTblData{s*2, 3} = model.force_type(s).dusk; 
        end
        parTblData{end, 1} = 'cycle_period';
        parTblData{end, 3} = str2double(model.cycle_period);
        
        set(tblHndl, 'data', tbldata); 
        set(parTblHndl, 'data', parTblData);  
        
        ffiles = {'-none-'};
        f = dir(fullfile(model.dir, '*.fv'));
      
        for i = 1:length(f)
            ffiles{end+1} = f(i).name;
        end

       
        set(fFileHndl, 'string', ffiles);
        set(fFileHndl, 'callback', {@SelFFile, parTblHndl, model});
  
    end
    
  
    %otherwise, we a moving to this panel by going back. No data is passed
    
    set(panel, 'visible', 'on'); 

elseif strcmp(action, 'gonext')

    %called when user click Next.
   r = [];
    
    tbldata = get(tblHndl, 'data');
    parTbldata = get(parTblHndl, 'data');
    
    %record user edits, 
    
    for i = 1:size(tbldata, 1)
        
        model.sbml_force(i).name = tbldata{i,1}; %Ensure this is not a param or variable name!!!!
        model.sbml_force(i).petssy_name = model.force_type(i).name; %save original name that appears in odes
        
        ok = validName(model.sbml_force(i).name, model);
        if ~ok
            return;
        end            
        model.sbml_force(i).notes = fixXMLString(tbldata{i,2});
        model.sbml_force(i).type = tbldata{i,3};
                
        model.sbml_force(i).dawnname = parTbldata{i*2-1, 1};
        ok = validName(model.sbml_force(i).dawnname, model);
        if ~ok
            return;
        end 
        model.sbml_force(i).dawnnotes = fixXMLString(parTbldata{i*2-1, 2});               
        model.sbml_force(i).dawnvalue = parTbldata{i*2-1, 3};
        ok = validNumber(model.sbml_force(i).dawnvalue, model.sbml_force(i).dawnname);
        if ~ok
            return;
        end 

        model.sbml_force(i).duskname = parTbldata{i*2, 1};
        ok = validName(model.sbml_force(i).duskname, model);
        if ~ok
            return;
        end 
        model.sbml_force(i).dusknotes = fixXMLString(parTbldata{i*2, 2});
        model.sbml_force(i).duskvalue = parTbldata{i*2, 3};
        ok = validNumber(model.sbml_force(i).duskvalue, model.sbml_force(i).duskname);
        if ~ok
            return;
        end
        

    end
    model.sbml_cp.name = parTbldata{end, 1};
    ok = validName(model.sbml_cp.name, model);
    if ~ok
        return;
    end
    
    model.sbml_cp.notes = fixXMLString(parTbldata{end, 2});
    
    model.sbml_cp.value = parTbldata{end, 3};
    ok = validNumber( model.sbml_cp.value, model.sbml_cp.name);
    if ~ok
        return;
    end

   r = model;
   
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

%============================================
function SelFFile(hFile, event, hTbl, model)

%user has chosen an initial cond file


 fname = get(hFile, 'String');
idx = get(hFile, 'value');
fname = fname{idx};

parTblData = get(hTbl, 'data'); 

if strcmp(fname, '-none-')
    %no file, so fill in default  values
    for s = 1:model.numforce 
          
           parTblData{s*2-1, 3} = model.force_type(s).dawn; 
           parTblData{s*2, 3} = model.force_type(s).dusk; 
    end
   
  
else
    %read selected file
    fp = fopen(fullfile(model.dir, fname), 'rt');
    fvals = textscan(fp, '%s %s %f %f');
    fclose(fp);
    if size(fvals{1},1) ~= model.numforce
        ShowError('The selected force file is invalid.');
        return;
    end
    for s = 1:size(fvals{1},1)
        parTblData{s*2-1, 3} = fvals{3}(s);
        parTblData{s*2, 3} = fvals{4}(s);
    end
end

set(hTbl, 'data', parTblData);


%========================================================================

function ok = validName(name, model)

ok = false;
if any(strcmp(name, model.parn))
    ShowError([name ' is also the name of a model parameter. Please choose a different name. ']);
    return
end
if any(strcmp(name, model.vnames))
    ShowError([name ' is also the name of a model species. Please choose a different name. ']);
    return
end
if isempty(name)
    ShowError('Name cannot have an empty value.');
    return;
end
if isempty(regexp(name, '^[a-zA-Z_][a-zA-Z0-9_]*$', 'once'))
     ShowError([name ' : Function or parameter names will be mapped to SBML id attributes and so must consist of alphanumeric characters and underscores, and not begin with a digit.']);
     return; 
end
ok = true;

%=========================================================================

function ok = validNumber(value, name)

ok=false;
if isnan(value) || ~isnumeric(value) || isempty(value)
   ShowError(['Please enter a numeric value for ' name '.']);
   return;
end
ok=true;

