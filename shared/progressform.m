function progressform(action, varargin)

%displays a message and a progress bar

persistent progFig barHndl barInc txtHndl tm num_div interval maxWidth okHndl


if strcmp(action, 'init')
    
    %create figure
    barInc = varargin{1}; %number of large increments to complete the bar. 
                            %This should be the number of times
                            %progressform('progress', ...) is called 
    interval = varargin{2}; %max length of time that bar takes to advance one large increment,
                            %under the control of the timer in seconds
                            %This should be a guess at the interval between
                            %calls to progressform('progress', ...)
                                              
    
    progFig=figure('WindowStyle', 'modal', 'menubar', 'none', 'resize', 'off', 'Units', 'centimeters','Name','New Solution' ,'NumberTitle','off','Visible','on', 'CloseRequestFcn', 'progressform(''ok'')');

    set(0,'Units','centimeters')
    screen_size = get(0,'ScreenSize');
    figwidth = 14;
    figheight = 10;
    figleft = (screen_size(3) - figwidth)/2;
    figbottom = (screen_size(4) - figheight)/2;
    set(progFig, 'Units', 'centimeters', 'Position', [figleft figbottom figwidth figheight]);

    % The panel
    panelheight = figheight-1.2;
    panelwidth = figwidth-0.2;
    panelHndl = uipanel('BorderType', 'etchedin', ...
        'BackgroundColor', get(progFig, 'Color'), ...
        'Units','centimeters', ...
        'Position',[0.1 1.1  panelwidth panelheight], ...
        'HandleVisibility', 'on', ...
        'Parent', progFig, 'Visible', 'on');
    
    %list box that will contain text
     txtHndl=uicontrol( ...
                            'Style','listbox', ...
                            'Units','centimeters', ...
                            'position',[0.4 1 figwidth-1 figheight-2.7], ...
                            'min', 1, 'max', 1, ...
                            'HandleVisibility', 'on', ...
                            'Parent',panelHndl, ...
                            'string', {' '}, ...
                            'value', [], ...
                            'min', 1, 'max', 10, ...
                            'enable', 'inactive', ...
                            'FontUnits', 'points', 'FontSize', 10);
          
   
    %progress bar
    barHndl = uicontrol('style', 'text', 'Units','centimeters', 'Position', [0.4 0.2 0.1 0.6],'Parent',panelHndl, 'BackgroundColor', 'r', 'ForegroundColor', 'r' );
    maxWidth = figwidth-1;
    
    %num_div is number of small steps in one large increment. Scale so each is approx 0.1 mm on
    %screen
    num_div = ceil(maxWidth/barInc)*10;
     
    %close button
     okHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figwidth-2.6 0.1 2.5 0.8], ...
        'Interruptible','on', ...
        'BackgroundColor', get(progFig, 'Color'), ...
        'string', 'OK', ...
        'HandleVisibility', 'on', ...
        'Parent',progFig, ...
        'FontUnits', 'points', 'FontSize',10, ...
        'FontWeight', 'bold', ...
        'enable', 'off', ...
        'Callback','progressform(''ok'');'); 
    
    %pointer
    set(progFig, 'pointer', 'watch');
    
    %start timer
    
    tm = timer('TimerFcn', {@timer_update, num_div, barHndl, barInc, maxWidth}, 'ExecutionMode', 'fixedRate', 'Period', interval/num_div, 'TasksToExecute', num_div);
    start(tm);
    
    drawnow;
  
elseif strcmp(action, 'progress') || strcmp(action, 'write')
    
    %write text
    if nargin > 1
        str = varargin{1};
        lst = get(txtHndl, 'string');
        
        lst{end} = str;

        lst{end+1} = ' '; %add extra blank line so scrolling works
        set(txtHndl, 'string', lst, 'value', []);
        
        %ensure latest lines are visible
        set(txtHndl, 'ListboxTop', max(1, length(lst)-16));
    end

    if strcmp(action, 'progress')
        %increment bar
        %move to end of current block (large increment), and reset timer for the next
        if strcmp(get(tm, 'Running'), 'on')
            stop(tm);
            num = get(tm, 'TasksExecuted');
            for i = 1:num_div-num
                timer_update(tm, [], num_div, barHndl, barInc, maxWidth)
            end
        end
        start(tm);
    end
    
elseif strcmp(action, 'end')
    
    stop(tm);
    delete(tm);
    pos = get(barHndl, 'position');
    pos(3) = maxWidth;
    set(barHndl, 'Position', pos);
    drawnow;   
    
    set(okHndl, 'enable', 'on');
    set(progFig, 'pointer', 'arrow');
    
elseif strcmp(action, 'ok')
    
    delete(progFig);
    
end


%===========================================
function timer_update(tm ,data, num_div, barHndl, barinc, maxwidth)

barlen = get(barHndl, 'Position');
barlen(3) = min(barlen(3) + maxwidth /(barinc*num_div), maxwidth);
set(barHndl, 'Position', barlen);
drawnow;
