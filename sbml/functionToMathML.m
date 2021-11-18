
function [funcBodyMathML, funcCallMathML, usesParams, success, msg] = functionToMathML(eqn, force, cpname)

% PEB, Nov 2015
% Takes a simple text based function body and returns it as a MathML
% Second input 'force' is a structure with fields: name (function name),
% dawnname and duskname (potential input parameter names). cpname is another
% potential input parameter.

% funcBodyMathML is the function body, without the <math>...</math> tags
% funcCalMathML is how to call the function in an expression, something like
% <apply><ci>force.name</ci> ...
% usesParams is a structure with fields hasDawn, hasDusk and hasCP, which
% are set to non-zero if the function uses these input
% success is a flag to indicateif everything worked ok
% msg will be an error message it it didn't
                

funcCallMathML=[];
usesParams = [];
msg = '';
success = true;

[funcBodyMathML, success, msg] = ODEToMathML(eqn);
if ~success
    return;
end

%Now got function body. 
%Rename parameters as required
if ~isempty(strfind(funcBodyMathML, '<ci>dawn</ci>'))
    usesParams.hasDawn = true;
    funcBodyMathML = strrep(funcBodyMathML, '<ci>dawn</ci>', ['<ci>'  force.dawnname '</ci>']);
else
   usesParams.hasDawn = false; 
end
if ~isempty(strfind(funcBodyMathML, '<ci>dusk</ci>'))
    usesParams.hasDusk = true;
    funcBodyMathML = strrep(funcBodyMathML, '<ci>dusk</ci>', ['<ci>'  force.duskname '</ci>']);
else
   usesParams.hasDusk = false; 
end
if ~isempty(strfind(funcBodyMathML, '<ci>CP</ci>'))
    usesParams.hasCP = true;
    funcBodyMathML = strrep(funcBodyMathML, '<ci>CP</ci>', ['<ci>' cpname '</ci>']);
else
   usesParams.hasCP = false; 
end
if ~isempty(strfind(funcBodyMathML, '<ci>t</ci>'))
    usesParams.hasTime = true;
else
   usesParams.hasTime = false; 
end



%Need to add its input pars, which can be dawn, dusk,
%cp and time

inputs = [];
funcCallMathML = ['<apply>\n\t<ci>' force.name '</ci>\n'];

if usesParams.hasDawn  
    inputs = [inputs '\t<bvar><ci>' force.dawnname '</ci></bvar>\n'];
    funcCallMathML = [funcCallMathML '\t<ci>' force.dawnname '</ci>\n'];
end
if usesParams.hasDusk  
    inputs = [inputs '\t<bvar><ci>' force.duskname '</ci></bvar>\n'];
    funcCallMathML = [funcCallMathML '\t<ci>' force.duskname '</ci>\n'];
end
if usesParams.hasCP  
    inputs = [inputs '\t<bvar><ci>' cpname '</ci></bvar>\n'];
    funcCallMathML = [funcCallMathML '\t<ci>' cpname '</ci>\n'];
end
if usesParams.hasTime
    inputs = [inputs '\t<bvar><ci>t</ci></bvar>\n'];
    funcCallMathML = [funcCallMathML '\t<csymbol encoding="text" definitionURL="http://www.sbml.org/sbml/symbols/time">t</csymbol>\n'];
end

funcBodyMathML = ['<lambda>\n' inputs funcBodyMathML '</lambda>'];
funcCallMathML = [funcCallMathML '</apply>'];





   
 
 
 

