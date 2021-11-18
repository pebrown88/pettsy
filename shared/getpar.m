function [p, ip] = getpar(name, parn, par)

% function [p, ip] = getpar(name, parn, par)
% 
% find parameter value in par array by given name
%
% p - parameter value
% ip - index of parameter in parameter arrays par
% name - parameter name
% parn - array  with parameter names
% par - array with parameter values

for i=1:length(parn)
    if strcmp(parn(i), name)        
        p = par(i);
        ip = i;
        return;
    end
end
ip = -1;
p = 0;
%error(['parameter ', name, 'was not found in par file']);