function [gotEnough, maxElems] = gotEnoughMemory(numElementsRequired, sizeOfElements)



%memory function is at present only avaiable on Windows
global max_dim

maxElems = (max_dim+max_dim^2)^2;
if numElementsRequired < maxElems
    %allows about 50MB for type double
    gotEnough = 1;
else
    gotEnough = 0;
end

return;

%This is the proper function that won't work on Macs

%is there anough free memory available in one block to store a matrix of
%the required size

%numElementsRequired - the number of elements required to be stored
%sizeOfElements - the number of bytes each element requires, eg 8 for
%double

%gotEnough - true of false
%maxElems - number that can be stored if not enough

%find the amount of memory available to Matlab
m = memory;
m = m.MaxPossibleArrayBytes; %most bytes available for one matrix,ie largest continuous block
maxElems = m/sizeOfElements;  %8 bytes for each element required

if numElementsRequired <= maxElems
    %got enough
    gotEnough = 1;
    return;
end
%not enough, but worth trying to re-organise memory to see if enough
%can be created
pack;
m = memory;
m = m.MaxPossibleArrayBytes; %most bytes available for one matrix,ie largest continuous block
maxElems = m/sizeOfElements;  %8 bytes for each element required
if numElementsRequired <= maxElems  
    gotEnough = 1;
else
    gotEnough = 0;
end