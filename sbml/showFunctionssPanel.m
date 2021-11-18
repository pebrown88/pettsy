function r = showFunctionssPanel(varargin)


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
   
    uicontrol('Fontweight', 'bold', 'HorizontalAlignment', 'left','Parent',panel,'string', 'Model functions' ,'Units','centimeters','Style','text', 'position',[0.5 panelheight-1.1 panelwidth-4 0.7],'Visible', 'on','FontUnits', 'points', 'FontSize', title_fontsize, 'Backgroundcolor',maincol);

    
     uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', ['The SBML model contains the following functions. ' ...
       'Check the Force column to indicate if any are external forces. ' ... 
       'As PeTTSy does not support user-defined functions within model ODEs, calls to force functions will be replaced ' ...
       'by a call to the PeTTSy force function, and other functions will be replaced by their function body. '], ...
        'Units','centimeters','Style','text', ...
       'position',[0.5 panelheight-3.3 panelwidth-1 2],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
    
   tblpos = [0.5 2 panelwidth-1 panelheight-5.3];
   tblwidth = tblpos(3);
   pixels_per_cm = get(0, 'screenpixelsperinch')/2.54;
   tblwidth = tblwidth * pixels_per_cm;
    tblHndl = uitable('Units','centimeters', 'fontunits', 'points', 'fontsize', 10,...
       'parent', panel, 'position', tblpos, ...
       'ColumnName', {'Name', 'Description', 'Force'}, 'ColumnWidth', {tblwidth*0.2 tblwidth*0.6 tblwidth*0.1}, 'ColumnEditable', [false false true]);

    uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
       'string', ['If the model includes a force function that is not one of the PeTTSy force functions,then this can be added ' ...
       'seperately as a new force defininiton.'], ...
        'Units','centimeters','Style','text', ...
       'position',[0.5 0.5 panelwidth-1 1],'Visible', 'on', ...
       'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
   
    
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
       
        tbldata = cell(length(sbml_model.functionDefinition), 3);
        for s = 1:length(sbml_model.functionDefinition)
           
           tbldata{s, 1} = sbml_model.functionDefinition(s).id; 
           tbldata{s, 2} = sbml_model.functionDefinition(s).name;
           
           notes = sbml_model.functionDefinition(s).notes;
           notes = strrep(notes, sprintf('\n'), '');
          
           if ~isempty(notes)
                notes = strtrim(notes);
               notes = notes(1:min(length(notes),100));
               tbldata{s, 2} = [tbldata{s, 2} ', ' notes];
           end
           
           if regexpi(tbldata{s, 1}, 'force')
                tbldata{s, 3} = true; %guess if a parameter is force
           else
                tbldata{s, 3} = false;
           end
        end
       
        set(tblHndl, 'data', tbldata);
    end
    %otherwise, we a moving to this panel by going back. No data is passed
    
    set(panel, 'visible', 'on'); 

elseif strcmp(action, 'gonext')

    %called when user click Next.
   
    %note forces
    tbldata = get(tblHndl, 'data');
    for f = 1:size(tbldata, 1)
        sbml_model.functionDefinition(f).isforce = tbldata{f, 3};
    end
    
    r{1} = sbml_model;
    r{2} = species;
    r{3} = parameters;
    
    %TO DO: can't have a function called force in sbml if it isn't a force
   

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


