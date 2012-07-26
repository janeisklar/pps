function [ status ] = ppNiftiCheck(workingPath, niftiPath,PPmode)
%checks the existance and completeness of NIfTI files

status      = 0;
DS          = filesep();

nii         = strcat(niftiPath,'vols.nii');
modeNii     = strcat(niftiPath,PPmode,'vols.nii');

niiPara     = dir(nii);
modeNiiPara = dir(modeNii);

job         = strcat(PPmode,'_job.m');
jobPath     = strcat(workingPath, 'jobs', DS, job);

%% Returns an error in case vols.nii does not exist or is empty
if ( exist(nii) == 0 || niiPara.bytes == 0 )
    throw(MException('PPS:NIfTICheck','vols.nii is missing or is empty'));
    return
end

%% Returns an error in case vols.nii of preprocessing does not exist or is empty
if ( exist(modeNii) > 0 )
    throw(MException('PPS:NIfTICheck','%svols.nii is already present. Preprocessing canceled', PPmode));
    return
end

%% Returns an error in case the job file does not exist
if ( exist(jobPath) < 1 )
    throw(MException('PPS:NIfTICheck','Job for paradigm ''%s'' is missing. Jobfile ''%s'' does not exist! Preprocessing canceled', PPmode, job));
    return
end

status      = 1;