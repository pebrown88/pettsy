function sds = master_svd6(scaling, all_dgs)

% this function takes in the output of the function get_solutions and
% does a SVD of the d_xi/dk. It then projects this onto the normal and then
% does a SVD of that. Options are noscale_z and noscale_params - default is
% to do scaling

% in the latest version the unscaled, parameters-only scaled and z and
% parameters scaled cases are all worked out

% note that z is a d*num_param x tspan_length matrix where each row is
% of the form dx_i/dk_j(t_m) for a fixed m. As you go down the columns
% i changes faster than jmain

% this is converted into sds.main_deriv where each row j is of the form
% dx_1/dk_j followed by dx_2/dk_j followed by dx_3/dk_j followed by ...

% need to check the unobserved stuff - not finished

% initial version subtracted out the meaan vectors. Decided that this is
% not a good idea as any general deviation/bias is something that should be
% included

%results should be param by dim*timepoint

%dgs from theory - timepoint by variable by parameter 

big_dgs = [];   %combined dgs
main_deriv = cell(length(all_dgs), 1);
dgs = cell(length(all_dgs), 1); %individual dgs's
total_time_length = 0; % added by DAR 22.4.11

for e = 1:length(all_dgs)   %create combined matrix
    
    tmp_dgs = all_dgs{e};
    len_t=size(tmp_dgs,1);
    d = size(tmp_dgs,2); 
    w_pnum=size(tmp_dgs, 3);
    
    total_time_length = total_time_length + len_t;

    % =================================================================
    % reshape the derivative solution so that d/dk_j is all on one row
    % =================================================================

    B=zeros(w_pnum,len_t*d); % column length is pn, row length is l*d
    for pp=1:w_pnum%B is param by d*t
        a = squeeze(tmp_dgs(:,:,pp));
        B(pp,:)=a(:)';
    end

    big_dgs = [big_dgs B];
    
    % =================================================================
    % scale B to remove the dependence on the time-series length
    % =================================================================
    main_deriv{e} = B;

    if ~strcmp(scaling, '-')
        main_deriv{e} = main_deriv{e} / sqrt(len_t);
    end

    B = B/sqrt(len_t);
    
    
    dgs{e} = B;
    
end
 big_dgs = big_dgs/sqrt(total_time_length); % added by DAR 22.4.11

% Store the derivatives

sds.main_deriv = main_deriv;

% Pre-allocate storeage for the svd output, one set for each dgs

sds.U_all = cell(length(dgs), 1);          % U matrix for all, (dim*numt) by (dim*numt)
sds.V_all = cell(length(dgs), 1);          % V matrix for all, nump by nump
sds.spec_all = cell(length(dgs), 1);       % singular spectrun for all, length nump
sds.strengths = cell(length(dgs), 1);      % sing spec for all, nump by nump
sds.slope_spec_all = cell(length(dgs), 1);

% =================================================================
% calculate svd of B
% =================================================================

%inidivual dgs first

for e = 1:length(dgs)
    B = dgs{e};
    [U,S,V] = svd(B',0); % columns of U contain the principal components
    s=diag(S); %length is nump (or dim * numt if smaller, will crash)
    W=inv(V);   %size is nump by nump
    se = zeros(size(W));
    for j=1:w_pnum
        se(j,:)=s(j)*W(j,:); % this gives the strengths
    end

    sds.U_all{e} = U;          % U matrix for all, (dim*numt) by (dim*numt)
    sds.V_all{e} = V;          % V matrix for all, nump by nump
    sds.spec_all{e} = s;       % singular spectrun for all, length nump
    sds.strengths{e} = se;     % sing spec for all, nump by nump

    % ================= get log slopes for specs ===================
    warning off MATLAB:log:logOfZero;
    nn=min(10,w_pnum);

    x=log10(s(1:nn));
    y1=detrend(x);
    dif=x-y1;
    sds.slope_spec_all{e}=(dif(end)-dif(1))/(length(dif)-1);

    warning on MATLAB:log:logOfZero;
end

%now combined dgs

sds.bigU = [];
sds.bigV = [];
sds.bigspec = [];
sds.bigstrengths = [];
sds.bigslope_spec = [];

if length(all_dgs) > 1
    [U,S,V] = svd(big_dgs',0); % columns of U contain the principal components
    s=diag(S); %length is nump (or dim * numt if smaller, will crash)
    W=inv(V);   %size is nump by nump

    se = zeros(size(W));
    for j=1:w_pnum
        se(j,:)=s(j)*W(j,:); % this gives the strengths
    end

    sds.bigU = U;          % U matrix for all, (dim*numt) by (dim*numt)
    sds.bigV = V;          % V matrix for all, nump by nump
    sds.bigspec = s;       % singular spectrun for all, length nump
    sds.bigstrengths = se;     % sing spec for all, nump by nump

    % ================= get log slopes for specs ===================
    warning off MATLAB:log:logOfZero;
    nn=min(10,w_pnum);

    x=log10(s(1:nn));
    y1=detrend(x);
    dif=x-y1;
    sds.bigslope_spec=(dif(end)-dif(1))/(length(dif)-1);

    warning on MATLAB:log:logOfZero;
end
