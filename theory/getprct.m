function [phi,dphi] = getprct(lc,dxdm1,amp0,dlen,prcnum,plist)

t1 = lc.sol.x;
per = lc.per;
cp = t1(end)-t1(1);

dawn = 6;
dusk = dawn+dlen;

pstep = per/(prcnum-1);

st = dawn-4;
en = dawn+dlen+4;


fprintf(1, 'prc curves will be calculated for %d parameters\n',length(plist));
fprintf(1, '%d points on a curve \n',floor(prcnum));

dxdm2 = squeeze(dxdm1(:,1,:));%ircs

for n=1:length(plist)
    dxdm(:,n) = dxdm2(:,plist(n));%ircs for selected params
end    

dxdm = [dxdm; dxdm(2:end,:)];%listed twice
t1=t1-t1(1);
tau = t1(end);
t2 = t1+per;
t=[t1; t2(2:end)]; %time series from 0 to 2*per    
t0 = dawn-2;    %should be zero but is 4? Is this because force is inaccurate at time zero?

for j=1:prcnum    
    k = 0;
 %   fst = 1;
    for i=1:length(t)
        t1 = t(i)+t0;%t always astarts at zero, so t1 always starts at dawn-2
        if t1 > st && t1 < en %store irc * force during perturbation
            k = k+1;%firs perturbation is at time = 6
            force = amp0 * (tanh((t1-dawn)*cp) + 1) * (-tanh((t1-dusk)*cp)+1)/4;
            f(k,:) = dxdm(i,:) * force;
            tf(k) = t1;
          %  if fst > 0 && t1 >= dawn
          %     fprintf(1,'run %d, phase %f, first t = %f\n', j, dawn-t0, t(i));
          %     fst = 0; 
          %  end
        end
    end
    if ~mod(k,2) %if an even number of time stores, add an extra one to end
        f(k+1,:) = 0;
        tf(k+1) = tf(k) + tf(k)-tf(k-1);
    end
    dphi(j,:) = -bsimpson2(f,tf);   %prc = integrated force * irc, only the final integral
    phi(j) = dawn-t0;
    t0 = t0 - pstep;
    clear f tf
end

%force begins beofre on time, so time needs to begin befor ethis. This is
%the reason for the offset.

%function f = myf(t,dawn,dusk)
%f = (tanh(24*t-576*floor(1/24*t)-24*dawn)+1)*...
%    (-tanh(24*t-576*floor(1/24*t)-24*dusk)+1);

%PEB 4/4/2007

%This function intgrates the ircs by the method in bsimpson2. 
%Only the time range where the pertrubation is applied is integrated
%and only the final integral is returned as this represents the total 
%phase change produced.

%t1 is time points for 2 complete cycles, starting at the point determined
%in getperiod, and dxdm is corresponding ircs

%t1 values are 4 to 52 on the first run (if tau = 24), moving to -20 to 28
%on the last. Pulse is applied at 6, so phases of pulse relative to start
%range from 6-4 = 2 to 6--20 = 26 on last 
%pulse time values returned in phi are 2 to 26. These represent the time
%the perturbation was applied relative to the start if th etime series in
%input parameters t1 and dxdm1, ie dphit is produced using dxdmt

%t0 increases the time, when positive, 4 falling to 0, this brings the puls
%earlier. Then it falls from 0 to -20. This brings th epulse later

%phases of perturbations are correct, but they ar enot done over 1 cp o to
%per, but from 2 to per+2 as pulse is not accurat ewhen determined from 0

%this code corrects the problem
phi = mod(phi, tau);%values over tau will become very small
%move these to start.
for i = 2:length(phi)
   if phi(i) < phi(i-1)
       to_move = phi(i:end-1);
       phi(i:end) = [];
       phi = [to_move phi];
       to_move = dphi(i:end-1,:);
       dphi(i:end,:) = [];
       dphi = [to_move; dphi];
       break;
   end
end
%this results in there bein gone less point than requested though
