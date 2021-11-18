function result = create_sortable_table(hTable, colwidths, selection)

%hTable is the matlab table
%colwidths a vector of column width expressed as proportions (0 to 1)
%selection is a flag to indicate if table needs a column with checkboxes to
%allow user to select entries

%other table properties are set in Matlab

%output argument is true for success, false for failure

%This function must be called after the table is made visible, or java
%object won't be found. This can happen either before or after data is
%added to the table for the first time.

result = false;

try
    import javax.swing.*
    import java.awt.*
    pxpos = getpixelposition(hTable);
    
    jscrollpane = [];
    attempts = 1;
    while isempty(jscrollpane)
        %there can be a delay before this object appears, even
        %though function has completed.
        if attempts > 3
            exception = MException('findjobj:ObjectNotFound', ...
                'Could not find the java object for the table');
            throw(exception);
        end
        drawnow;
        jscrollpane = findjobj(hTable);
        attempts = attempts+1;
    end
    if ~isempty(jscrollpane)
        
        %scroll bars
        jscrollpane.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
        jscrollpane.setHorizontalScrollBarPolicy(ScrollPaneConstants.HORIZONTAL_SCROLLBAR_AS_NEEDED);
        
        %make rows sortable
        jtable = jscrollpane.getViewport.getView;
        jtable.setSortable(true);
        jtable.setAutoResort(false);
        jtable.setMultiColumnSortable(true);
        jtable.setShowSortOrderNumber(false);
        %re-sizing cols
        jtable.setAutoResizeMode(jtable.AUTO_RESIZE_NEXT_COLUMN);
        
        if selection
            %set width of first col
            jcol = jtable.getColumnModel.getColumn(0); %note java array zero based
            jcol.setResizable(false);
            jcol.setMaxWidth(25);
            jcol.setPreferredWidth(25);
            first_col = 1;
        else
            first_col = 0;
        end
        
        %other cols resizeable
    
        for c = first_col:jtable.getColumnCount-1;
            cwidth = fix((pxpos(3)-30) * colwidths(c));
            jcol = jtable.getColumnModel.getColumn(c);
            jcol.setResizable(true);
            jcol.setPreferredWidth(cwidth);
           
        end
        
        %can only access header if data exists
        if ~isempty(jtable.getColumnModel.getColumn(0).getHeaderRenderer())
            jtable.getColumnModel.getColumn(0).getHeaderRenderer.setToolTipText('Click on a column heading to sort the list');
        end
        
        %needed to prevent blue box which exposes prefixes
        jtable.setSelectionBackground(java.awt.Color.white)
        jtable.setSelectionForeground(java.awt.Color.black)
        
        %save java object
        user_data = get(hTable, 'Userdata');
        user_data.jtable = jtable;

        set(hTable, 'Userdata', user_data);
    end
    
catch err
    ShowError('Java Error', err);
    return;
end

result = true;
return;
