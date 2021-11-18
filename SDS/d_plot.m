function d_plot_str = d_plot(strengths,num_pars,xleft, do_plot)

% this plots the number n of principal components needed
% so that the variance of the error is less than
% 10^d i.e plots n against d

% INPUTS
% strengths: the matrix sds.pscaled_strengths or similar
% num_pars: the number s of parameters
% xleft: plots between [-xleft 0]

% OUTPUT
% d_plot_str.x and d_plot_str.y are the things to be plotted

s1=strengths.^2;
usum=zeros(num_pars,num_pars-1);
for j = 1:num_pars
    all_sum(j)=sum(s1(j,:)); %sum of rows of strengths^2 (pcs)
end
maxsum=max(all_sum);
for j = 1:num_pars
    for d=1:num_pars-1
        usum(j,d)=sum(s1(j,d+1:num_pars))/maxsum;%sum of 1..end, 2..end, 3..end etc.. / maxsum
    end;
end
for d=1:num_pars-1 musum(d)=max(usum(:,d));end
for i=1:num_pars-1 
        dusum(2*i-1)=musum(i);
        dusum(2*i)=musum(i);
        xx(2*i-1)=i;
        xx(2*i)=i+1;
end
warning off MATLAB:log:logOfZero;
ldusum=log10(dusum);    %gives log of zero warnings
warning on MATLAB:log:logOfZero;
ldusum=[0 ldusum];
xx = [1 xx];
if do_plot 
    plot(ldusum,xx(1:length(ldusum)));
    xlim([-xleft 0]);
end
d_plot_str.x=ldusum;
d_plot_str.y=xx(1:length(ldusum));
return