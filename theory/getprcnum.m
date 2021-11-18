function [prc,pt] = getprcnum(name, t00, y0, per, par, parn, tol,...
    pulseSize, dlen, pstep, plist, varnum, phase)
%PEB added varnum so prc can phase change of any state 2/4/07
global forced;
tol.int = 1e-7;
options = odeset('RelTol', tol.int, 'AbsTol', tol.int);
global method ModelForce CP;
routine = str2func(method);
system = str2func(name);
prcnum = per/pstep+1;
%PEB wrote this alternative routine as the original one assumes dd when using
%per to calculate phase and doesn't allow for using the 'shift' parameter

%first get phase of unperturbed system
if forced
    %switch off light to get phase
    [oldamp, ip] = getpar('amp', parn, par);
    par = setpar('amp', 0, parn, par);
    [t1,y1] = feval(routine,system,[t00 t00 + per * 5],y0,options,par, ModelForce, CP);
    [t1,y1] = getminimum(name, [t1(end) t1(end) + per], y1(end,:), par, varnum, tol.int);
    targetTime = t1(end);
    setpar('amp', oldamp, parn, par);
else
    targetTime = phase + per * 6; %This is trough phase of variable varnum
end
disp('generating numerical prc');
for j=1:length(plist)
    pulseOn = t00;
    pulseOff = pulseOn + dlen;
    px = plist(j);
    fprintf(1, 'for %d parameter: %s\n',px,parn{px});
    fprintf(1, 'for %d points:',prcnum);
    for i=1:prcnum
        %apply perturbation and run for a further 5 cycles
        [t1,y1] = feval(routine,@integraprc,[t00 t00 + per * 5],y0,options,par,pulseSize,pulseOn,pulseOff,px);
        %find next trough
        [t3,y3] = getminimum(name, [t1(end) t1(end) + per], y1(end,:), par, varnum, tol.int);
        %calc phase change
        np = t3(end);
        if np > (targetTime + per/2)
            np = np - per;
        elseif np < (targetTime - per/2)
            np = np + per;
        end
        pc = targetTime - np;
        prc(i,j) = pc;
        pt(i,j) = pulseOn;
        %increment pulse
        pulseOn = pulseOn + pstep;
        pulseOff = pulseOff + pstep;
        fprintf(1,' %d ',i);
        if ~mod(i,15)
            fprintf(1, '\n');      
        end
    end
    fprintf(1,'\n');
end



