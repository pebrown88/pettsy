function r = exportSavePanel(varargin)

persistent myDir panel  model   fileHndl browseHndl

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
    
    uicontrol('Fontweight', 'bold', 'HorizontalAlignment', 'left','Parent',panel,'string', 'Save SBML model' ,'Units','centimeters','Style','text', 'position',[0.5 panelheight-1.1 panelwidth-4 0.7],'Visible', 'on','FontUnits', 'points', 'FontSize', title_fontsize, 'Backgroundcolor',maincol);
    
    
    uicontrol('HorizontalAlignment', 'left','Parent',panel, ...
        'string', 'Enter the name of the SBML file to create and click Save to finish', ...
        'Units','centimeters','Style','text', ...
        'position',[0.5 panelheight-2.5 panelwidth-1 1.2],'Visible', 'on', ...
        'FontUnits', 'points', 'FontSize', 10, 'Backgroundcolor',maincol);
    
    fileHndl =uicontrol( ...
        'Style','edit', ...
        'HorizontalAlignment', 'left', ...
        'Units','centimeters', ...
        'position',[0.5 panelheight-3 panelwidth-3.5 0.8], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', [], ...
        'BackgroundColor', 'w');
    browseHndl =uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'position', [panelwidth-3 panelheight-3.1 2.5 0.9], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', 'Browse...', ...
        'call','exportSavePanel(''selectfile'');');
    
    
    r = panel;
    
elseif strcmp(action, 'show')
    
    %show controls and pass in data to be used to set them.
    
    if nargin > 1
        %moving to this panelfrom a previous one so data is passed
        %set controls according to this data
        model = varargin{2};
        
    end
    %otherwise, we a moving to this panel by going back. No data is passed
    
    set(panel, 'visible', 'on');
    
elseif strcmp(action, 'goback')
    
    set(panel, 'visible', 'off');
    
elseif strcmp(action, 'finished')
       
    sbmlFile = get(fileHndl, 'String');
    
    fp = fileparts(sbmlFile);
     
    if exist(fp, 'dir') ~= 7
        ShowError('The selected folder does not exist.');
        uicontrol(browseHndl);
        return;
    end
    
    if isempty(sbmlFile)
        ShowError('Please enter a file name.');
        uicontrol(browseHndl);
        return;
    end
    
    ok = writeSBMLFile(model, sbmlFile);
        
    if ok       
        msgbox(['Model ' model.name ' exported successfully.'], 'PeTTSy - Export model to SBML');       
    end
      
elseif strcmp(action, 'isvisible')
    
    r = get(panel, 'visible');
    if strcmp(r, 'on')
        r = 1;
    else
        r = 0;
    end
    
    
elseif strcmp(action, 'selectfile')
    
    %launch dialog box to select a file
    title = 'Select a file name to save';
    
    [fname, fpath] = uiputfile('*.xml',title, fullfile(model.dir, [model.name '.xml']));
    
    if ~isequal(fname, 0)
        %valid file selected
        set(fileHndl, 'String', fullfile(fpath,fname));
    end
    
end

%==========================================================================









