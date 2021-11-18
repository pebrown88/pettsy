function  [dp, dxdks] = getphases(lc, gs, getdpkdpar, getdypk, getphaseircintegrals)

% rechecked and commented DAR 18.5.12

% dp is the derivative of dxdks phase at which dxdks turning points occur
% (dpkdpar in output
% dxdks is dxdks derivative of the value of dxdks solution at the peak
% point (dypk in output)

% this calculation uses the fact that dt_i/dk_j = -(J(t).dg/dk_j)_i/dotdoty_i and
% dotdoty_i = df/dt + df/dy.dotg = df/dt + J(t).g = J(t).y if we assume
% that df/dt = 0 at t as is the case if dxdks system is not forced or if tm is
% at a point where the force level is locally constant.

%the last input indicates the peak derivatives are required to calculate
%inegrals for phase irc. My not need trough derivatives

global dim ModelForce CP

pnum = length(lc.par);
dim = lc.dim;
t = lc.sol.x;
y = lc.sol.y;

system = str2func(lc.name);
sysjac = str2func([lc.name,'_jac']);
syspar = str2func([lc.name,'_dp']);
dp = []; dxdks = [];

%Changed by PEB October 2012 to find all peaks for all variables, and flags
%added as input to inicate which ouptuts
if getdpkdpar || getphaseircintegrals
    dp.peaks = cell(1,dim);
    
    if getdpkdpar
        dp.troughs = cell(1,dim);
    else
        dp.troughs = [];
    end
end

if getdypk
    dxdks.peaks = cell(1,dim);dxdks.troughs = cell(1,dim);
end

for  varnum=1:dim
    
    for peaknum = 1:length(lc.peaks{varnum})
        pktime = lc.peaks{varnum}(peaknum);
        
        ym = interp1(t,y,pktime);  % value of solution at peak time
        jac = feval(sysjac, pktime, ym, lc.par, ModelForce, CP);        % Jacobian
        dydt = feval(system, pktime, ym, {lc.par, ModelForce, CP});       %\dot{y} at tm
        bs = feval(syspar, pktime, ym, lc.par, ModelForce, CP);         %derivative of vectorfield at tm
        
        %dgs for all vars at peak time
        for k=1:dim
            gsm(:,k) = (interp1(t,squeeze(gs(:,k,:)),pktime))'; % changed by DAR: added squeeze dx_k/dk_j at tm
            % this is \del g_k/\del k_: evaulated at peak time
        end  %gsm - par * dim
        
        left = jac * gsm';  %J(t).df/dk at pktime dimensions : vars x params
        % this is J(tm)*(\del g/\del k)
        
        left1 = left(varnum,:) + (bs(:,varnum))';
        % this is J(pktime)*(\del g/\del k)_{varnum}
        
        right = jac * dydt; %J(t).dydt
        right1 = right(varnum,:);
        
        
        %d_pktime/dpar
        % dp.peaks{varnum}{peaknum} = (-left1/right1)';  % -(J(t).dydt)^-1 . J(tm).df/dk
        dpkdpar =  (-left1/right1)';
        
        if getdpkdpar || getphaseircintegrals
            dp.peaks{varnum} =[dp.peaks{varnum} dpkdpar];
        end
        if getdypk
            %param * var
            for j=1:pnum
                dxt(j,:) = (dydt * dpkdpar(j))';
            end
            %dy/dpar at peak time
            dxdk = gsm + dxt; % this is J(tm)*(\del g/\del k)
            dxdks.peaks{varnum} = [dxdks.peaks{varnum} dxdk(:,varnum)]; %param * var
        end
    end
    if getdpkdpar || getdypk
        %dont need trough information is all we want is to calculate
        %integrals of phase ircs
        for troughnum = 1:length(lc.troughs{varnum})
            trtime = lc.troughs{varnum}(troughnum);
      
            
            ym = interp1(t,y,trtime);  % value of solution at peak time
            jac = feval(sysjac, trtime, ym, lc.par, ModelForce, CP);        % Jacobian
            dydt = feval(system, trtime, ym, {lc.par, ModelForce, CP});       %\dot{y} at tm
            bs = feval(syspar, trtime, ym, lc.par, ModelForce, CP);         %derivative of vectorfield at tm
            
            %dgs for all vars at peak time
            for k=1:dim
                gsm(:,k) = (interp1(t,squeeze(gs(:,k,:)),trtime))'; % changed by DAR: added squeeze dx_k/dk_j at tm
                % this is \del g_k/\del k_: evaulated at peak time
            end  %gsm - par * dim
            
            left = jac * gsm';  %J(t).df/dk at pktime dimensions : vars x params
            % this is J(tm)*(\del g/\del k)
            
            left1 = left(varnum,:) + (bs(:,varnum))';
            % this is J(pktime)*(\del g/\del k)_{varnum}
            
            right = jac * dydt; %J(t).dydt
            right1 = right(varnum,:);
            
            %d_pktime/dpar
            dtrdpar = (-left1/right1)';
            if getdpkdpar
                dp.troughs{varnum} = [dp.troughs{varnum} dtrdpar];  % -(J(t).dydt)^-1 . J(tm).df/dk
            end
            if getdypk
                %param * var
                for j=1:pnum
                    dxt(j,:) = (dydt * dtrdpar(j))';
                end
                %dy/dpar at peak time
                dxdk = gsm + dxt; % this is J(tm)*(\del g/\del k)
                dxdks.troughs{varnum} =  [dxdks.troughs{varnum} dxdk(:,varnum)]; %param * var
            end
        end
    end
    
end
return






