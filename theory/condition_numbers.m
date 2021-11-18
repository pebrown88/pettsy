function  result=condition_numbers(fsols,rsols,tb, num_intervals)

global reject_condition_number;

N=zeros(sqrt(size(fsols(1).y,1)));
M=zeros(sqrt(size(fsols(1).y,1)));
for i=1:length(tb)-1 %returns fsols and rsols back to matrix form
    for j=1:size(fsols(i).y,2) 
    N(:)=fsols(i).y(:,j);
    Fcond{i}(j)=cond(N);
    end
    for j=1:size(rsols(i).y,2) 
    M(:)=rsols(i).y(:,j);
    Rcond{i}(j)=cond(M);
    end
end

%for each interval (t_i, t_i+1) we identify the max condition numbers of
%fsols (matrices X(t_i,s)) and rsols (matrices X(s, t_i+1))
for i=1:length(tb)-1
    Rmax(i)=max(Rcond{i});
    Fmax(i)=max(Fcond{i});
    %extras: finding the gradient of the log of condition number on each
    %time interval:
%    [rr(i),mr(i),br(i)] = regression(rsols(i).x,log(Rcond{i}));
 %   [rf(i),mf(i),bf(i)] = regression(fsols(i).x,log(Fcond{i}));
end

%identifying  maximum condition number of fsols and rsols on the interval (0, tau) and
%interval where they are found.
[Rmax_tot,rindex]=max(Rmax);
[Fmax_tot,findex]=max(Fmax);


%plot of the condition numbers for the interval (t_i, t_i+1) where largest condition number of fsols and
%largest condition number of rsols are found. 
condition_number_gui('init', rindex, (rsols(rindex).x-tb(rindex))/(tb(2)),log(Rcond{rindex}), findex, (fsols(findex).x-tb(findex))/(tb(2)),log(Fcond{findex}), num2str(num_intervals));
result = reject_condition_number;
return;

figure
plot((rsols(rindex).x-tb(rindex))/(tb(2)),log(Rcond{rindex}),'b.');
hold on
plot((fsols(findex).x-tb(findex))/(tb(2)),log(Fcond{findex}),'r.');
ylabel('log(\kappa (X)) (\kappa is condition no.)')
xlabel(['s (as a fraction of the interval from t_{',num2str(findex), '} to t_{',num2str(findex+1), '})'])
legend(['X=X(s,t_{',num2str(rindex+1), '})'],['X=X(t_{',num2str(findex), '},s)']);
%OPTIONAL: plotting the gradient of the best linear fit (this is to see how
%good the linear regression fit is):
%hold on;
%plot((rsols(rindex).x-tb(rindex))/(tb(2)),(br(rindex)+mr(rindex)*rsols(rindex).x(1))+(mr(rindex)*tb(2))*(rsols(rindex).x-tb(rindex))/(tb(2)),'k');
%plot((fsols(findex).x-tb(findex))/(tb(2)),(bf(findex)+mf(findex)*fsols(findex).x(1))+(mf(findex)*tb(2))*(fsols(findex).x-tb(findex))/(tb(2)),'k');


%plot of the gradient of the best linear fit to log of the condition numbers in each time interval:
return;

figure
plot(mr,'b.');
hold on
plot(mf,'r.');
ylabel('gradient of linear approx to log(\kappa(X)) in interval (t_i, t_{i+1})')
xlabel('i')
legend(['X is set of matrices (X(s,t_{i+1}))'],['X is set of matrices (X(t_i,s))']);





