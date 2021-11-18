function varargout = runCVode(modelname, trange, y0, varargin)

%PEB Jan 2016. A wrapper to CVode solver sos they can be called using the
%same syntax as Matlab solvers

%Matlab solver would be called like this
%solver(modelname, [t0 tend], y0, odeopts,par, ModelForce, CP)

%This function can be called the same way
%solver(modelname, [t0 tend], y0, odeopts,par, ModelForce, CP)

%userdata = {par, ModelForce, CP}

if nargout == 0 || nargout > 5
    
    error('You must specify one to five output arguments.')
    
end

if nargin < 3 || nargin > 5
   
    error('runCVode(system, t, y, [options], [userdata])');
    
end

global stiff_problem 

%convert options to cvode format, which must contain  par, ModelForce, CP
%and tend

if stiff_problem
    lmm = 'BDF';
    nls = 'Newton';
else
    lmm = 'Adams';
    nls = 'Functional';
end

t0 = trange(1);
tend = trange(end);

%at the moment, if trange has > 2 values, rest are ignored. This only
%happens in getdgs()

odeopts = [];
userdata = [];
hasEvents = false;

if nargin >= 4
   
    if isa(varargin{1}, 'struct')
        
        odeopts = varargin{1};
        
        if nargin == 5 && isa(varargin{2}, 'cell')
           
            userdata = varargin{2};
            
        end
        
    elseif isa(varargin{1}, 'cell')
        
        userdata = varargin{1};
        
    end
    
end


cv_opts = CVodeSetOptions( ...
        'StopTime', tend, ...
        'LMM', lmm, ...
        'NonLinearSolver', nls);


if ~isempty(odeopts)
    
    %doesn't support Matlab opts  NormControl, NonNegative, OutputFcn,
    %OutputSel, Refine, Stats, BDF, Jacobian, JPattern, Vectorized, Mass, 
    %MStateDependence, MvPattern, MassSingular, InitialSlope
    
    cv_opts = CVodeSetOptions(cv_opts, 'AbsTol', odeopts.AbsTol, ...
        'RelTol', odeopts.RelTol, ...
        'InitialStep', odeopts.InitialStep, ...
        'MaxStep', odeopts.MaxStep, ...
        'MaxOrder', odeopts.MaxOrder, ...
        'RootsFn', odeopts.Events);
    
    if isempty(odeopts.Events)
        %disable event firing
        cv_opts = CVodeSetOptions(cv_opts, 'NumRoots', 0);
    else
        cv_opts = CVodeSetOptions(cv_opts, 'NumRoots', 1); %only interested in one variable
        hasEvents = true;
    end
    
end
    
if ~isempty(userdata)
   
     cv_opts = CVodeSetOptions(cv_opts, 'Userdata', userdata);
    
end



%intialise
y0=y0(:); %must be column to allocate memory properly
CVodeInit(modelname, lmm, nls, t0, y0, cv_opts);
    
%solver over required t

ysol = y0';
tsol = t0;
te = [];
ye = [];
ei = []; %not supported yet

i = 2;

t = t0;
while t < tend
   
    %tout just used to determine direction
    [status,t,y] = CVode(tend,'OneStep');
    
    ysol(i, :) = y';
    tsol(i,1) = t;
    
	if (status == 2)
		%found event. 
        te = [te; t];
        ye = [ye y];
		break;
    end
    i = i+1;

end

CVodeFree();


%format outputs required. Could be

%simple solution
%[t, y] = odesolver(...)

%for events
%[t, y, te, ye, ei] = odesolver(...)
%te is a col vector of event times, rows of ye are corresponding y values,
%and ei is a col vector showing index of which y fired event

%structure
%sol = osesolver(...)
%sol.x is timepoints 
%sol.y columns ore y values at each timepoint
%if events, sol.xe is a row vectot of event times, sol.ye ar ecorresponding
% y values and sol.ie are indices of y that caused event.


if nargout == 1
    
    %structure required
    %struct('solver', solver, 'extdata', [], 'x', [], 'y', [], 'stats', [], 'idata', []);
    
    sol.solver = 'cvode';
    sol.extdata.varargin{1} = userdata;
    
    
    sol.x = tsol(:)';
    sol.y = ysol';
    
    sol.stats = [];%required but not used
    sol.idata = [];
    
    %events
    if hasEvents
        
       sol.xe = te';
       sol.ye = ye;
       sol.ie = ei';      
    end
   
    varargout(1) = {sol};
    
else
    
    varargout(1) = {tsol};
    varargout(2) = {ysol};
    
    if nargout > 2
        
          varargout{3} = te;
        
        if nargout > 3
          
            varargout{4} = ye;
            
            if nargout > 4
                
                varargout{5} = ei;
                
            end
            
        end
        
    end
       
end
    


    

%files that are integrated

%modelname                  *
%integrate_d_traj_dk        *
%integrate_d_traj_dk_par    *
%fint                       *
%bint2                      *
%integra                    *
%integra2                   *


%files listing/naming solvers

%newcyclegui        *
%limitcycle         *
%signal             *
%make               *
%sbml/ShowSavePanel
%mintegrate         *
%newXst_deltat      *
%calc_int2t         *

%files using 'method'

%find_oscillator_cylce  *
%find_signal_solution   *
%getcycle               *
%getmaximum             *
%getminimum             *
%signal                 *
%limitcycle             *
%getdgs line 32         *



%event functions

%findpeakevent      *
%getmaximum/ifmin   *
%getminimum/ifmin   *










                           
                           




