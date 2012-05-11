clear all;
clc;

path ='/sacher/raid/fmri/pps12/transfer/CLU12-P020_TRIO.MR.PHYSIKER_CWIND.0015.0177.2012.03.31.18.10.06.906250.59761262.IMA';
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
        
    end
    
    
else
    throw(MException('Id:id','Source Directory must be either "subject" or "transfer"'));
end



%copyfile('path','');

%copy to subjects/subID/measure/scan_run