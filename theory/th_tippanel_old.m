function r = th_tippanel_old(action, varargin)

persistent panel status mainFig txtHndl hideHndl titleHndl previousMessages clear_highlight;

global rightMenu bottomMenu %need to remove check when panel closed

if strcmp(action, 'init')
    %create the panel, initially hidden in the top left corner of the gui
   
    mainFig = varargin{1};
   % maincol = get(mainFig, 'color');

    panel = uipanel('BorderType', 'etchedin', ...
        'Units','centimeters', ...
        'Position',[0 0 0.1 0.1], ...
        'visible', 'off', ...
        'Parent', mainFig);
    
    titleHndl = uicontrol('Parent',panel , ...
        'Style', 'text', 'horizontalalignment', 'left', ...
        'FontWeight', 'bold', 'FontUnits', 'points', 'FontSize', 10, ...
        'Units','centimeters', ...
        'position',[0 0 0.1 0.1], ...
        'string','User actions');

    txtHndl=uicontrol( ...
        'Style','listbox', ...
        'Units','centimeters', ...
        'position',[0 0 0.1 0.1], ...
        'Parent',panel, ...
        'BackgroundColor', 'w', ...
        'Max', 10, 'Min', 0, ...
        'horizontalalignment', 'left', ...
        'enable', 'inactive',...
        'string', cell(0), ...
        'value', [], ...
        'FontUnits', 'points', 'FontSize', 9);
    %use listbox as this can be scrolled
    
     hideHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[0 0 0.5 0.5], ...
        'string', 'X', ...
        'Parent',panel, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'tooltipstring', 'Close window', ...
        'Callback','th_tippanel(''hide'');'); 
    
    status = 'hidden';
    previousMessages = [];
    clear_highlight = false;
    
    r = panel;
    
elseif strcmp(action, 'show')
    %model has beens set at startup, or when user changed model menu
    pos = varargin{1};
    if strcmp(status, pos)
        %already shown in this place
        return;
    end

    if strcmp(pos, 'right')
        %extend figure by required amount
        formsize = get(mainFig, 'position');
        formsize(3) = 31;
        set(mainFig, 'position', formsize);
        
        if strcmp(status, 'bottom')
           %shrink height
            formsize(4)=18;
            %maintain position on screen
            formsize(2) = formsize(2)+4;
            set(mainFig, 'position', formsize);
            %shift panels upwards
            th_rightpanel('position');
            th_leftpanel('position');
            th_titlepanel('position');
        end
        set(panel, 'position', [formsize(3)-7 0.1 6.9 formsize(4)-0.3], 'visible', 'on');
        set(txtHndl, 'position', [0 0 6.8 formsize(4)-0.9]);
        set(titleHndl, 'position', [0.1 formsize(4)-0.9 4 0.45]);
        set(hideHndl, 'position', [6.3 formsize(4)-0.9 0.5 0.5]);
    else
        %show at bottom
        %extend figure by required amount
        formsize = get(mainFig, 'position');
        formsize(4) = 22;
        %dont let it go off top of screen
        formsize(2) = formsize(2)-4;
        set(mainFig, 'position', formsize);
        %shift panels upwards
        th_rightpanel('position');
        th_leftpanel('position');
        th_titlepanel('position');
        if strcmp(status, 'right')
           %shrink width
           formsize(3)=24;
           set(mainFig, 'position', formsize);
        end 
        set(panel, 'position', [0.1 0.1 formsize(3)-0.2 3.9], 'visible', 'on');
        set(txtHndl, 'position', [0 0 formsize(3)-0.3 3.35]);
        set(titleHndl, 'position', [0.1 3.3 4 0.45]);
        set(hideHndl, 'position', [formsize(3)-0.8 3.3 0.5 0.5]);
    end
    status = pos;
    scrollToEnd(txtHndl, status);
    
elseif strcmp(action, 'hide')
    
     if strcmp(status, 'hidden')
        return;
     end
        
     set(panel, 'position', [0 0 0.1 0.1], 'visible', 'off');
     set([titleHndl txtHndl], 'position', [0 0 0.1 0.1]);
     set(hideHndl, 'position', [0 0 0.5 0.5]);
     %shrink form
     formsize = get(mainFig, 'position');
     if strcmp(status, 'right')
         %shrink width
         formsize(3)=24;
         set(mainFig, 'position', formsize);
     else
         %shrink height
         formsize(4)=18;
         %maintain position on screen
         formsize(2) = formsize(2)+4;
         set(mainFig, 'position', formsize);
         %shift panels upwards
         th_rightpanel('position');
         th_leftpanel('position');
         th_titlepanel('position');
     end
    
     set([rightMenu bottomMenu], 'checked', 'off');
     status = 'hidden';
     
elseif strcmp(action, 'write')
   
    msg = varargin{1};
    if ischar(msg)
         msg = {msg};
    end
    %keep a record of messages to avoid repetitive ones
    if ~(length(msg) == length(previousMessages) && all(strcmp(msg, previousMessages)))

        if strcmp(status, 'right')
            linelength = 44;
        else
            linelength = 170;
        end

        msgtowrite = fixLineBreaks(msg, linelength);
        
        %add text to label
        str = get(txtHndl, 'string');
        %add extra blank line to separate messages, and so that scrolling works
        %to last line of text
        msgtowrite{end+1} = ' ';
        
        %make new part bold, remove bold from previous last message
        if clear_highlight
            str = strrep(str, '<html><b>', '');
            clear_highlight = false;
        end
        msgtowrite = strcat('<html><b>', msgtowrite);
        str = [str; msgtowrite'];
        set(txtHndl, 'string', str, 'value', []);
        scrollToEnd(txtHndl, status);
        previousMessages = msg;
   
    end

    %msgIdx = 0;
    %previousMessages = [previousMessages msgIdx];%clear could empty this
    
elseif strcmp(action, 'clear')

    set(txtHndl, 'string', cell(0));
    previousMessages = [];
    
elseif strcmp(action, 'clear_highlight')
      %sets a flag that removes text highlighting before next text is added that will be
      %highlighted. Usually called in response to user actions that make
      %previously highlighted text no longer applicable. Text is not
      %unhighlighted in response to cascading messages produced by the gui
      %as all these may remain relevant.
       clear_highlight = true;
       
end 

%======================================================================
function scrollToEnd(txtHndl, pos)


%ensure latest lines are visible
if strcmp(pos, 'right')
    maxlines = 30;
else
    maxlines = 6;
end
str = get(txtHndl, 'string');
drawnow;
pause(0.1);%needed or scrolling won't work??
set(txtHndl, 'ListboxTop', max(1, length(str)-maxlines));


%======================================================================
function r = fixLineBreaks(msg, linelength)

 % Add line breaks by breaking strings into multiple cell array
 % elements
 % msg is a cell array of strings to be broken up to no more than
 % linelength chars
 
 msgtowrite = cell(0);
 for m = 1:length(msg)
     msgline = msg{m};
     if length(msgline) > linelength
         %break into words
         spaces  = find(msgline == ' ');
         spaces = [1 spaces length(msgline)];
         breaks = 0;
         for i = 1:length(spaces)
             %find last space that can fit onto a line
             if spaces(i) > breaks(end)+linelength
                 breaks = [breaks spaces(i-1)];
             end
         end
         breaks = [breaks length(msgline)];
         for i = 1:length(breaks)-1
             msgtowrite{end+1} = msgline(breaks(i)+1:breaks(i+1));
         end
     else
         %line not too long
         msgtowrite{end+1} = msgline;
     end
     
 end
 
 r = msgtowrite;

    

 %what about when moving to side view?? Need to put line breaks in
 %exisitng lines
%hash vals
%help buttons on the panels
%use ButtonDownFcn to generate messages whenclicking on controls


%xpp

%clear button, next button
