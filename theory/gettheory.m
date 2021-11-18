function [results] = gettheory(lc, options)

tic
% function [results] = gettheory(name, list of optional parameters...)

% input arguments----------------------------------------------

% the input structure 'lc' described the limit cycle to be analysed and has the following fields

% name          character array. model name
% odesol        the solution found by the ode solver
% sol           the solution with equally spaced
%               timepoints
% dim           the number of model variables
% force         matrix of time series of force values, forces in cols
% env           the force type or 'off'
% per           period of limit cycle
% troughs       row vector of variable trough times
% peaks         row vector of variable peak times
% par           model parameter values used to produce limit cycle 
% parn          cell array of parameter names
% parnames      cell array of parameter decriptions
% vnames        cell array of the model variable names
% date          character array. date lc was produced
% solver        character array. The name of the solver used to produce the limit cycle.
%               theory will use the same one
% orbit_type    'signal' or oscillator'
% forced        zero if force is constant, non-zero if not
% orbit_type    'oscillator' or 'signal'
% forceparams    array of structures withe fields 'name', 'dawn', 'dusk'


% options is a cell array. An element which is a function handle is
% interpreted as the function that is evaluated in response to this function
% progressing, eg 'newtheorygui'. Used to display progress.

% The value 'allow_reject_Xst causes the condition numbers of Xst matrices to be 
% plotted and allows the user to reject them and recalculate with smaller time windows 

%Other elements indicate the outputs required. Valid values are

% For oscillators

% 'yp'          yp matrix
% 'dy0dpar'     dy0dpar
% 'dxdm'        dxdm
% 'irc'         ircs for unforced (requires dxdm), phase ircs for forced

% for unforced oscillators

% 'dperdpar'    dperdpar

% For all models

% 'dgs'         periodic_dgs nonper_dgs
% 'dphasedpar'  dtrdpar, dpkdpar (require dgs)
% 'dypkdpar'    dytr, dypk (require dgs)

%Output arguments------------------------------

% This function returns a structure with the following fields

%Oscillators only

%irc           	the infinitesimal response curves matrix, the curves under the integral for 
%               dy0/dpar (unforced model). One column for each parameter and one row for each time in t
%dxdm          	3-d matrix of the curves under the integral for dy0/dpar (forced model). 
%               The dimensions are time, variable, parameter.
%dperdpar      	column vector of period derivatives with respect to each parameter
%dy0dpar       	matrix of dy0/dpar first derivatives in standard coordinate system, 
%               One column for each variable and one row for each parameter
%yp            	Y(p) matrix, fundamential matrix of equations for variations at
%              	t=period. A square matrix whose size is the number of model
%              	variables

%Forced oscillators only

%ircphi         phase ircs. A 2D cell array. Firs dimension is variable,
%               second is peak number, ie ircphi{m}{n} is the phase irc of the nth peak
%               (chronologically) of the mth model variable. This is a
%               structure with fields as follows
%                   data    the phase irc, one column for each parameter
%                           and one row for each timepoint
%                   bs
%                   integrals   vector of integrals for each parameter
%                   maxAdvances/Delays  vectors of larger phase advance/delay for each parameter
%
%               In additon, each variable with more than one peak will have
%               an additonal structure at ircphi{m}{end}, which contains
%               the maximum advance/delay and total integral for all peaks
%               for the mth variable

%Signal solutions and unforced oscillators only

%nonper_dgs     derivative of the solution with respect to parameter. 
%               A 3-d matrix with dimensions of time, variable, parameter.
%nonper_sds     A structure representing svd of the limit cycle
%               derivatives. It has the following fields


%Oscillators only

%periodic_dgs   derivative of the solution with respect to parameter. 
%               A 3-d matrix with dimensions of time, variable, parameter.
%periodic_sds   A structure representing svd of the limit cycle
%               derivatives. It has the following fields

%All systems

%dtrdpar       	derivative of trough times with respect to parameter. A
%               cell array with an element for each variable. Each element 
%               is a par * trough num matrix with troughs ordered
%               chronologically. 
%dpkdpar        as above, for peaks
%dytr          	variable derivatives with respect to parameter at times of troughs. 
%               cell array with an element for each variable. Each element 
%               is a par * trough num matrix with troughs ordered
%               chronologically. 
%dypk          	as above for peaks
%date           character array. date results was produced
%t              time values for dgs, irc and dxdm



%Correspondence of outputs in original version to fields of results is as
%follows:

%[t,y,ipr,i,yp,dgs,dphi,dm,phi]=theory(modelname, ...);
%ipr (unforced) results.irc
%ipr (forced)   results.dxdm
%i (unforced)   [results.dperdpar results.dy0dpar]
%i (forced)     results.dy0dpar
%yp             results.yp
%dgs            results.periodic_dgs
%dphi           [results.dtrdpar results.dpkdpar]
%dm             [results.dytr results.dypk]

global odetol;

global max_dim;     %dimension of largest square matrix than can be linearized and integrated. Memory required is equal to max_dim ^ 4 * 8 bytes
max_dim = 50;       %about 50 Mb continuous memory block required

% integration tolerances (speed factor)
if lc.forced  % if theory_forced
    odetol = 1e-9;
else
    odetol = 1e-7;
end

global ModelForce CP

ModelForce = lc.forceparams;
if strcmp(lc.orbit_type, 'signal')
    CP = lc.tend;
else
    CP = lc.per;
end



%% ---------------------------------------------------------------------
% calculation of the derivatives of the solutions
% ---------------------------------------------------------------------
if strcmp(lc.orbit_type,'oscillator')
    results = theory_oscillator(lc, options);
elseif strcmp(lc.orbit_type,'signal')
    results = theory_signal(lc, options);
else
    str = ('Unknown orbit type');
    disp(str);
    if ~isempty(gui)
        feval(gui,'write', str);
    end 
    results = [];
    return;
end
return;
