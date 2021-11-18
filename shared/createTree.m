%create java based tree control

function varargout = createTree(action, varargin)

persistent dataTree;

if strcmp(action, 'init')
    
    % panel - uipanel to act as control container
    % pos - position, in pixels
    % timeSeriesData - structure to display the fields of
    % showDescriptions - non-zero means show descriptions next to field name
    % showSizes - non-zero means show dimensions next to field name
    
    global showDescriptions showSizes
    
    panel = varargin{1};
    pos = varargin{2};
    timeSeriesData = varargin{3};
    showDescriptions = varargin{4};
    showSizes = varargin{5};
    
    dataTree = [];
    
    %uses Matalb's built in java classes
    import javax.swing.tree.*;
    import javax.swing.*;
    import com.jidesoft.swing.CheckBoxTree.*
    
    if isfield(timeSeriesData, 'myfile')
        [~, rootName] = fileparts(timeSeriesData.myfile);
    else
        rootName = 'All';
    end
    % define a simple tree
    rootNode = javaObjectEDT(DefaultMutableTreeNode( ['<html><b>' rootName '</b></html>'])); %java.swing.tree.DefaultMutableTreeNode
    
    %root of tree is name of results structure. Now add fields recursively
    %fill in data fields
    rootNode = addNode(rootNode, timeSeriesData, '');
    
    % define tree model
    treeModel = javaObjectEDT(DefaultTreeModel( rootNode ));   %java.swing.tree.DefaultTreeModel
    % create checkbox tree
    dataTree = javaObjectEDT(com.jidesoft.swing.CheckBoxTree( treeModel ));    %com.jidesoft.swing.CheckBoxTree, from java.swing.JTree
    dataTree.setShowsRootHandles(true);
    
 
    
    % icons for nodes
     my_dir = fileparts(mfilename('fullpath'));
     default_icon = ImageIcon(fullfile(my_dir, 'resources', 'defaultTreeNodeIcon.gif'));
     char_icon = ImageIcon(fullfile(my_dir, 'resources', 'charTreeNodeIcon.gif'));
     struct_icon = ImageIcon(fullfile(my_dir, 'resources','structTreeNodeIcon.gif'));
     cell_icon = ImageIcon(fullfile(my_dir, 'resources', 'cellTreeNodeIcon.gif'));
     func_icon = ImageIcon(fullfile(my_dir, 'resources', 'funcTreeNodeIcon.gif'));
     cr = SASSyTreeNodeRenderer(default_icon, char_icon, struct_icon, cell_icon, func_icon);
     dataTree.setCellRenderer(cr);
    
    % place tree on figure
    
    jScrollPane = com.mathworks.mwswing.MJScrollPane(dataTree);
    [jComp,hc ] = javacomponent(jScrollPane,pos,panel);
    
    % define tree selection model
    treeSelectionModel = dataTree.getCheckBoxTreeSelectionModel();  %com.jidesoft.swing.CheckBoxTreeSelectionModel
    treeSelectionModel.setDigIn(true);
    %ensures checking box will automatically check all children
    %and that treeSelectionModel.getSelectionPaths() just returns path to
    %parent when all its children are selected
    
    %return reference to tree
    varargout{1} = dataTree;
    
elseif strcmp(action, 'get_selected')
    
    %retrieve selected nodes
    
    treeSelectionModel = dataTree.getCheckBoxTreeSelectionModel();  %com.jidesoft.swing.CheckBoxTreeSelectionModel
    selectedNodes=treeSelectionModel.getSelectionPaths();   %java.swing.TreePath[]
    selectedPaths = cell(length(selectedNodes), 1);
    
    for s = 1:length(selectedNodes)
        node = selectedNodes(s);    %java.swing.TreePath
        nodepath = node.getPath(); %an array of java.swing.tree.DefaultMutableTreeNode
        %create struct field name from java objects
        fieldPath = '';
        for c = 2:length(nodepath)  %ignore first path component as this is parent structure 
           fieldname = char(nodepath(c).toString());
           %extract name via regex
           fieldname = regexp(fieldname, '<b>\s*(\w+)\s*</b>', 'once', 'tokens');
           fieldPath = [fieldPath '.' fieldname{1}];
           selectedPaths{s} = fieldPath;
        end
       
    end
    
    varargout{1} = selectedPaths;
    
elseif strcmp(action, 'clear')
    
    clear dataTree;
    
end

%==========================================================================

function str = getFieldDescription(name)

persistent fieldDescriptions;

if isempty(fieldDescriptions)
    fieldDescriptions = {};
    mydir = fileparts(mfilename('fullpath'));
    fname = fullfile(mydir, 'field_desc.txt');
    fid = fopen(fname);
    if fid > 0
        fieldDescriptions = textscan(fid, '%s %s', 'Delimiter', '\t', 'MultipleDelimsAsOne', 1);
        fclose(fid);
    end
end

str =  '';
for f = 1:length(fieldDescriptions{1})
    if strcmp(fieldDescriptions{1}{f}, name)
        str = fieldDescriptions{2}{f};
        return;
    end
end



%==========================================================================
function node = addNode(rootNode, timeSeriesData, parentPath)

%adds nodes to rootNode and returns the node
%timeSeriesData is a structure whose fields will be child nodes

global showDescriptions showSizes

import javax.swing.tree.*;
import javax.swing.*;

types = {'logical', 'char', 'numeric', 'cell', 'struct', 'function_handle'}; %posible data types

datanames = fieldnames(timeSeriesData);

for i = 1:length(datanames)
    isStruct = false;
    fieldName = datanames{i};
    field = getfield(timeSeriesData, fieldName);
    
    if showSizes
        %get type
        fieldType = '';
        for t = 1:length(types)
            if isa(field, types{t})
                fieldType = types{t};
                break;
            end
        end
        fieldSize = size(field);
        fieldSizeStr = printFieldSize(size(field));
        if strcmp(fieldType, 'cell')
            if max(fieldSize) == 1
                fieldType = ['{' field(1) '}'];
            else
                fieldType = ['{' fieldSizeStr ' cell array}'];
            end
        elseif strcmp(fieldType, 'struct')
            fieldType = ['[' fieldSizeStr ' struct array]'];
            isStruct = true;
        elseif strcmp(fieldType, 'char')
            if max(fieldSize) == 1
                if length(field) <= 35
                    fieldType = strcat('''', field, ''''); %print string
                else
                    fieldType = strcat('''', field(1:20), '...', field(length(field)-10:end), '''');
                end
            else
                fieldType = ['[' fieldSizeStr ' character array]'];
            end
        elseif strcmp(fieldType, 'function_handle')
            fieldType = '@function_handle';
            field = char(field); %prevent call to function when passed as param to addNode
        else
            %numeric
            if max(fieldSize) == 1
                fieldType = ['['  num2str(field(1)) ']']; %scalar so print value
            else
                fieldType = ['[' fieldSizeStr ' numeric array]'];
            end
            
        end
        fieldType = ['<b>:</b> ' fieldType];
    else
        fieldType = '';
    end
    
    %add to tree
    pathToNode = fieldName;
    if ~strcmp(parentPath, '')
        pathToNode = [parentPath '.' pathToNode];
    end
    if showDescriptions
        desc = ['<i>' getFieldDescription(pathToNode) '</i>' ];
    else
        desc = '';
    end
    newNode =  javaObjectEDT(DefaultMutableTreeNode( ['<html><b>' fieldName '</b>' fieldType ' ' desc '</html>'] ));

    if isStruct
        %recursively add its fields
       % newNode = uitreenode('v0', node_text, node_text, [], 0);
        newNode = addNode(newNode, field, pathToNode);
    %else
        % a leaf node with no children
        %newNode = uitreenode('v0', node_text, node_text, [], 1);
    end
    
    %set node's icon
    %types = {'logical', 'char', 'numeric', 'cell', 'struct', 'function_handle'}

    rootNode.add( newNode );

end

node = rootNode;
  
%==========================================================================

function fs = printFieldSize(fieldSize)

fs = '';
for i = 1:length(fieldSize)
    fs = [fs num2str(fieldSize(i))];
    if i < length(fieldSize)
        fs = [fs 'x'];
    end
end
