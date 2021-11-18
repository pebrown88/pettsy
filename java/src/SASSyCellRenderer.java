import java.awt.*;
import java.util.*;
import javax.swing.*;
import javax.swing.table.*;

public class SASSyCellRenderer extends
DefaultTableCellRenderer implements TableCellRenderer
{
    private int _eventTypeLookupColumn = -1;
	private Hashtable _cellTooltipHashtable = new Hashtable();

    public Component getTableCellRendererComponent(JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int column)
    {
        JComponent cell = (JComponent)
        super.getTableCellRendererComponent(table, value, isSelected, hasFocus, row, column);
        String valueStr = "" + value;
        Vector rowColVector = getRowColVector(row, column);
        
        // If this cell should have a specific tooltip, then use it
        String cellTooltip = (String)_cellTooltipHashtable.get(rowColVector);
        if ((cellTooltip == null) || (cellTooltip.length() == 0))
        {
            // No specific tooltip set, so use the cell's string value as the tooltip
            if (value == null)
                cell.setToolTipText(null);
            else if (valueStr.length() > 200)
            {
                // Split long tooltip text into several smaller lines
                String tipText = "<html>";
                int MAX_CHARS_PER_LINE = 150;
                int strLen = valueStr.length();
                for (int lineIdx=0; lineIdx <= strLen/MAX_CHARS_PER_LINE;lineIdx++)
                    tipText = tipText.concat(valueStr.substring(lineIdx*MAX_CHARS_PER_LINE,Math.min((lineIdx+1)*MAX_CHARS_PER_LINE,strLen))).concat("<br>");
                cell.setToolTipText(tipText);
            }
            else
                cell.setToolTipText(valueStr);
        }
        else
        {
            cell.setToolTipText(cellTooltip);
        }

        return cell;
    }

   
    public void resetTooltips()
    {
        _cellTooltipHashtable.clear();
    }

    
    public void setCellTooltip(int row, int column, String text)
    {
        Vector rowColVector = getRowColVector(row, column);
	
        if (text == null)
            text = ""; 
        _cellTooltipHashtable.put(rowColVector, text);
    }


    public String getCellTooltip(int row, int column)
    {
        Vector rowColVector = getRowColVector(row, column);
        return (String) _cellTooltipHashtable.get(rowColVector);
    }

    private Vector getRowColVector(int row, int column)
    {
        Vector rowColVector = new Vector();
        rowColVector.addElement(new Integer(row));
        rowColVector.addElement(new Integer(column));
        return rowColVector;
    }


    public void setEventTypeLookupColumn(int column)
    {
        _eventTypeLookupColumn = column;
    }
}
