%creates a wizard for importing sbml files

function exportsbmlgui(varargin)


persistent myDir;
persistent timerHndl panelfuncs cancelHndl backHndl nextHndl finishedHndl sbmlFig currentpanel;

global title_fontsize;
title_fontsize = 11;

action = varargin{1};
if nargin > 1
    data = varargin{2};
else
    data = [];
end

if strcmp(action,'init') && isstruct(data)
    
    model = data;
    %create the gui and controls
    myDir = fileparts(mfilename('fullpath'));
    sbmlFig=figure( 'resize', 'off', 'Menubar', 'none', 'Units', 'normalized','Name','PeTTSy - Export Model to SBML' ,'NumberTitle','off','Visible','off', 'CloseRequestFcn', 'exportsbmlgui(''close'')');
    %   'WindowStyle', 'modal', set(mainFig, 'Position', [0.15 0.15 0.7 0.7]);
    
    set(0,'Units','centimeters')
    screen_size = get(0,'ScreenSize');
    
    figwidth = 18;%min(24, screen_size(3)*0.7);
    figheight = 18;%figwidth * 0.8;
    set(sbmlFig, 'Units', 'centimeters', 'Position', [(screen_size(3)-figwidth)/2 (screen_size(4)-figheight)/2 figwidth figheight]);

    maincol = get(sbmlFig, 'Color');
    
    %define a series of panels that the user must move through
   
    frmPos=[0.5 1.5 figwidth-1  figheight-2.5];
    if model.numforce > 0
        panelfuncs = {@exportSBMLInfoPanel; @showExportModelPanel; @exportSpeciesPanel; @exportParametersPanel; @exportForcePanel; @exportSavePanel};  
    else
        panelfuncs = {@exportSBMLInfoPanel; @showExportModelPanel; @exportSpeciesPanel; @exportParametersPanel; @exportSavePanel};
    end
    
    for i = 1:length(panelfuncs)
        panels(i) = feval(panelfuncs{i}, 'init', myDir, frmPos, sbmlFig);
    end  
    
 
    %navigation buttons
    leftpos = 0.5;
    sep = 0.5;
    btnlen = (figwidth-1 - 3*sep)/4;
    cancelHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[leftpos 0.4 btnlen 0.9], ...
        'Parent',sbmlFig, ...
        'string', 'Close', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','exportsbmlgui(''cancel'');');
    leftpos = leftpos + btnlen+sep;
    backHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[leftpos 0.4 btnlen 0.9], ...
        'Parent',sbmlFig, ...
        'string', '<Back', ...
        'enable', 'off', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','exportsbmlgui(''back'');');
    leftpos = leftpos + btnlen+sep;
    nextHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[leftpos 0.4 btnlen 0.9], ...
        'Parent',sbmlFig, ...
        'string', 'Next>', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','exportsbmlgui(''next'');');
    leftpos = leftpos + btnlen+sep;
    finishedHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[leftpos 0.4 btnlen 0.9], ...
        'Parent',sbmlFig, ...
        'string', 'Save', ...
         'enable', 'off', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','exportsbmlgui(''finished'');');
 
    
    %axes to hold animated timer image
    timerHndl = axes('parent', sbmlFig, ...
        'Units','centimeters', ...
        'Position', [22.5 18 0.75 0.75], ...
        'xtick', [], 'ytick', [], ...
        'xcolor', maincol, 'ycolor', maincol, ...
        'visible', 'off');
    
    %finally show figure
    currentpanel = 1;
    feval(panelfuncs{currentpanel}, 'show',model);
        
    set(sbmlFig,'Visible','on');
    
elseif strcmp(action, 'back')
    %move to previous panel
    
    idx = [];
    for i = 1:length(panelfuncs)
       v = feval(panelfuncs{i}, 'isvisible');
       if v
           idx = i;
           break;
       end
    end
    
    %hide current panel
    feval(panelfuncs{idx}, 'goback');
    %show previous one
    idx = idx-1;
    feval(panelfuncs{idx}, 'show'); 
        
    if idx < length(panelfuncs)
        set(nextHndl, 'enable', 'on')
        set(finishedHndl, 'enable', 'off');
        if idx == 1
            set(backHndl, 'enable', 'off');
        end
    end
    currentpanel = idx;
        
elseif strcmp(action, 'next')

    %move to next panel
    set(sbmlFig, 'pointer', 'watch');
    set([backHndl nextHndl], 'enable', 'off');drawnow;
    idx = [];
    for i = 1:length(panelfuncs)
       v = feval(panelfuncs{i}, 'isvisible');
       if v
           idx = i;
           break;
       end
    end
    
    %hide current panel and return data modified according to its control
    %settings

    data = feval(panelfuncs{idx}, 'gonext');
    
    if ~isempty(data)
        %controls were valid so move to next panel, and pass data
        idx = idx+1;
        feval(panelfuncs{idx}, 'show', data);
    end
    
    if idx > 1
        set(backHndl, 'enable', 'on')
        if idx == length(panelfuncs)
            set(nextHndl, 'enable', 'off');
            set(finishedHndl, 'enable', 'on');
        else
             set(nextHndl, 'enable', 'on');
            set(finishedHndl, 'enable', 'off');
        end
    else
        set(nextHndl, 'enable', 'on');
    end
    
    currentpanel = idx;
     set(sbmlFig, 'pointer', 'default');
    
elseif strcmp(action, 'finished')

    %save new model and quit
    
    for i = 1:length(panelfuncs)
       v = feval(panelfuncs{i}, 'isvisible');
       if v
           feval(panelfuncs{i}, 'finished');
           break;
       end
    end
  
  
elseif strcmp(action, 'cancel')
    
    delete(gcf);
   
    
end






