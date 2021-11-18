function [dxde] = getint4(y,i0,bs,t,dim,pnum,yt1)

% dxde(i) is int_0^t(i) X(s,t(i))*bs(s)ds

dxdep = zeros(dim, pnum);
dxde = zeros((length(t)-1)/2+1,dim,pnum);
dxde(1,:,:) = i0;

h = t(2)-t(1);
k = 1;

for i=1:2:length(t)-2
    k = k+1;
    bs1 = bs{i};
    bs2 = bs{i+1};
    bs3 = bs{i+2};

    % yt1{k}=X(ts(1)+(k-2)*h,ts(1)+(k-1)*h)
    % i.e. yt1{k}=X(t(i),t(i+1))
    
    dxdep(:) = dxde(k-1,:,:);
   % sum = h * (inv(yt1{1})*bs1/3+... %MD removed these lines to eliminate calculuating inverses. 
   %     4*inv(yt1{i+1})*bs2/3+...
   %     inv(yt1{i+2}*yt1{i+1})*bs3/3);

    %dxde(k,:,:) = yt1{i+2} * yt1{i+1} * (dxdep + sum); %MD removed lines
    %linked to inverses 
     dxde(k,:,:) = yt1{i+2} * yt1{i+1} * (dxdep+ h*bs1/3)+yt1{i+2}*4*h*bs2/3+h*bs3/3; 
      
end
return



