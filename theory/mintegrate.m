function [fsols rsols tb] = mintegrate(lc,m, tspan, A, numblocks, varargin)

% [fsols rsols tb] = mintegrate(m, tspan, A) with tspan = [t0 tfinal] and t0 < tfinal
% 
% Integrates a square matrix Y of size m-by-m over the range tspan. A is a handle
% to a function that takes a time value as an input and returns an m-by-m matrix.
%
% tspan is divided into numblocks equal blocks, with the times at the start of each being
% tb(i), where i = 1 to numblocks. fsols(i) contains the solution to the
% equation dY/dt= A(t)*Y with Y(t(i-1)) = I, the identity matrix so that
% Y(t) = X(t(i-1),t). rsols(i) contains the solution to the
% equation dY*/ds= (A(s)*)*(Y*) with Y(t(i)) = I so that Y(s) = X(s,t(i)).
%
% [fsols rsols tb] = mintegrate(m, tspan, A, At) is as above, except that At is
% an n-by-1 vector of time values, and A is an n-by-m-by-m matrix representing
% the corresponding values of A. The values required at the integration
% points are found by interpolation. The values in At must cover the range
% tspan.
%
% [fsols rsols tb] = mintegrate(m, tspan, A, [], solver) or 
% [fsols rsols tb] = mintegrate(m, tspan, A, At, solver), where solver is a
% character array representing any of the built in ODE solvers, uses solver
% to perform the integration. By default the solver used is ode15s.
%
% [fsols rsols tb] = mintegrate(....., solver, options) where options is a
% structure returned by ODESET, is as above with default integration
% properties replaced by values in options. If solver is not defined, []
% must be used as a placeholder.
%
% Example
%   [fsols rsols tb] = mintegrate(lc,dim,tspan,sysjac,numTimeIntervals, opt);
%   solves for the time series in lc.odesol over the time range tspan,
%   using the default solver, with properties defined in opt. A is defined by
%   sysjac. Using numTimeIntervals time blocks.


% in this routine the global structure lc is used: it has the fields
% odesol which contains the periodic orbit being analysed, p the
% parameters, CP the preiod of the orbit, force the name of the forcing
% being used and name which is the name of the system

global time_series CP ModelForce PAR_ENV 

%%Set defaults for missing parameters
At=[];
%solver = str2func('ode15s');
opts = []; 
opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-8); % was 1e-4 and 1e-6 %was 1e-5 and 1e-8
t0 = lc.odesol.x(1);
t1 = lc.odesol.x(end);
time_series = lc;

varflag = 0;
nnargin=length(varargin);
if nnargin>1
    for k=1:nnargin
        if (mod(k,2)==1)
            if strcmp(varargin{k},'Atdefined')
                At = varargin{k+1};
                varflag=varflag+1;
            end
            if strcmp(varargin{k},'solver')
                solver = varargin{k+1};
                varflag=varflag+1;
            end
            if strcmp(varargin{k},'opts')
                opts = varargin{k+1};
                varflag=varflag+1;
            end
            if strcmp(varargin{k},'odesol')
                odesol = varargin{k+1};
                varflag=varflag+1;
                t0=odesol.x(1);t1=odesol.x(end);
                tspan=odesol.x;
            end
        end
    end
end

%% Validate the inputs other than A

if ~isinteger(int32(m)) || m <= 0 
    error('The matrix dimension must be a positive integer: [fsols rsols tb] = mintegrate(m, tspan, A)');
elseif ~isscalar(m)
    error('The matrix dimension must be a scalar value: [fsols rsols tb] = mintegrate(m, tspan, A)');
end

% if numel(tspan) ~= 2 || ~isnumeric(tspan)
%     error('tspan must be a two element numeric vector: [T1 Y1 T2 Y2] = mintegrate(m, tspan, A)');
% elseif tspan(1) >= tspan(2)
%     error('Time tspan(1) must fall before time tspan(2): [T1 Y1 T2 Y2] = mintegrate(m, tspan, A)');
% end

if mod(nnargin,2)~=0
    error('Odd number of varargins');
end
if varflag>0
    if nnargin~=2*varflag
        error('Unknown varargin is used');
    end
end

if nargout < 3
    error('Not enough output arguments:  [fsols rsols tb] = mintegrate(m, tspan, A, ...)'); 
elseif nargout > 3
    error('Too many output arguments:  [fsols rsols tb] = mintegrate(m, tspan, A, ...)'); 
end





%Validate A

[v msg] = validate_function(A, At, m, tspan);
if ~v
    error(['Parameter A is not valid: [fsols rsols tb] = mintegrate(m, tspan, A). ' msg]);
end


%% Begin Integration

%solver = str2func('ode45');
% numblocks = 20; % the number of blocks [t_(i-1), t_i], t goes from tb(1) to tb(numblocks+1)
% numintervals = 10; % each block is divided into numinterval intervals
blocklength = (t1-t0)/numblocks; % time span of each block
% h = blocklength/numintervals;
% nt = numblocks * numintervals + 1; %Total timepoints

%get all the ti s
tb = [t0:blocklength:t1];

% Y1 = zeros(nt, m, m);
% T1 = zeros(nt, 1);
% 
% Y2 = zeros(nt, m, m);
% T2 = zeros(nt, 1);

%Forward integration
ltb = length(tb);
fsols(ltb-1) = struct('solver', solver, 'extdata', [], 'x', [], 'y', [], 'stats', [], 'idata', []);

mineig=1;
vb=eye(m);
incBar = floor(ltb/3);

if ~isempty(PAR_ENV)
    display_message('', 1);
    model_odesol = time_series.odesol; %need to avoid global inside loop
    model_par =  time_series.par;
    model_force = ModelForce;
    cper = CP;
    parfor i = 2:ltb
        %tspan = [tb(i-1) tb(i)];
        im = eye(m);
        %linearise Identity by stacking cols into one col
        Y0 = im(:);
        
        sol = feval(str2func(solver), @fint, [tb(i-1) tb(i)], Y0, opts, {m, A, At, model_odesol, model_par, model_force, cper});
        fsols(i-1) = sol;
        vb=zeros(m);%need to initialise its size
        vb(:)=sol.y(:,end);
        mineig = min(mineig,min(real(eig(vb))));
           
        % fprintf('the minimum eigenvalue if fsols(%d ) is %f\n',i-1,min(real(eig(vb))));
    end
else
    for i = 2:ltb
        %tspan = [tb(i-1) tb(i)];
        im = eye(m);
        %linearise Identity by stacking cols into one col
        Y0 = im(:);
        sol = feval(str2func(solver), @fint, [tb(i-1) tb(i)], Y0, opts, {m, A, At, time_series.odesol, time_series.par, ModelForce, CP});
        fsols(i-1) = sol;
        vb(:)=sol.y(:,end);
        mineig = min(mineig,min(real(eig(vb))));
        % fprintf('the minimum eigenvalue if fsols(%d ) is %f\n',i-1,min(real(eig(vb))));
        if i == incBar
            % 3 progress bar increments duing this loop
            display_message('', 1);
            incBar = incBar + floor(ltb/3);
        end
    end
end
str = sprintf('        the minimum forward eigenvalue is %f',mineig);
display_message(str, 1);
%repeat for reverse integration

mineig=1;
rsols(ltb-1) = struct('solver', solver, 'extdata', [], 'x', [], 'y', [], 'stats', [], 'idata', []);
incBar = floor(ltb/3);
if ~isempty(PAR_ENV)
    display_message('', 1);
    model_odesol = time_series.odesol; %need to avoid global inside loop
    model_par =  time_series.par;
    model_force = ModelForce;
    cper = CP;
    parfor i = 2:ltb
        u = [0 tb(i)-tb(i-1)];
        im = eye(m);
        %linearise Identity
        Y0 = im(:);
        sol = feval(str2func(solver), @bint2, u, Y0, opts, {m, A, At, tb(i),  model_odesol, model_par, model_force, cper});
        % this now solves the transposed equation dY/dt = A*Y for
        % Y(u)=X(t-u,t)
        for j = 1:length(sol.x)
            Ytmp = zeros(m,m);
            Ytmp(:) = sol.y(:,j);
            Ytmp = Ytmp';
            sol.y(:,j) = Ytmp(:);
        end
        % now reverse the order
        sol.x=tb(i)-sol.x;
        sol.x=fliplr(sol.x);
        sol.y=fliplr(sol.y);
        
        rsols(i-1) = sol;
        vb=zeros(m);%need to initialise its size
        vb(:)=sol.y(:,1);
        mineig=min(mineig,min(real(eig(vb))));
       
    end
else
    for i = 2:ltb
        u = [0 tb(i)-tb(i-1)];
        im = eye(m);
        %linearise Identity
        Y0 = im(:);
        sol = feval(str2func(solver), @bint2, u, Y0, opts, {m, A, At, tb(i), time_series.odesol, time_series.par, ModelForce, CP});
        % this now solves the transposed equation dY/dt = A*Y for Y(u)=X(t-u,t)*
        xx = sol.y;
        for j = 1:length(sol.x)
            Ytmp = zeros(m,m);
            Ytmp(:) = sol.y(:,j);
            Ytmp = Ytmp';
            sol.y(:,j) = Ytmp(:);
        end
        % now reverse the order
        sol.x=tb(i)-sol.x;
        sol.x=fliplr(sol.x);  
        sol.y=fliplr(sol.y);
 
        rsols(i-1) = sol;
        vb(:)=sol.y(:,1);
        mineig=min(mineig,min(real(eig(vb))));
        if i == incBar
            % 3 progress bar increments duing this loop
            display_message('', 1);
            incBar = incBar + floor(ltb/3);
        end
    end
end
str=sprintf('        the minimum backward eigenvalue is %f',mineig);
display_message(str);
return
       



%==========================================================================

function [v msg] = validate_function(A, At, dim, tspan)

% This function validates the function A against the requirements described
% at the top of the fle
% tspan is a 2 element vector, and dim is the size of the matrix required

global time_series CP ModelForce

v = false;
msg = [];

if isa(A, 'function_handle')
    if ~isempty(At)
       msg = 'A appears to be a functional handle. Parameter At is not required.';
    else
        %check it returns a matrix of the correct size
        %a = feval(A, tspan(1));
        a = feval(A, time_series.odesol.x(1), time_series.odesol.y(:,1), time_series.par, ModelForce,CP);
        if ~isequal(size(a),[dim dim])
            msg = 'The function must return a square matrix of size m';
        end
    end
elseif isnumeric(A) && length(size(A)) == 3
    if size(A,2) ~= dim || size(A, 3) ~= dim
       msg = 'The second and third dimensions of A must match m';
    end
    %Validate At
    if isempty(At)
       msg = 'Parameter At is missing'; 
    end
    if isnumeric(At) && length(size(At)) == 2
        if size(At, 1) ~= size(A, 1) || size(At, 2) ~= 1
            msg = 'Parameter At must be a column vector with the same number of elements as the first dimension of matix A';
        elseif At(1) > tspan(1) || At(end) < tspan(2)
            msg = 'The time values in At do not cover the required range in tspan';
        elseif ~issorted(At)
            msg = 'The time values in vector At must be monotonically increasing';         
        end  
    end   
else
    msg = 'A must be either a function handle or an n-by-m-by-m matrix';
end
v = isempty(msg);


