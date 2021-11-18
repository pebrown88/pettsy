function r = ConfigXPPGUI(action)

persistent  browserHndl helpHndl homeHndl browserBtnHndl helpBtnHndl newFig homeBtnHndl

global mydir

if strcmp(action, 'init')
    
    %draw figure
    if ispc
        binname = 'xppaut.exe';
    else
        binname = 'xppaut';
    end
    
    
    newFig=figure('resize', 'off', 'menubar', 'none' ,'Name', 'Configure XPPAUT launch' ,'NumberTitle','off', 'windowstyle', 'modal');
    set(0,'Units','centimeters')
    screen_size = get(0,'ScreenSize');
    
    figwidth = 15;
    figheight = 9;
    figleft = (screen_size(3) - figwidth)/2;
    figbottom = (screen_size(4) - figheight)/2;
    
    pos = [figleft figbottom figwidth figheight];
    set(newFig, 'Units', 'centimeters', 'Position', pos);
    
    maincol = get(newFig, 'Color');
    frmPos=[0.1 0.9 figwidth-0.2 figheight-1];
    
    panel = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', maincol, ...
        'Units','centimeters', ...
        'Position',frmPos, ...
        'HandleVisibility', 'on', ...
        'visible', 'on', ...
        'Parent', newFig);
    
    pheight = frmPos(4);
    pwidth = frmPos(3);
    
    uicontrol('Fontweight', 'bold', 'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-1.5 pwidth-1 0.6],'string','Location of your web browser:','BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    browserHndl =uicontrol( ...
        'Style','edit', ...
        'HorizontalAlignment', 'left', ...
        'Units','centimeters', ...
        'position',[0.5 pheight-2 pwidth-3 0.6], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'BackgroundColor', 'w', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', []);
    
    browserBtnHndl =uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'position',[pwidth-2.5 pheight-2 2 0.6], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', 'Browse ...', ...
        'call','ConfigXPPGUI(''browser'');');
   uicontrol('HorizontalAlignment', 'right','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-2.75 pwidth-3 0.6],'string','Optional, but will enable XPPAUT to launch html help files','BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);

    uicontrol('Fontweight', 'bold', 'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-3.75 pwidth-1 0.6],'string','Location of your XPPAUT help directory:','BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    helpHndl =uicontrol( ...
        'Style','edit', ...
        'HorizontalAlignment', 'left', ...
        'Units','centimeters', ...
        'position',[0.5 pheight-4.25 pwidth-3 0.6], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'BackgroundColor', 'w', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', []);
    
    helpBtnHndl =uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'position',[pwidth-2.5 pheight-4.25 2 0.6], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', 'Browse ...', ...
        'call','ConfigXPPGUI(''help'');');
   uicontrol('HorizontalAlignment', 'right','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-5 pwidth-3 0.6],'string','Optional, but will enable XPPAUT to launch html help files','BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);

    uicontrol('Fontweight', 'bold', 'HorizontalAlignment', 'left','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-6 pwidth-1 0.6],'string','XPPAUT installation directory:','BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);
    homeHndl =uicontrol( ...
        'Style','edit', ...
        'HorizontalAlignment', 'left', ...
        'Units','centimeters', ...
        'position',[0.5 pheight-6.5 pwidth-3 0.6], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'BackgroundColor', 'w', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', []);
    
    homeBtnHndl =uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'position',[pwidth-2.5 pheight-6.5 2 0.6], ...
        'HandleVisibility', 'on', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'String', 'Browse ...', ...
        'call','ConfigXPPGUI(''home'');');
   uicontrol('HorizontalAlignment', 'right','Parent',panel ,'Style', 'text','Units','centimeters','position',[0.5 pheight-7.25 pwidth-3 0.6],'string',['Required, the directory where the ' binname ' binary file is found'],'BackgroundColor', get(newFig, 'Color'), 'ForegroundColor', 'k', 'HandleVisibility', 'on', 'FontUnits', 'points', 'FontSize', 10);


    %OK and Cancel buttons
    
    cancelHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figwidth-2.1 0.1 2 0.7], ...
        'Parent',newFig, ...
        'string', 'Cancel', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','delete(gcf)');
    
    OKHndl = uicontrol(...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figwidth-4.1 0.1 2 0.7], ...
        'Parent',newFig, ...
        'string', 'OK', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Callback','ConfigXPPGUI(''ok'')');
    
    %fill in current values if set
    
    
    if ispc
       fname = fullfile(mydir, 'xpp', ['runxpp.bat']);
       if exist(fname, 'file') == 2
           fid = fopen(fname, 'rt');
           content = textscan(fid, '%s\n');
       end
    else
       fname = fullfile(mydir, 'xpp', ['runxpp.sh']);
       if exist(fname, 'file') == 2
            fid = fopen(fname, 'rt');
            while ~feof(fid)
                content = textscan(fid, '%s', 1);
                val = regexpi(content{1}, 'BROWSER="(.+)"', 'tokens');
                if ~isempty(val)
                    val = val{1};
                    if ~isempty(val)
                        set(browserHndl, 'string', char(val{1}));
                    end
                end
                val = regexpi(content{1}, 'XPPHELP="(.+)\/xpphelp.html"', 'tokens');
                if ~isempty(val)
                    val = val{1};
                    if ~isempty(val)
                        set(helpHndl, 'string', char(val{1}));
                    end
                end
                val = regexpi(content{1}, '"(.+)\/xppaut"', 'tokens');
                if ~isempty(val)
                    val = val{1};
                    if ~isempty(val)
                        set(homeHndl, 'string', char(val{1}));
                    end
                end
            end
            
           
       end
    end
    
    
elseif strcmp(action, 'ok')
    
    %write the launch script
    
    browser = get(browserHndl, 'string');
    helpdir = get(helpHndl, 'string');
    homedir =  get(homeHndl, 'string');
   
    if ispc
        ext = 'bat' ;
    else
        ext='sh';
    end
    
    fname = fullfile(mydir, 'xpp', ['runxpp.' ext]);
    fid = fopen(fname, 'wt');
    if fid < 0
        ShowError('Error setting XPPAUT launch script. Cannot create launch script, permission denied.');
        return;
    end
    if ispc  
        fprintf(fid, 'set BROWSER="%s"\n',browser);
        fprintf(fid, 'set XPPHELP="%s\\xpphelp.html"\n',helpdir);
        fprintf(fid, 'set HOME="%s"\n',homedir);
        fprintf(fid, 'set DISPLAY=127.0.0.1:0\n');
        xppbin = fullfile(homedir, 'xppaut');
        fprintf(fid, '"%s" %%1\n', xppbin);
    else
        if ismac
            fprintf(fid, '#!/bin/bash\n');
        else
           %don't know path to shell interpreter on other platforms
           [r loc] = system('which bash');
           fprintf(fid, ['#!' loc '\n']);
        end
        fprintf(fid, 'export BROWSER="%s"\n',browser);
        fprintf(fid, 'export XPPHELP="%s/xpphelp.html"\n',helpdir);
        xppbin = fullfile(homedir, 'xppaut');
        fprintf(fid, '"%s" $1\n', xppbin);
    end
    
    fclose(fid);
    if ~ispc
        system(['chmod 755 ' fname]);
    end
    delete(newFig);
    
elseif strcmp(action, 'browser')
    
    title = 'Locate your web browser:';
    if ispc
        filter = '*.exe';
    elseif ismac
        filter = '*.*';
    else
        filter = '*.*';
    end
    
    [FileName,PathName] = uigetfile(filter,title);
    
    if ~isequal(FileName, 0)
       %valid file selected
       set(browserHndl, 'String', fullfile(PathName, FileName));
    end
    
    
elseif strcmp(action, 'help')
    
    title = 'Locate your XPPAUT help directory';
    
    if ispc
        startdir = 'C:\';
    else
        startdir = '/';
    end
       
    dirname = uigetdir(startdir,title);
    
    if ~isequal(dirname, 0)
       %valid file selected
       set(helpHndl, 'String', dirname);
    end
    
elseif strcmp(action, 'home')
    
  title = 'Locate your XPPAUT installation directory';
  
   if ispc
        startdir = 'C:\';
    else
        startdir = '/';
    end
       
    dirname = uigetdir(startdir, title);
    
    if ~isequal(dirname, 0)
       %valid file selected
       set(homeHndl, 'String', dirname);
    end
    
end

r = newFig;