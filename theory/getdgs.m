function [periodic_gs1, gs1, t1] = getdgs(lc, idxdm, bdxdm, sdxdm, vartol, fsols,tb)

%edited by PEB 11/12/2006
%t=t+100;   this would make dlcpar and svd look like old theory
%this function is not scaled for time. Should param t always run from
%zero???

% added outputs pgs1, pscaled_pgs1 to save having to rerun getdgs for the
% phases calculation. 

%Sept 2012, added fsols and tb. THese are output of mintegrate and are
%passed to getdxpar to avoid re-integrating system and sysjac which have
%already been done.

global max_dim dim2;
global PAR_ENV
global ModelForce CP

pnum = length(lc.par);
dpe = idxdm(:,1);   %dperdpar
dim = lc.dim;
dim2 = dim * dim;
t = lc.sol.x;
y0 = lc.sol.y(1,:);
per = lc.per;

% global new_idxdm
% new_idxdm=idxdm;

system = str2func(lc.name);
sysjac = str2func([lc.name,'_jac']);
method = str2func(lc.solver{1});

ba = eye(dim);
y0(dim+1:dim+dim2) = ba(:);
options = odeset('RelTol', vartol,'Refine',1, 'MaxStep', (t(end)-t(1))/200);%,...
%'Abstol',1e-10);

numElementsRequired = numel(y0)^2;
[gotEnough, maxSize] = gotEnoughMemory(numElementsRequired, 8);
% this is to get all the X(t)'s
if gotEnough && isempty(PAR_ENV)
    
    sol = feval(method, @integra, t, y0, options, {lc.par, system, sysjac, dim, ModelForce, CP});
    %this requires creation of a matrix in the solver with (dim + dim^2)^2 so
    %can't do it with really big models
    sol = interpsol(sol, t);
    t1 = t;
    %when using sol, sol. is not meant to be the same as t. Sometimes it
    %can be though
    y1 = sol(1:dim,:);
    ylin = sol(dim+1:end,:);
else
    %must integrate in blocks, either because user want to parallelise or
    %because modle is too big to do in one go
    ylin = [];
    y1 = [];
    if ~isempty(PAR_ENV)
        y0temp = cell(1,dim);
        sol = cell(1,dim);
        for i = 1:dim
            y0temp{i} = [y0(1:dim) y0(dim*i+1:dim*(i+1))];
        end
        par = lc.par;
        parfor i = 1:dim
            sol{i} = feval(method, @integra2, t, y0temp{i}, options, {par, system, sysjac, dim, ModelForce, CP});
            sol{i} = interpsol(sol{i}, t);
        end
        t1 = t;
        y1 = sol{1}(1:dim,:);
        for i = 1:dim
            ylin = [ylin; sol{i}(dim+1:end,:)];
        end
    else
        maxcols = floor(max_dim^2 / dim) * dim;     %requires 50^4 * 8 = about 50Mb memory in one block
        firstcol = dim+1;
        lastcol = min([firstcol+maxcols-1 dim2+dim]);
        while firstcol <= (dim2+dim)
            y0temp = y0(1:dim);%initial conditions
            y0temp = [y0temp y0(firstcol:lastcol)];
            sol = feval(method, @integra2, t, y0temp, options, {lc.par, system, sysjac, dim, ModelForce, CP});
            soly = interpsol(sol, t);
            if isempty(y1)
                y1 = soly(1:dim,:);
                t1 = t;
            end
            ylin = [ylin; soly(dim+1:end,:)];
            firstcol = lastcol+1;
            lastcol = min([firstcol+maxcols-1 dim2+dim]);
        end
    end
end
y1=y1';
ylin = ylin';

y0 = y1(1,:);

% this is to get me all the X(t_i,t_{i+1})'s

[dxde, bs, tdxde] = getdxdpar(t1,lc, fsols,tb);

dxdei = zeros(length(t1),dim,pnum);

%dxdei = dxde;
if t1(end) > tdxde(end)
    t1(end) = tdxde(end);
end
for i=1:dim
    dxdei(:,i,:) = interp1(tdxde,dxde(:,i,:),t1);            
   % sdxdmi(:,:,i) = interp1(t,sdxdm(:,:,i),t1);    %sdxdm not used now
end

% global new_dxdei  new_t1 %DAR this is just for debugging
% new_dxdei = dxdei;
% new_t1 = t1;

%pnum=1;
yy = zeros(dim);
sumx = zeros(length(t1),dim,pnum);
periodic_sumx = zeros(length(t1),dim,pnum);
len = length(t1);

% global new_bdxdm new_ylin  %DAR this is just for debugging
% new_bdxdm= bdxdm;
% new_ylin = ylin;

if ~strcmp(lc.orbit_type,'signal')          % DAR
    display_message('',1);
    pp = dpe/per;
    for j=1:len
        dydt = feval(system,t1(j),y1(j,:),{lc.par, ModelForce, CP});    
        yy(:) = ylin(j,:);

        for pn=1:pnum            
            sumx(j,:,pn) = yy * bdxdm(pn,:)' + dxdei(j,:,pn)'; % this gives the change in the unscaled orbit produces \del g/'del k_i
            %this sumx is non-periodic
            periodic_sumx(j,:,pn) = sumx(j,:,pn);
            if ~lc.forced %PEB edited this line old was 'if amp == 0 && ~strcmp(scaled,'phases')'
                %calc periodic sumx for non-forced models
                % DAR edit here because not necessary to use the phases
                % entry.
                % David's version with linear phase function
                %dpe = dper/dpar
                periodic_sumx(j,:,pn) = periodic_sumx(j,:,pn) +  (dydt * t1(j) * dpe(pn))'/per; %DAR this is the difference with Boris' version
                % Boris's version with nonlinear phase function
                % sumx(j,:,pn) = sumx(j,:,pn) + (dydt * sdxdmi(j,pn,1))';
            end
         %   sumx(j,:,pn) = dxdei(j,:,pn)';
         % this uses the fact that if we scale t to get a constant period
         % the we get the adjustment by the t term. If g(t) is the base
         % periodic orbit, letting
         % sg(t,k)=\xi((tau(k)/tau(k_0)t,x_0(k),k) we have that
         % dsg/dk_i=t d log(tau)/dk_i f(t,sg(t,k_0),k) + (d\xi/dx_0)(dx_0/dk_i) +
         % d\xi/dk_i with all terms evaluated at (t,sg(t,k_0),k) and
         % sg(t,k_0)=g(t).
         % Thus we must just add tdlog(tau)/dk_i f(t,sg(t,k_0),k). Note
         % that  log(tau)/dk_i = (dtau/dk_i(k_0))/tau(k_0)
        end
    %this bit above makes it time dependent  due to use of ' * t1(j)' 
    end
    %for a forced model, sumx, psumx and periodic_sumx are identical
    %for unforced, periodic_sumx is different
    if ~lc.forced
        disp(sprintf('%s %f','CHECK: the derivatives should be periodic in this case: error = ',max(max(max(abs(periodic_sumx(1,:,:)-periodic_sumx(end,:,:)))))));
    end
    periodic_gs = periodic_sumx;
    gs = sumx;
else
    gs = dxdei;%never called by signal system
end

% global new_sumx  %DAR this is just for debugging
% new_sumx = sumx;

% global new_pp  %DAR this is just for debugging
% new_pp = pp;

% parameter scaling matrix
% sc = eye(pnum);
% for k=1:pnum
%     if lc.par(k) > 0
%         sc(k,k) = lc.par(k);
%     end
% end


% for i=1:length(periodic_gs(:,1,1))%for each timepoint
%     pscaled_periodic_gs(i,:,:) = squeeze(periodic_gs(i,:,:)) * sc;%multiply gs(t, :, p) by param value
%     pscaled_gs(i,:,:) = squeeze(gs(i,:,:)) * sc;
% end


gs1 = zeros(length(t),dim,pnum);
periodic_gs1 = zeros(length(t),dim,pnum);

if t(end)>t1(end)
    t(end)=t1(end);
end
for i=1:dim
    periodic_gs1(:,i,:) = interp1(t1,periodic_gs(:,i,:),t); 
%    pscaled_periodic_gs1(:,i,:) = interp1(t1,pscaled_periodic_gs(:,i,:),t);
    gs1(:,i,:) = interp1(t1,gs(:,i,:),t);
 %   pscaled_gs1(:,i,:) = interp1(t1,pscaled_gs(:,i,:),t);
end

