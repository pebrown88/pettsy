function mathml = ODEToMathML(ode_str)

%PEB Nov 2015
%Functio nto convert the ode in the input string to a MathML structure
%in order ot incorporate it into an SBML document.

%ode_str has variable sin symbolic form , not y(n), CAn contain the
%following operators: + - / ^ *, constants and symbolic names


eqn_info = load('../SASSy/models/oscillator/neurospora/derivatives/neurospora_eqn_info.mat');

ode_str = eqn_info.model_odes{1};

%move all spaces to simplfy code
ode_str = strrep(ode_str, ' ', '');

%for example 
% (ki^n*(vs + amp*force))/(FRQn^n + ki^n) - (FRQm*vm)/(FRQm + km)

%find each operator

operators = stuct([]);
oppos = regexp(ode_str, '[+-/*^]');
%-x start becomes 0-x
for i = length(oppos)
   
    operators(i).type = ode_str(oppos(i));
    operators(i).position = oppos(i);
    
    %determine level of parentheses so we get the correct order to evaluate them
    %in
    open_backets = strfind(odestr(1:operators(i).position-1), '(');
    closing_brackets = strfind(odestr(1:operators(i).position-1), ')');
    operators(i).level = length(open_backets)-length(closing_brackets); 
    
    
    %precedence takes effect if a number are grouped in the same brackets
    switch operators(i).type
        
        case '^'
            operators(i).precedence = 3;
            
        case {'/', '*'}
            
            operators(i).precedence = 2;
            
        otherwise
            
            operators(i).precedence = 1;
    end
    
    
%     %find operands
%     [left_operand, start_idx] = find_left_expr(ode_str, operators(i).position);
%     [right_operand, end_idx] = find_right_expr(ode_str, operators(i).position);
%     
%     operators(i).left_operand
%     operators(i).right_operand
    
end

%put thne in blocks surrounded by a set of ()



%go through and adjust level of operators in the same set of brackets
%accoring to their precedence
i = 1;j=0;
while (i+j) < length(operators)
    
    level = operators(i).level;
    j=i+1;
    same_level = 0;
    while operators(j).level == level      
        same_level = same_level+1;
        j=j+1;
    end
    
end


 max_level = max([operators(:).level]);
 
 %convert each operator in order of precedence. If they match, left most one
 %first



%==========================================================================

function [expr, last_idx] = find_right_expr(eqn, i)

%returns the right operand and the index value in the equation string where
%it ends

i=i+1;
expr = eqn(i); %first character after operator

if expr == '('
    
    openb = 1;
    closeb = 0;
    while i <= length(eqn)
        i = i+1;
        expr = [expr eqn(i)];
        if expr(end) == '('
            openb = openb+1;
        elseif expr(end) == ')'
            closeb = closeb+1;
        end
        if openb == closeb
            last_idx = i;
            break;
        end
        
    end
    
elseif isstrprop(expr, 'digit')
    %no backets, simple literal value
    expr=regexp(eqn(i:end), '^([\d\.]+)', 'tokens');
    expr = char(expr{1});
    last_idx = i +length(expr)-1; 
elseif isstrprop(expr, 'alpha')
    %sym name
    expr=regexp(eqn(i:end), '^([a-zA-Z][a-zA-Z_\d]*)', 'tokens');
    expr = char(expr{1});
    last_idx = i +length(expr)-1;
end

%==========================================================================

function [expr, first_idx] = find_left_expr(eqn, i)

i=i-1;
expr = eqn(i);

if expr == ')'
    
    openb = 0;
    closeb = 1;
    while i > 1
        i = i-1;
        expr = [eqn(i) expr ];
        if expr(1) == '('
            openb = openb+1;
        elseif expr(1) == ')'
            closeb = closeb+1;
        end
        if openb == closeb
            first_idx = i;
            break;
        end
        
    end
    
elseif isstrprop(expr, 'digit')
    %no backets, 
    %test for variable whose name ends in a digit
    expr=regexp(eqn(1:i), '([a-zA-Z][a-zA-Z_\d]*[\d])$', 'tokens');
    if isempty(expr)
        %simple literal value
         expr=regexp(eqn(1:i), '([\d\.]+)$', 'tokens');
    end

    expr = char(expr{1});
    first_idx = i - length(expr) +1;
elseif isstrprop(expr, 'alpha')
    %sym name
    expr=regexp(eqn(1:i), '([a-zA-Z][a-zA-Z_\d]*)$', 'tokens');
    expr = char(expr{1});
    first_idx = i - length(expr) +1;
end



%Break equation into 

%becomes
%   <apply>
%       <minus/>
%             <apply>
%               <divide/>
%               <apply>
%                 <times/>
%                 <apply>
%                   <plus/>
%                   <ci> vs </ci>
%                   <apply>
%                     <times/>
%                     <ci> amp </ci>
%                     <ci> force </ci>
%                   </apply>
%                 </apply>
%                 <apply>
%                   <power/>
%                   <ci> ki </ci>
%                   <ci> n </ci>
%                 </apply>
%               </apply>
%               <apply>
%                 <plus/>
%                 <apply>
%                   <power/>
%                   <ci> ki </ci>
%                   <ci> n </ci>
%                 </apply>
%                 <apply>
%                   <power/>
%                   <ci> FRQn </ci>
%                   <ci> n </ci>
%                 </apply>
%               </apply>
%             </apply>
%             <apply>
%               <divide/>
%               <apply>
%                 <times/>
%                 <ci> vm </ci>
%                 <ci> FRQm </ci>
%               </apply>
%               <apply>
%                 <plus/>
%                 <ci> km </ci>
%                 <ci> FRQm </ci>
%               </apply>
%             </apply>
%           </apply>

