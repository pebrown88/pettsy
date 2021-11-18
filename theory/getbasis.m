function ba = getbasis(name, t, y, par, ftype, cp)

% function ba = getbasis(system, t, y, dim, par)
%
% calculates an orthogonal basis aligned with the vector field
% by Gramm-Schmidt algorithm
%
% name - model name
% t, y - point x0 where basis is calculated
% par - model parameters
% initial basis is identy matrix with first column equal to vector field 
% (first basis vector is the vector of the phase velocity at the point)



% model dimension
dim = length(y);

% starting basis
ba = eye(dim);

% vector field in the point x0
f = feval(str2func(name), t, y, {par, ftype, cp});
ba(:,1) = f;

% in order to avoid parrallel initial basis vectors
ba(:,2) = -f(end:-1:1);     % this is v(i)=-f(end-(i-1))

% store initial basis
bo = ba;


% Gramm-Schmidt algorithm
% of obtaining of the orthogonal basis from an initial basis
  
for k = 2:dim
    sum1 = zeros(dim);
     
    for j = 1:k-1
        m1 = 0;
        m2 = 0;
        for i = 1:dim
    	    m1 = m1 + (bo(i,k) * ba(i,j));
	        m2 = m2 + (ba(i,j) * ba(i,j));	
        end
   
        for i = 1:dim
        	sum1(i) = sum1(i) + m1 / m2 * ba(i,j);
        end
    end 
 
    for i = 1:dim
      ba(i,k) = bo(i,k) - sum1(i);
    end
end 

% SVD orthogonal basis
%[ba,s,v] = svd(bo);

% scale basis vectors to unit length
for k = 1:dim
    mod = norm(ba(:,k));
    if (mod) 
	    ba(:,k) = ba(:,k) / mod;
    end
end



% check that the basis is orthogonal
er = abs(det(ba)) - 1;
if (er > 1e-6) 
    disp(['warning: basis is not quite orthogonal, det = ', num2str(det(ba))]);
end

ba(:,1) = ba(:,1) * norm(f);
