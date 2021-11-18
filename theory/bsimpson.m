function [integp, integi] = bsimpson(dxdm, t)

% that function integrates matrix by simpson method
%
% dxdm = dxdm(i1,i2,i3), where i1 - time, i2 - dimension, i3 - parameter number
% t - time vector
% num - number of grid points for integral
% pnum - number of parameters
% dim - system dimension
%
% integp - matrix of integrals
% integi - these integrals as a function of time using interploation

[len, dim, pnum] = size(dxdm);
if mod(len, 2) == 0 
   ShowError('Limit cycle must have an odd number of timepoints'); 
end

s = (len-1)/2;
integ = zeros(s,pnum,dim);
integp = zeros(pnum,dim);


% Simpson integration
% integ(i,k,j) - is integral for interval [t=i-2,t=i]

xh = t(2)-t(1);

for i=2:2:len
    if (t(i)-t(i-1) - xh) > 1e-10
        ShowError('time step is not constant in simpson');
    end
end

for k=1:pnum
    for j=1:dim
        integ(1,k,j) = 0;
        ti(1) = t(1);
        % integration starts from t=3 (simpson)
        kk = 1;
        for i=3:2:len
            kk = kk+1;
            ti(kk) = t(i);
            integ(kk,k,j) = integ(kk-1,k,j) + ...
                dxdm(i-2,j,k) / 3 + 4 / 3. * dxdm(i-1,j,k) + dxdm(i,j,k) / 3;
        end
        % final integral
        integp(k,j) = integ(kk,k,j) * xh;
        % as function of time
        integ(:,k,j) = integ(:,k,j) * xh;
    end
end
for i=1:dim
    integi(:,:,i) = interp1(ti,integ(:,:,i),t);            
end

