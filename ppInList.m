function [ index ] = ppInList(needle, haystack)

index = 0;

for i=1:length(haystack)
    if ( strcmp(haystack{i}, needle) )
        index = i;
        return;
    end
end
