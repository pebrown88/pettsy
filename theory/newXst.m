function [times matrices] = newXst(s,t,tb,fsols,rsols)
% assumes t-s<=CP

% this  returns X(s,t) on the assumtion that tb(1) <= s <= t <=
% tb(end)

dim = fsols(1).extdata.varargin{1}{1}; % dim
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
while(t <= tb(i)) i=i-1;end
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
N = eye(dim);
NN = eye(dim);
if (sindex < tindex)
    [times, matrices] = newXij(sindex,tindex,tb,rsols,-1);%MD added -1
    % times = [rsols(i-1).x times];
    v = [];
    NN(:) = matrices(:,1);
    l = length(rsols(sindex-1).x);
    k = 1;
    ntimes = [];
    while  (k<=l) && (rsols(sindex-1).x(l-k+1)>=s) %MD >= instead of > and added k<=l
        ntimes = [rsols(sindex-1).x(l-k+1) ntimes];
        N(:) = rsols(sindex-1).y(:,l-k+1); %l-j+1);
        N=NN*N; %MD X(s,t(sindex-1))
        v = [N(:) v];
        k = k+1;
    end
    matrices = [v matrices];
    times = [ntimes times];
    
    
   
   % figure;
    %plot(times,matrices);
end
matrices=matrices';
