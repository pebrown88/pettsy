function spec = get_plot_style(i)

%returns a linespec string for plot function based on index i

%should be 7 * 4 = 28 combinations

col={'b','r','g','k', 'c', 'm','y'};
style = {'-', '--', ':', '-.'};

colIdx = mod(i-1, length(col))+1;
specIdx = mod(ceil(i/length(col))-1, length(style))+1;

spec = [col{colIdx} style{specIdx}];