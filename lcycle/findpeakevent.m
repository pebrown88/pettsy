function [value, isterminal, direction] = findpeakevent(t,y, userdata)

%finds peak times in order to provide a guess at period

%With matlab solvers, 


global method

if strcmp(method{1}, 'matlab')

    %matlab
    isterminal = 1;
    direction = 0; %peak or trough
else
    %cvode
    isterminal = 0; %indicates no error
    direction = []; %just a placeholder. Must be set to empty
end

foundpeaks = 0;

global maxIdx;
global periods yvals tvals lastpeak %initially empty

 %save time series
if maxIdx > 0
    yvals = [yvals; y(maxIdx)];%variable with biggest amp
else
    yvals = [yvals; y'];
end
tvals = [tvals; t];
    
if size(yvals, 1) >= 3 %enough timepoints
    if maxIdx > 0
        %look only for periods in this one variable
        ispeak = (yvals(end-1) > yvals(end-2)) & (yvals(end-1) > yvals(end));
        if ispeak 
            if lastpeak
                periods = [periods (t-lastpeak)];
                if length(periods) >= 3
                    goodper = (min(periods(end-2:end)) >= (0.9 * max(periods(end-2:end))));
                    if ~goodper && length(periods) >= 5
                        %here we compare every alternate period value
                        goodper = (min(periods(end-4:2:end)) >= (0.9 * max(periods(end-4:2:end))));
                    end
                    %triphasic
                    if ~goodper && length(periods) >= 7
                        goodper = (min(periods(end-6:3:end)) >= (0.9 * max(periods(end-6:3:end))));
                    end
                    foundpeaks = int8(goodper);
                end
            end
            lastpeak = t;
        end
    else
        
        goodper = zeros(length(y), 1);
        %find indices of peaking variables
        for i = 1:length(y)
           ispeak = (yvals(end-1,i) > yvals(end-2,i)) & (yvals(end-1,i) > yvals(end,i));
           if ispeak
                if lastpeak(i)
                    periods{i} = [periods{i} (t-lastpeak(i))];
                end
                lastpeak(i) = t;
            end
            if length(periods{i}) >=3
                %check if last 3 periods for each var are within 10% of each other
                goodper(i) = (min(periods{i}(end-2:end)) >= (0.9 * max(periods{i}(end-2:end))));
                %if not, checkif it is a biphasic var
                if ~goodper(i) && length(periods{i}) >= 5
                    %here we compare every alternate period value
                    goodper(i) = (min(periods{i}(end-4:2:end)) >= (0.9 * max(periods{i}(end-4:2:end))));
                end
                %triphasic
                if ~goodper(i) && length(periods{i}) >= 7
                    goodper(i) = (min(periods{i}(end-6:3:end)) >= (0.9 * max(periods{i}(end-6:3:end))));
                end
            end
        end
     
        if any(goodper)
            %As we have found at least one periodic variable, eliminate any that
            %are flat (min > 99% max) over the oscillating period
            %also ignore any that are < max peak * 10^-9 for whole period
            maxper = max(cell2mat(periods'));
            tidx = find(tvals > (tvals(end)-maxper), 1);
            maxpeak = max(max(yvals(tidx:end,:)));
            ignore = [];
            for i = 1:length(periods)
                if isempty(periods{i})
                    if min(yvals(tidx:end,i)) > (max(yvals(tidx:end,i))*0.99)
                        ignore = [ignore i];
                    elseif max(yvals(tidx:end,i)) < maxpeak*10^-9
                        ignore = [ignore i];
                    end
                    
                end
            end
            goodper(ignore) = [];
        end
        %quit solver as soon as we have found good periods for every variable
        foundpeaks = int8(all(goodper));
        
       
    end
end


if foundpeaks
    value = 0; %stop
else
    value = 1;
end

