function [dxde, bs, t1] = getdxdpar(t0,lc, fsols,tb)


global ModelForce CP

pnum = length(lc.par);
dim = length(lc.sol.y(1,:));
dim2 = dim * dim;
syspar = str2func([lc.name,'_dp']);

num =length(tb)-1; %MD changed
th = (t0(end)-t0(1))/num;

intervals = 1;
points = 40;
npoint = 2*intervals*points;
h = th/npoint;  %this is CP/(70*80)

ts(1) = t0(1);
ts(2) = t0(1)+th;
t = t0(1);
y =  lc.sol.y(1,:);
yt1{1} = eye(dim);
yt = zeros(dim);
k = 1;

%MD: I removed the parallelisation as we don't need to do the integration here.
% Since we are not integrating anymore, we still  need some way to get the 
%y's. I have just interpolated sol.y from 0 to tau at a timestep h. 

%no parallelisation
for i=1:num%divides time series into (num) blocks, then divides ech of these blocks into 20 sections
    times = ts(1):h:ts(2);
    %separated y1 into x(t) part and X(t)  parts.
    % both come from interpolation now.
    % X(t) comes from interpolation of the fsols at uniform time
    % steps.
    
    %PEB added 'extrap' as on final interation ts(2) is greater than
    %lc.sol.x(end). This must be due to numerical error
    y1(:,1:dim)= interp1(lc.sol.x, lc.sol.y,times, 'linear', 'extrap');
    y1(1:npoint,dim+1:dim+dim2)=interp1(fsols(i).x', fsols(i).y', times(1:npoint));%get evenly spaced time points for fsols.
    y1(npoint+1,dim+1:dim+dim2)=fsols(i).y(:,end)'; %MD have to do the last point separately since when interpolating sometimes it comes out with NaN values. This last point should be the last point of the fsols(i).y anyway.
    
    % y1(i,dim+1:dim+dim2) is X(ts(1),ts(1)+(i-1)*h)
    t1 = times;
    %disp(sprintf('run %d max is ', i,max(max(y1))));
    %integratin gover very small timesteps fo rmor eaccuracy
    ts(1) = ts(2);
    ts(2) = ts(2)+th;
    % ts(i)<=t<ts(i)+th has exactly 20 steps
    
    t = [t; t1(2:end)'];
    y = [y; y1(2:end,1:dim)];
    
    ytp = eye(dim);
    for j=2:length(t1)
        yt(:) = y1(j,dim+1:dim+dim2); % yt is matrix form of y1
        k = k+1;
        yt1{k} = yt*pinv(ytp);% was yt * inv(ytp) yt1{k}=X(ts(1)+(k-2)*h,ts(1)+(k-1)*h) - use B/A instead of B*inv(A)
        ytp = yt;
        Cnum(k)=cond(yt1{k});% condition number of X(t_i, t_i+1).
    end
    %Cnum is a measure of closeness to a singular matrix. Equal to
    %1/eigenvalue, big Cnum is bad, so this means the time interval
    %wasn't small enough
    % yt1{k} contains the single step matricies i.e.
    % yt1{k}=X(ts(1)+(k-2)*h,ts(1)+(k-1)*h)
   
end

for i=1:length(t)
    bs{i} = feval(syspar,t(i),y(i,1:dim),lc.par, ModelForce, CP)';
end

dxde = getint4(y,zeros(dim,pnum),bs,t,dim,pnum,yt1);
h=(t(2)-t(1))*2;
t1 = t(1):h:t(end);
if abs(t1(end)-t(end))>1e-3
    t1(end+1)=t(end);
end