class SASSyTreeNodeRenderer extends DefaultTreeCellRenderer {
    
	Icon myDefaultIcon;
	Icon myCharIcon;
	Icon myStructIcon;
	Icon myCellIcon;
	Icon myFuncIcon;
	

    	public SASSyTreeNodeRenderer(Icon defaultIcon, Icon charIcon, Icon structIcon, Icon cellIcon, Icon funcIcon) {
        	
		myDefaultIcon = defaultIcon;
		myCharIcon = charIcon;
		myStructIcon = structIcon;
		myCellIcon = cellIcon;
		myFuncIcon = funcIcon;	

    	}


    	public Component getTreeCellRendererComponent(
                        JTree tree,
                        Object value,
                        boolean sel,
                        boolean expanded,
                        boolean leaf,
                        int row,
                        boolean hasFocus) {

		Icon nodeIcon = myDefaultIcon;	//numeric types

        	super.getTreeCellRendererComponent(tree, value, sel,expanded, leaf, row,hasFocus);

		DefaultMutableTreeNode node = (DefaultMutableTreeNode)value;
		String nodeText = node.toString();

      
        	if (nodeText.indexOf("character") >= 0) {
            		nodeIcon = myCharIcon;
        	}else if (nodeText.indexOf("structure") >= 0){
			nodeIcon = myStructIcon;
		}else if (nodeText.indexOf("cell") >= 0){
			nodeIcon = myCellIcon;
		}else if (nodeText.indexOf("function") >= 0){
			nodeIcon = myFuncIcon;
		}


         	setIcon(nodeIcon);
        	return this;
    	}

}