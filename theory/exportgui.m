function exportgui(varargin)

%gui for displaying the results structure so user can export it to the
%workspace

persistent mainFig closeHndl   exportHndl  timeSeriesData

if nargin > 0
    action = varargin{1};
else
    action = 'init';
end

if strcmp(action, 'init') && nargin > 1
    
    timeSeriesData = varargin{2};
    [p, name]  = fileparts(timeSeriesData.myfile);
    comment = '';
    switch timeSeriesData.plotting_timescale
        case 60
            tunits = 'minutes';
        case 1
            tunits = 'hours';
        case 3600
            tunits = 'seconds';
        otherwise
            tunits = '';
    end
   
    
    if strcmp(timeSeriesData.orbit_type, 'oscillator')
        if timeSeriesData.forced
            comment = ['The times series is a forced oscillator with period of ' num2str(timeSeriesData.per) ' ' tunits]; 
        else
            comment = ['The times series is an unforced oscillator with period of ' num2str(timeSeriesData.per) ' ' tunits]; 
        end
    else
        comment = ['The times series is a signal solution with length ' num2str(timeSeriesData.tend) ' ' tunits]; 
    end
    
    %draw controls
    tstr = ['Export data - ' name];
    mainFig=figure('resize', 'off','Menubar', 'none', 'Units', 'centimeters','Name',tstr ,'NumberTitle','off','Visible','off', 'windowstyle', 'modal');
    set(0,'Units','centimeters')
    screen_size = get(0,'ScreenSize');
    
    figwidth = 22;
    figheight = 18;
    set(mainFig, 'Units', 'centimeters', 'Position', [(screen_size(3)-figwidth)/2 (screen_size(4)-figheight)/2 figwidth figheight]);
    
    maincol = get(mainFig, 'Color');
    
    panelHeight = figheight-1.25;
    panelWidth = figwidth-0.5;
    frmPos=[0.25 1 panelWidth panelHeight];
    
    panel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', maincol, ...
        'Units','centimeters', ...
        'Position',frmPos, ...
        'HandleVisibility', 'on', ...
        'visible', 'on', ...
        'Parent', mainFig);
    
    %details of the data
    commentHndl = uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 panelHeight-1 panelWidth-1 0.5],'string',comment, 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
   
    uicontrol('HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 panelHeight-2 panelWidth-1 0.5],'string','Check the values you wish to export:', 'ForegroundColor', 'k', 'BackgroundColor', get(panel, 'backgroundcolor'), 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10, 'FontWeight', 'bold');
    

    exportHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figwidth-6.25 0.25 3 0.7], ...
        'Parent',mainFig, ...
        'string', 'Export', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','exportgui(''export'');');
    
    
    closeHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figwidth-3.25 0.25 3 0.7], ...
        'Parent',mainFig, ...
        'string', 'Close', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','exportgui(''close'');');
    
   
    %need tp specify position in pixels
    
    panelpos = get(panel, 'position'); %this is in cm
    set(panel, 'units', 'pixels');
    pxpos = get(panel, 'position'); %this is in pixels
    cmTopx = pxpos(3)/panelpos(3); %conversion factor
    
    treepos = [0.5 0.5 panelWidth-1 panelHeight-3] * cmTopx;
    createTree('init', panel, treepos, timeSeriesData, 1, 1); 

    %show figure
    set(mainFig,'Visible','on');
    
    
elseif strcmp(action, 'close')
    
    createTree('clear');
    delete(gcf);
    
elseif strcmp(action, 'export')
    
    structToExport = [];
    selectedPaths = createTree('get_selected');
    
    if isempty(selectedPaths)
        msgbox('Please select some data to export.', 'PeTTSy');return;
    end
    
    for s = 1:length(selectedPaths)
        %add to output struct
        eval(['structToExport' selectedPaths{s} ' = timeSeriesData' selectedPaths{s} ';']);
    end

    [p fname] = fileparts(timeSeriesData.myfile);
    %modify name if necessary to ensure it is unique,ie doesn't
    %overwrite an exisiting variable
    
    %generate a unique var name stored in base workspace variable
    %'varname'
    evalin('base', ['varname = genvarname(''' fname ''', who);']);
    %retrieve this
    varname = evalin('base', 'varname');
    %execute on base workspace, store results in variable called this
    assignin('base', varname, structToExport);
    %remove string variable 'varname'
    evalin('base', 'clear varname');
    %done
    uiwait(helpdlg(['Time series exported to the MATLAB workspace as variable ''' varname ''''],'Export data'));
    
end

%==========================================================================



