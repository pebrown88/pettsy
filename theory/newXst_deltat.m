function [times, matrices] = newXst_deltat(s,t,tb,fsols,rsols,lc,A)

global CP ModelForce solver

% MD this is similar in template to  newXst.  but calculates only to phi
% not p.
% assumes t-s<=CP

% this  returns X(s,t) on the assumtion that tb(1) <= s <= t <=
% tb(end)
%%%MD 01.10 new additions.
At=[];
% solver = str2func('ode15s');
opts = [];
opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-8); % was 1e-4 and 1e-6 %was 1e-5 and 1e-8
%t0 = lc.odesol.x(1);
%t1 = lc.odesol.x(end);



%%%

dim = fsols(1).extdata.varargin{1}{1};
if (dim*dim ~= size(fsols(1).y,1))
    error('dim is not set correctly');
end

if (s > t)
    error('s is greater than t in Xst');
end
if (s == t)
    im=eye(dim);
    matrices = im(:);
    matrices=matrices';
    times=s;
    return;
end
if (s<tb(1))
    error('s is outside the limits set by tb');
end
if (t>tb(end))
    error('t is outside the limits set by tb');
end


% now we fine the tb(i) which are between s and t
i=1;
while(tb(i) <= s)
    i=i+1;
end
sflag=0;tflag=0;
if (i == 1)
    sflag=1;
end
sindex = i;
i=length(tb);
while(t < tb(i)) i=i-1;end
tindex =i;
% fprintf('%d %d %d %d\n',s, tb(sindex),tb(tindex),t);
%if tindex < sindex
%    none_betweenflag = 1;
%else
%    none_betweenflag = 0;
%end
% this gives s<tb(sindex) < tb(tindex) <= t provided at least one between

% now we calculate X(s,t)
% this is X(tb(tindex),t)X(tb(sindex),tb(tindex))X(s,tb(sindex))
% unless there are no tbs between s and t
N = eye(dim); %need to start with N (again diff from newXst)
NN = eye(dim);
if (sindex>tindex) %this means there are no tb(i) values between s and t.
    phi=t;
    u = [0 phi-s];
    im = eye(dim);
    Y0 = im(:);
    sol = feval(str2func(solver), @bint2, u, Y0, opts, {dim, A, At, phi, lc.odesol, lc.par, ModelForce, CP});
   
    for j = 1:length(sol.x)
        Ytmp = zeros(dim,dim);
        Ytmp(:) = sol.y(:,j);
        Ytmp = Ytmp';
        sol.y(:,j) = Ytmp(:);
    end
    % now reverse the order
   sol.x=t-sol.x;
     
   sol.x=fliplr(sol.x);
   sol.y=fliplr(sol.y);
  
    times=sol.x;
    matrices=sol.y;
       
else
    if (sindex < tindex)
        [times, matrices] = newXij(sindex,tindex,tb,rsols,N(:),rsols(tindex).x(1));%MD added -1, added -1 to tindex, otherwise does a higher number
        % times = [rsols(i-1).x times];
    elseif (sindex==tindex)
        times=tb(tindex);
        matrices=N(:);
    end
    v = [];
    NN(:) = matrices(:,1);
    l = length(rsols(sindex-1).x);
    k = 1;
    ntimes = [];
    while  (k<=l) && (rsols(sindex-1).x(l-k+1)>=s) %>= instead of > and added k<=l
        ntimes = [rsols(sindex-1).x(l-k+1) ntimes];
        N(:) = rsols(sindex-1).y(:,l-k+1); %l-j+1);
        N=NN*N; %MD X(t(sindex),t(tindex))*X(s,t(sindex-1))
        v = [N(:) v];
        k = k+1;
    end
    matrices = [v matrices]; %this has all the matrices from X(m,tb(tindex)) for m from lower bound s to  tb((sindex) to tb(tindex)
    times = [ntimes times];
    
    
    NN(:)=interp1(fsols(tindex).x,fsols(tindex).y',t);% X(tb(tindex),phi)
    
    % X(m,phi) for m from s to tb(tindex).
    b=zeros(dim);
    for i=1:length(times)
        b(:)=matrices(:,i);
        b(:)=NN*b;
        matrices(:,i)=b(:);
        
    end
    
    %X(m,phi) for m from tb(tindex) to phi.
    v=[];
    ntimes=[];
    % calculate X(m,phi) by integrating ODE with  m from  phi to tb(tindex)
    phi=t;
    u = [0 phi-tb(tindex)];
    im = eye(dim);
    Y0 = im(:);
    sol = feval(str2func(solver), @bint2, u, Y0, opts, {dim, A, At, phi, lc.odesol, lc.par, ModelForce, CP});
   
    for j = 1:length(sol.x)
        Ytmp = zeros(dim,dim);
        Ytmp(:) = sol.y(:,j);
        Ytmp = Ytmp';
        sol.y(:,j) = Ytmp(:);
    end
    % now reverse the order
    
    sol.x=t-sol.x;
    sol.x=fliplr(sol.x);
    sol.y=fliplr(sol.y);
    
    ntimes=sol.x;
    v=sol.y; %note that last point is the identity.   X(phi, phi)
    
    
    %collating all X(m,phi)  for m from s to t(tindex) to phi.
    times = [times ntimes];
    matrices=[matrices v];
end

matrices=matrices';
