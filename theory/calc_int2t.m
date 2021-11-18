function sol = calc_int2t(lc, tinterval, dim, ts)

global syspar sysjac solver

% this function returns int_0^tX(s,t)*bs(s)ds by integrating the
% differential equation. It reurns an ode structure so that this can be
% used with deval on any grid of times.

global PAR_ENV ModelForce CP

pnum = length(lc.par);
par = lc.par;
odesol=lc.odesol;

%% set the Jacobian pattern
sysjac = str2func([lc.name,'_jac']);
syspar = str2func([lc.name,'_dp']); % for integrate_d_traj_dk
sysJpattern = str2func([lc.name,'_jac_pattern']);
jac_pat = feval(sysJpattern);
% the Jacobian for the full system is just a par x dim square matrix with
% all zeros except for par copies of the normal Jacobian down the diagonal
BJ_pat=zeros(dim*pnum);
for i=1:pnum
    BJ_pat((i-1)*dim+1:i*dim,(i-1)*dim+1:i*dim)=jac_pat;
end

%% do the integration
%options = odeset('RelTol', 1e-7, 'AbsTol', 1e-7,'Jacobian',@idtd_jac);
%options1 = odeset('RelTol', 1e-7, 'AbsTol', 1e-7,'JPattern',BJ);
%options1 = odeset('RelTol', 1e-5, 'AbsTol', 1e-7,'JPattern',BJ_pat);
Y = zeros(dim,pnum);
y11 = Y(:);

numElementsRequired = numel(y11)^2;
[gotEnough, maxSize] = gotEnoughMemory(numElementsRequired, 8);
% this is to get all the X(t)'s
if gotEnough && isempty(PAR_ENV)
    options1 = odeset('RelTol', 1e-3, 'AbsTol', 1e-3,'JPattern',BJ_pat);    %PEB changed
    sol = feval(str2func(solver), @integrate_d_traj_dk, [tinterval(1), tinterval(end)], y11, options1, {par, 1:pnum, odesol, dim});
    sol = interpsol(sol,ts);
else 
    %must integrate in blocks, either because user want to parallelise or
    %because modle is too big to do in one go
    %one column (paramerter) at a time
    
    %Won't work for Horton2. Causes ode15s to fail
    options1 = odeset('RelTol', 1e-3, 'AbsTol', 1e-3);    %PEB changed
    y11temp = cell(1,pnum);
    soltemp = cell(1,pnum);
    sol = [];
    for i = 1:pnum
        y11temp{i} = y11(dim*(i-1)+1:dim*i);
    end
    if ~isempty(PAR_ENV)
        parfor i = 1:pnum
            soltemp{i} = feval(str2func(solver), @integrate_d_traj_dk_par, [tinterval(1), tinterval(end)], y11temp{i}, options1, {par, i, odesol, dim, sysjac, syspar, ModelForce, CP});
            soltemp{i} = interpsol(soltemp{i},ts);
        end
    else
        for i = 1:pnum
            soltemp{i} = feval(str2func(solver), @integrate_d_traj_dk_par, [tinterval(1), tinterval(end)], y11temp{i}, options1, {par, i, odesol, dim, sysjac, syspar, ModelForce, CP});
            soltemp{i} = interpsol(soltemp{i},ts);
        end
    end
    for i = 1:pnum
        sol = [sol; soltemp{i}];
    end
end