function [value isterminal direction] = findfirstpeak(t,y, par, ft, cp)

%finds peak times in order to provide a guess at period


global periods ts lastpeak

goodper = zeros(length(y), 1);
ts = [ts; y'];

%save last 3 timepoints
if size(ts,1) > 3
    ts(1,:) = [];
end

%find indices of peaking variables
if size(ts, 1) >= 3
    ispeak = (ts(2,:) > ts(1,:)) & (ts(2,:) > ts(3,:));    
    for i = 1:length(y)
        if ispeak(i)
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
end


%quit solver as soon as we have found good periods for every variable
value = int8(all(goodper));
isterminal = 1;
direction = 0;

