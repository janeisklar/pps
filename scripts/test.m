clear all;
clc;

%% DEBUG STUFF *REMOVE*
if (ispc())
    path ='..\\transfer';
else
    path ='../transfer';
end

pps(path);