function results = signal(model, varargin)

% input arguments----------------------------------------------
% model, structure representing the model. See getlistofmodels for the
% details of the structure
% then the following optional arguments

%These arguments consist of property name / value pairs

%Name           Value

%'param'        parameters vector
%'ic'           inital conditions vector
%'solver'       name of ode solver to use. Default is 'ode45'
%'env'          Zero or non-zero. Indicates wherther the external force is
%               on or off. Default is off
%'opts'         an ode options structure generated by odeset()
%'plot'         {'off | 'on'} plot the limit cycle. Default is 'off'
%'gui'          function that is evaluated in response to this function
%               progresing, eg 'theorygui'
%'force_type'   Array of structure with fields 'type', 'dawn and 'dusk',one
%               for each model force.
%'tend'         The length of time to run the simulation, defsult = 100 time units

%the results structure has the following fields

% name          character array. model name
% odesol        The solution returned by the ode solver
% sol           the solution with equally spaced timepoints
% troughs       cell array where troughs{i} is a row vector of trough times for variable i
% peaks         cell array where peaks{i} is a row vector of peak times for variable i
% par           model parameter values used to produce solution 
% parn          cell array of parameter names
% parnames      cell array of parameter decriptions
% vnames        cell array of the model variable names
% date          character array. date lc was produced
% solver        character array. The name of the solver used to produce the limit cycle.
%               theory will use the same one
% plotting_timescale This is scaling factor for time i.e. if computation
%               is in mins and the plot in hours then plotting_timescale =
%               60: tnew = t/plotting_timescale
% tend          the length of the simluation
% orbit_type    set to 'signal'
% varnum        an empty field. For compatability with gui files 
% force         column vector of time series of force values
% forced        whether or not the limit cycle has a non-constant external force
% forcename     input parameter force_type

% DAR change
global method numTimepoints  plt gui ModelForce CP stiff_problem solver

%% ===============================================
% function setup
% ================================================

method = {'matlab' false};
forced = 0;

par = [];
var = [];

numTimepoints = 201;
odeopts = [];
plt= 'off';
gui = [];   
force_type = [];
tend = 100;

if mod(length(varargin),2)
   disp('Syntax error on command line. Enter Name Value pairs'); 
   return;
end
for i=1:2:length(varargin)-1;
    switch varargin{i}
        case {'param'}   % parameters are given
            par = varargin{i+1};
        case('solver')    % stiff integration
            method = varargin{i+1};
        case('ic')
            var = varargin{i+1};
        case ('env')
            forced =  varargin{i+1};
        case('opts')
            odeopts = varargin{i+1};
        case ('plot')
            plt = varargin{i+1};
        case ('gui')
            gui = varargin{i+1};
        case ('force_type')
            force_type = varargin{i+1}; 
        case ('tend')
            tend = varargin{i+1};
        otherwise
            disp('unknown property in the command line');
            return;
    end
end

ModelForce = force_type;
CP = tend;

stiff_problem = method{2};

if strcmp(method{1}, 'matlab')
   
    if stiff_problem
        solver = 'ode15s';
    else
        solver = 'ode45';
    end
    
else
    
    solver = 'runCVode';
    
end


disp('Initialising...');
if ~isempty(gui)
    feval(gui,'write', 'Initialising...');
end

fprintf('\nRunning using solver %s\n',solver);

%initialise results structure
results.troughs = [];
results.peaks = [];
results.force = [];
results.par = [];
results.parn = [];
results.parnames = [];
results.sol = [];
results.sol.x = [];
results.sol.y = [];
results.odesol =[];
results.dim = [];
results.vnames = [];
results.solver = {solver method{2}};
results.name = model.name;
results.date = date;
results.forced = forced;
results.plotting_timescale = model.plotting_timescale; 
results.forceparams = force_type;

%% ===============================================
% reading parameters from input files 
% ================================================


% ===============================================
% reading system parameters
% ================================================

if ~(model.plotting_timescale == 1)
    str = sprintf('timescale scaled by 1/%f',model.plotting_timescale);
    disp(str);
    if ~isempty(gui)
        feval(gui,'write', str);
    end
end
dim = model.vnum;

if ~forced
    disp('System is unforced');
    if ~isempty(gui)
        feval(gui,'write', 'System is unforced');
    end
else
    str = 'System is forced';
    disp(str);
    if ~isempty(gui)
        feval(gui,'write', str);
    end
end

% ===============================================
% setting initial condition - DAR
% ================================================
y0 = var;
t0 = 0;

% ===============================================
% setting integration tolerances
% ================================================

if forced 
    tol = 1e-9;
else
    tol = 1e-7;
end

% ===============================================
% setting timestep h - moved and changes by DAR
% ================================================
h = tend / (numTimepoints-1);


% ===============================================
% dealing with odeopts
% ================================================

if ~isempty(odeopts)
    reltol = odeget(odeopts, 'reltol');
    abstol = odeget(odeopts, 'abstol');
    odeopts = odeset(odeopts, 'reltol', min([reltol tol]), 'abstol', min([abstol tol]), 'MaxStep', h);
else
    odeopts = odeset('reltol' ,tol, 'abstol', tol, 'MaxStep', h);
end

% ===============================================
% dealing with inclusion of positivity or not in odeopts - DAR
% ================================================
str100='';
if strcmp(method{1}, 'matlab')
    if strcmp(model.positivity,'non-negative')
        odeopts = odeset(odeopts, 'NonNegative', 1:dim);
        str100=sprintf('%s','Solutions are assumed to be non-negative');
    else
        str100=sprintf('%s','Solutions are not assumed to be non-negative');
    end;
end

disp('Locating signal...');
if ~isempty(gui)
    feval(gui,'write', 'Locating signal...');
end

disp(str100);
if ~isempty(gui)
    feval(gui,'progress', str100);
end

% ===============================================
% find the required orbit - DAR
% ================================================
results=find_signal_solution(model, t0, tend,y0, par, results, odeopts);

% ===============================================
% plot the resulting orbit
% ================================================

if ~isempty(gui)
    feval(gui,'progress', 'Completed successfully');
end

%%
if strcmp(plt, 'on') 
   plot(results.sol.x/model.plotting_timescale, [results.sol.y results.force]);
   xlim([results.sol.x(1)/model.plotting_timescale results.sol.x(end)/model.plotting_timescale]);
   ys = get(gca, 'YLim');
   ylim([min(min(results.force), 0) ys(2)]);
   hl = legend([results.vnames; 'force']);
   set(hl,'Location', 'Best');
   xlabel('Time (h)');
   ylabel('y');
end
%mak estart time zero!!!!!!!!!!
gui = [];
return;


