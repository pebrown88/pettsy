function results=find_signal_solution(model,t0,tend,y0,par, results, odeopts)

global  solver numTimepoints gui ModelForce CP  



if tend<t0
    disp 'tend is smaller than t0';%if any phases are last point, set to first
    if ~isempty(gui)
        feval(gui,'write', 'tend is smaller than t0');
    end
    ShowError('tend is smaller than t0')
    results = [];return;
end


tic;
sol = feval(str2func(solver), str2func(model.name), [t0 tend], y0, odeopts,{par, ModelForce, CP});
tt=toc;
y0 = sol.y(:,end);
if any(isnan(y0))
    str = 'Numerical overflow. Please choose better parameter values.';
    disp(str);
    if ~isempty(gui)
        feval(gui,'progress', str);
    end
   ShowError(str);
   results = [];
   return;
end

str = sprintf('base equation solved in %.*f seconds',2,tt);
disp(str);
if ~isempty(gui)
    feval(gui,'progress', str);
end
str = sprintf('solver %s required to use %d points',solver,length(sol.x));
disp(str);
if ~isempty(gui)
    feval(gui,'write', str);
end

numTimepoints = max(floor(length(sol.x)/4),numTimepoints);
if mod(numTimepoints,2) == 0
    str = sprintf('An odd number of timepoints is required. There will be %d',numTimepoints + 1 );
    numTimepoints = numTimepoints + 1;
    disp(str);
else
    str = sprintf('There will be %d timepoints',numTimepoints);
end
if ~isempty(gui)
    feval(gui,'progress', str);
end


%%
disp 'Calculating phases...';%if any phases are last point, set to first
if ~isempty(gui)
    feval(gui,'write', 'Calculating phases...');
end

%find all peaks and troughs
peaks = cell(model.vnum, 1);
troughs = cell(model.vnum, 1);
%for i = 1:size(sol.y, 1)
%    data = sol.y(i,:);
%    for t=2:length(sol.x)-1
%        if (data(t) > data(t-1)) && (data(t) > data(t+1))
%            peaks{i} = [peaks{i} sol.x(t)];
%        elseif (data(t) < data(t-1)) && (data(t) < data(t+1))
 %           troughs{i} = [troughs{i} sol.x(t)];
 %       end
%    end
%end


for i = 1:size(sol.y, 1)
    data = sol.y(i,:);
    s=1;
    max_ind=[];
    min_ind=[];
    for t=2:length(sol.x)-1
        if (data(t) > data(t-1)) && (data(t) > data(t+1))
            s=t;
            max_ind=[max_ind s];
        elseif (data(t) < data(t-1)) && (data(t) < data(t+1))
           
            s=t;
            min_ind=[min_ind s];
        end
    end
   
    if ~isempty(max_ind) %MD new to calculate peaks and troughs. Uses getmaximum and getminimum files. 
        for j=1:length(max_ind)
        f1 = str2func('getmaximum');
        ynul=real(sol.y(:,max_ind(j)-1)');
        [tp,yp] = feval(f1,model.name, [sol.x(max_ind(j)-1) sol.x(max_ind(j)+1)], ynul, par, i, odeopts);
         peaks{i}(j)=tp(end);
        end
    else
        f1 = str2func('getmaximum');
        ynul=real(sol.y(:,end-1)');
        [tp,yp] = feval(f1,model.name, [sol.x(end-1) sol.x(end)+sol.x(2)], ynul, par, i, odeopts);
        if tp(end) <  (sol.x(end)+sol.x(2))
            %if this integration runs to the end, the event was not
            %triggered. This means the variable was flat or continually
            %increasing/decreasing
            peaks{i}=mod(tp(end),sol.x(end));
        end
        
    end
    
    
    if ~isempty(min_ind)
        for j=1:length(min_ind)
        f1 = str2func('getminimum');
        ynul=real(sol.y(:,min_ind(j)-1)'); 
        [tp,yp] = feval(f1,model.name, [sol.x(min_ind(j)-1) sol.x(min_ind(j)+1)], ynul, par, i, odeopts);
         troughs{i}(j)=tp(end);
        end
    else
        f1 = str2func('getminimum');
        ynul=real(sol.y(:,end-1)');
        [tp,yp] = feval(f1,model.name, [sol.x(end-1) sol.x(end)+sol.x(2)], ynul, par, i, odeopts);
        if tp(end) <  (sol.x(end)+sol.x(2))
            %if this integration runs to the end, the event was not
            %triggered. This means the variable was flat or continually
            %increasing/decreasing
            troughs{i}=mod(tp(end),sol.x(end));
        end
        
    end
end

%%
%get required evenly spaced timepoints
results.plotting_timescale=model.plotting_timescale;
results.odesol=sol; % DAR
h = tend / (numTimepoints-1);
t = sol.x(1):h:sol.x(end);
% if mod(length(t) ,2) == 0   %may be needed due to numerical error
%     t(end+1) = sol.x(end);
% end

sol = interpsol(sol, t)';
results.sol.y = sol;

vector_field = zeros(size(sol));

%Find derivatives of the solution
for i=1:length(t)
    vector_field(i,:)=feval(str2func(model.name),t(i),sol(i,:), {par, ModelForce, CP}); %DAR June08
end
results.sol.dy = vector_field;

f = plusforce(model, t, ModelForce, CP); %can miss photo if dusk =18, t(2) may be > 100hrs
results.force = f;
results.sol.x = t'; %(t - t(1))';    %DAR is this right? If forced should not change the t
results.troughs = troughs;%- t(1);
results.peaks = peaks;%- t(1);
results.tend =  tend;

results.par = par;
results.parn = model.parn;
results.parnames = model.parnames;
if length(results.parnames) < length(results.parn)
    results.parnames{end+1} = ' ';
end

%-------------------------------------------------------------------------
%add the dawn and dusk values
%-------------------------------------------------------------------------
for f = 1:length(results.forceparams)
    results.par = [results.par; results.forceparams(f).dawn; results.forceparams(f).dusk];
    results.parn = [results.parn; [results.forceparams(f).force '.dawn']; [results.forceparams(f).force '.dusk']];
    results.parnames = [results.parnames; [results.forceparams(f).force '.dawn']; [results.forceparams(f).force '.dusk']];
end


results.dim = model.vnum;
results.vnames = model.vnames;
results.varnum = [];
results.orbit_type = 'signal';
%%
disp 'Done';%if any phases are last point, set to first
if ~isempty(gui)
    feval(gui,'write', 'Done');
end

return;

