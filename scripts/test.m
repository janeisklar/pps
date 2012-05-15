clear all;
clc;

if (ispc())
    path ='..\\transfer';
else
    path ='../transfer';
end
exPath=regexpi(path,'(?<workingDir>.*)(?<mode>subjects|transfer)', 'names');

workingDir=exPath.workingDir;
mode=exPath.mode;
inputDir=strcat(workingDir,mode);

if(mode=='subjects')
    %preprosessing
elseif(mode=='transfer')
    list = ls(inputDir);
    sepList=textscan(list,'%s','EndOfLine');
    
    for i=1:length(sepList{1})
        file=sepList{1}{i};
        
        import_dicom(workingDir,file);
        
        % begin remove this in the final version
        % if(i>10) break; end
        % end remove
    end
    
    
else
    throw(MException('PPS:invalidPath','Source Directory must be either "subject" or "transfer"'));
end



%copyfile('path','');

%copy to subjects/subID/measure/scan_run