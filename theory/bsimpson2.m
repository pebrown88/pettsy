function [integp, integi] = bsimpson2(dxdm, t)

% that function integrates matrix by simpson method
%
% dxdm = dxdm(i1,i2,i3), where i1 - time, i2 - dimension, i3 - parameter number
% t - time vector
% num - number of grid points for integral
% pnum - number of parameters
% dim - system dimension
%
% integp - matrix of integrals

[len,pnum] = size(dxdm);  
s = (len-1)/2+1;
integ = zeros(s,pnum);
% Simpson integration
% integ(i,k,j) - is integral for interval [t=i-2,t=i]
xh = t(2)-t(1);       
integ(1,:) = 0;        
ti(1) = t(1);    %4
kk = 1;        
for i=3:2:len            
    kk = kk+1;            
    ti(kk) = t(i);            
    integ(kk,:) = integ(kk-1,:) + dxdm(i-2,:) / 3 +...
        4 / 3. * dxdm(i-1,:) + dxdm(i,:) / 3;    
end
% final integral        
integp = integ(kk,:) * xh;    
% as function of time        
integ = integ * xh;
%plot(ti,integ)    
for i=1:pnum
    integi(:,i) = interp1(ti,integ(:,i),t)'; 
end

