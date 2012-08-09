function [ info ] = ppImportDicom(workingDir,fileName)
%Imports a DICOM to the subject folder and creates the appropriate
%folders and links

workingDir         = ppGetFullPath(workingDir);
DS                 = filesep(); 

%% Read out basic information about the scan
filePath           = strcat(workingDir,'transfer',DS,fileName);
fileName           = lower(fileName);
[info,header]      = ppFileinfo(filePath);
subject            = lower(header.PatientName.FamilyName);
subjectFull        = lower(strcat(header.PatientName.FamilyName, '_', header.PatientName.GivenName));
measurement        = lower(header.PatientName.GivenName);
scanRun            = header.SeriesNumber;
scanId             = strcat('scan_', sprintf('%04d', scanRun));
paradigm           = lower(header.ProtocolName);
scanDate           = datestr(datenum(header.AcquisitionDate, 'yyyymmdd'), 'yyyy-mm-dd');

%% Gather paths to required folders
subjectsDir        = strcat(workingDir,        'subjects',         DS);
subjectDir         = strcat(subjectsDir,       subject,            DS);
measurementDir     = strcat(subjectDir,        measurement,        DS);
scanDir            = strcat(measurementDir,    scanId,             DS);
dicomDir           = strcat(scanDir,           'dicom',            DS);
niftiDir           = strcat(scanDir,           'nifti',            DS);

measurementsDir    = strcat(workingDir,        'measurements',     DS);
measurementDateDir = strcat(measurementsDir,   scanDate,           DS);
measurementLinkDir = strcat(measurementDateDir,subjectFull,        DS);

dirs = {subjectsDir subjectDir measurementDir scanDir dicomDir niftiDir measurementsDir measurementDateDir};

%% Check if folders already exist or create them otherwise
for dir=dirs

    if ( exist(dir{1}, 'dir') > 0 )
        continue;
    end
    
    [status, mess, messid] = mkdir(dir{1});
    
    if ( status > 0 )
        continue;
    end
    
    throw(MException('PPS:IOError','Failed in creating directory "%s". Error message was "%s".', dir{1}, mess));
end

%% Create symbolic links from measurements dir to the scans if not already existent
measurementLink    = strcat(measurementDateDir, subjectFull);
scanTarget         = strcat('..', DS, '..', DS, 'subjects', DS, subject, DS, measurement);

if ( ~ppIsSymlink(measurementLink) )
    status = ppCreateSymlink(scanTarget, measurementLink);
    
    if ( status == 0 )
        throw(MException('PPS:IOError','Failed in creating link from "%s" to "%s". Error message was "%s".', measurementLink, scanTarget, mess));
    end
end

%% Create symbolic links from the paradigm name to the corresponding scan if not already existent

paradigmLink       = strcat(measurementDir, paradigm);
scanTarget         = scanId;
createParadigmLink = true;

if ( ppIsSymlink(paradigmLink) )
    existingScanRun = ppGetScanRunFromLink(paradigmLink);
    
    if (scanRun <= existingScanRun )
        createParadigmLink = false;
    else
        ppRemoveSymlink(paradigmLink);
    end
end


if ( createParadigmLink )
    status = ppCreateSymlink(scanTarget, paradigmLink);
    
    if ( status == 0 )
        throw(MException('PPS:IOError','Failed in creating link from "%s" to "%s". Error message was "%s".', paradigmLink, scanTarget, mess));
    end
end

%% Ensure that to-be-imported DICOM does not exist already
[isUnique, conflictingFile] = ppIsDicomUnique(filePath, dicomDir);

if ( isUnique == 0 )
    conflictPath            = strcat(workingDir, 'conflicts');
    conflictedDicomPath     = strcat(conflictPath, DS, fileName);
    [status, mess, messid]  = movefile(filePath, conflictedDicomPath);
    
    % log conflict
    conflictLogFile         = strcat(workingDir, 'conflicts', DS, 'conflicts.fmri');
    conflictHandle          = fopen(conflictLogFile,'a');
    fprintf( ...
        conflictHandle, ...
        '[%s] When comparing the dicom headers it has been found that the file ''%s'' had the same meta-informations as the already-imported file ''%s''. It has therefore been skipped and moved to the conflicts directory. Please resolve the conflicted file ''%s''.\n', ...
        datestr(now()), ...
        filePath, ...
        conflictingFile, ...
        conflictedDicomPath ...
    );
    fclose(conflictHandle);
    
    if ( status == 0 )
        throw(MException('PPS:IOError','Error while moving conflicted DICOM "%s" from transfer to conflicts folder. Error message was "%s".', fileName, mess));
    end
    
    return
end

%% Move DICOM to the subject directory
dicomPath               = strcat(dicomDir, fileName);
[status, mess, messid]  = movefile(filePath, dicomPath);

if ( status == 0 )
    throw(MException('PPS:IOError','Failed in moving DICOM "%s" from transfer to subject folder. Error message was "%s".', fileName, mess));
end

end