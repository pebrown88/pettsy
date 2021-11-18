function xmlStr = fixXMLString(input)


%escapes any characters not allowed in XML string type, that is name
%attribute in SBML

xmlStr = input;
if ~isempty(input) && ~isnumeric(input)
    xmlStr=strrep(xmlStr, '&', '&amp;');
    xmlStr=strrep(xmlStr, '''', '&apos;');
    xmlStr=strrep(xmlStr, '"', '&quot;');
    xmlStr=strrep(xmlStr, '<', '&lt;'); %< inside tag causes validation to fail at sbml.org
    xmlStr=strrep(xmlStr, '>', '&gt;');
end

