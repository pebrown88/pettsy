function pos = get_size_of_figure(varargin)

%returns a suitable size for a single figure that should fill most of the
%screen

if nargin > 0 && strcmp(varargin{1}, 'cm')
    %retun szie in cm
    
set(0,'Units','centimeters');
screen_size = get(0,'ScreenSize');
figheight = 18;
figwidth = 24;
figleft = (screen_size(3) - figwidth)/2;
figbottom = (screen_size(4) - figheight)/2;
pos = [figleft figbottom figwidth figheight];

else
    %default is normalised
    set(0,'Units','normalized')
    pos = [0.2 0.2 0.6 0.6];
end
