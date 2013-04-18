function [ status ] = ppCheckParadigmNifti(workingPath, niftiPath, PPmode, isPostPreprocessing)
%checks the existance and completeness of NIfTI files

status      = 0;
DS          = filesep();

%% Error if no preprocessing mode is specified in paradigm.txt
if ( length(PPmode) < 1 )
    throw(MException('PPS:NIfTICheck','Failed to read paradigm, mode is missing in paradigm.txt'));
    return
end

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

if ( isPostPreprocessing )
    %% Returns an error in case the processed %paradigm%vols.nii does not exist after the preprocessing was run
    if ( PPmode(1:1) ~= '-' && exist(modeNii) < 1 )
        throw(MException('PPS:NIfTICheck','%svols.nii does not exist after the preprocessing was run. Preprocessing failed!', PPmode));
        return
    end
else
    %% Returns an error in case the processed %paradigm%vols.nii exists before the preprocessing was run
    if ( exist(modeNii) > 0 )
        throw(MException('PPS:NIfTICheck','%svols.nii is already present. Preprocessing canceled!', PPmode));
        return
    end
end

%% Returns an error in case the job file does not exist
if ( exist(jobPath) < 1 )
    throw(MException('PPS:NIfTICheck','Job for paradigm ''%s'' is missing. Jobfile ''%s'' does not exist! Preprocessing canceled', PPmode, job));
    return
end

status      = 1;
