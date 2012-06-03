function [ output_args ] = ppSearch(workingDir,mode)
%workingDir='E:/Uni/CognitiveScience/fMRI/pps12/';
clc;

BooleanOwnParadigm=0;

path=strcat(workingDir,'/',mode)
path=dir(path)

for i=3:length(path)
    names=[path(i).name];
    subPath=strcat(workingDir,mode,'/',names);
    fName=regexpi(names, '(?<cut>^[a-z]*)', 'names');
    fName=fName.cut;
    fGen=strcat('paradigms_',mode,'.txt');
    names;
    
    if names(1:1)==fGen(1:1) %%%%%%%%%%% dont match!! %%%%%%%%%%%%%%%%%%%%%
        
        BooleanOwnParadigm=1
        
        %write file: ('specified paradigm for ',mode)
        
        %read subPath
        %readParadigm(subPath)
        %end
        %fprint='------------HERE---------------'
    end
end

sSubject=dir(subPath);
subsub=dir([subPath]);

for j=3:length(subsub)
    subNames=[subsub(j).name]
    
    ppsearch(subPath,subNames)
end

if BooleanOwnParadigm==0;
    BooleanOwnParadigm
    %read paradigms.txt
    %readParadigm(/scripts/paradigms.txt)
end
end

% \A[a-z]*