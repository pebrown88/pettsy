function [times, matricies] = newXij_deltat(leftint,rightint,tb,rsols,inmatricies,intimes)

%MD similar to newXij




if (leftint >= rightint)
    error('i is greater than j');
end
if (leftint<1)
    error('i is below the limits set by tb');
end
if (rightint-leftint>length(tb))
    error('j is above the limits set by tb');
end

i = rightint;
backsteps = rightint-leftint;

% rsols(i) has the solution to X(s,tb(i+1)) for tb(i)<s<tb(i+1)

times = rsols(i).x;
%N = eye(14); %% change to 
dim = rsols(1).extdata.varargin{1}{1};
N = eye(dim);
NN=N;
if inmatricies == -1
    matricies = rsols(i).y;
    times = rsols(i).x;
    start = 1;
else
    matricies = inmatricies;
    times = intimes;
    start = 1; %MD this is the difference with newXij 
    % could make these two (newXij and newXij_deltat) one file possibly?
end
for j=start:backsteps
    times = [rsols(i-j).x times];
    v = [];
    NN(:) = matricies(:,1);
    l = length(rsols(i-j).x);
    for k =1:length(rsols(i-j).x)
        N(:) = rsols(i-j).y(:,k); %l-j+1);
        N=NN*N;
        v = [v N(:)];
    end
matricies = [v matricies];
end
%plot(times,matricies);   
  
