%==========================================================================================
function result = createSortableColumn(data)

%applies a hidden prefix to numeric data meaning it is correctly sorted when
%sorted as text, and right aligned in table column

result = cell(length(data),1);
prefixes = cell(length(data),1);
numdigits = zeros(length(data), 1);
padding = zeros(length(data), 1);

%find number of digits before  decimal point.
for i = 1:length(data)
    num_str = sprintf('%.5f', (data(i)));
    dp = find(num_str == '.');
    if ~isempty(dp)
        numdigits(i) = dp-1; %this will include a minus sign for negative values
    elseif isnan(data(i)) || (isinf(data(i)) && data(i) > 0)
        numdigits(i) = -1;  %3 chars 'NaN' or 'Inf'
    elseif isinf(data(i)) && data(i) < 0
        numdigits(i) = -2;  % 4 chars '-Inf'
    else
       %integer number
       numdigits(i)= length(num_str);
    end
    result{i} = num_str;
end

max_digits = max(numdigits);
%get size of padding required so all are aligned the same
padding = max_digits - numdigits;
padding(numdigits == -1) = max(max(cellfun(@length, result))-3, 0); % right align NaN values
padding(numdigits == -2) = max(max(cellfun(@length, result))-4, 0); 


%prepend strings with hidden characters that will ensure they are
%sorted correctly, as java table sort is alway string based
[sorted, sorted_index] = sort(data); %correct ascending order
ascii_values = 65:90; %upper case letters. Dont mix cases as sort not case-sensitive

prefix = [1 1];
for i = 1:length(sorted_index)
    prefixes{sorted_index(i)} = char(ascii_values(prefix));
    if prefix(2) == length(ascii_values)
        %after z, back to 'aa' etc. Will cope with 26^2 values
        prefix = [(prefix(1)+1) 1];
    else
        prefix = [prefix(1) (prefix(2)+1)];
    end
end

%apply prefixes and padding
for i = 1:length(sorted_index)
    result{sorted_index(i)} = ['<html><pre><span style="background-color:white;color:white;font-size:xx-small;">' prefixes{sorted_index(i)} '</span>'  blanks(padding(sorted_index(i))) result{sorted_index(i)} '</pre>'];
end