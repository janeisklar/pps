function [ info ] = ppImportDicom(workingDir,transferDir,fileName)
%Imports a DICOM to the subject folder and creates the appropriate
%folders and links

workingDir         = ppGetFullPath(workingDir);
DS                 = filesep(); 

%% Read out basic information about the scan
filePath           = strcat(transferDir,DS,fileName);
[info,header]      = ppFileinfo(filePath);
subject            = lower(header.PatientName.FamilyName);
measurement        = lower(header.PatientName.GivenName);
scanRun            = header.SeriesNumber;
scanId             = strcat('scan_', sprintf('%04d', scanRun));
paradigm           = lower(header.SeriesDescription);
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
measurementLinkDir = strcat(measurementDateDir,subject,            DS);

conflictPath       = strcat(workingDir, 'conflicts');

dirs = {subjectsDir subjectDir measurementDir scanDir dicomDir niftiDir measurementsDir measurementDateDir measurementLinkDir conflictPath};

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

measurementLink    = strcat(measurementLinkDir,   scanId);
scanTarget         = strcat('..', DS, '..', DS, '..', DS, 'subjects', DS, subject, DS, measurement, DS, scanId);

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

%% Get hashes for all dicoms that were already imported
[hashes, hashFilePaths] = ppGetImportedDicomIdentifiers(dicomDir);

%% Move DICOM to the subject directory

fileNameParts           = regexpi(fileName, '(?<before>.*PHYSIKER[^\.]*\.\d*\.)(?<run>\d*)(?<end>\..*\.)(?<date>\d*\.\d*\.ima)$', 'names');

filePattern             = strcat(fileNameParts.before, '\d*', fileNameParts.end, '.*\.ima$');
[unused, importFiles]   = ppGetFilesUsingPattern(transferDir, filePattern);

for i=1:length(importFiles)
	file      = importFiles{i};
	filePath  = strcat(transferDir,DS,file);
	dicomPath = strcat(dicomDir, lower(file));
	
	hash      = ppGetUniqueDicomIdentifier(filePath);
	hashIndex = ppInList(hash, hashes);
	
	if ( hashIndex > 0 )
		conflictingFile = hashFilePaths{hashIndex};
		conflictedDicomPath = strcat(conflictPath, DS, file);
    		[status, mess, messid] = movefile(filePath, conflictedDicomPath);
    
    		% log conflict
    		conflictLogFile = strcat(workingDir, 'conflicts', DS, 'conflicts.fmri');
    		errorHandle = 2;
    		conflictHandle = fopen(conflictLogFile,'a');
		conflictError = sprintf( ...
        '[%s] When comparing the dicom headers it has been found that the file ''%s'' had the same meta-informations as the already-imported file ''%s''. It has therefore been skipped and moved to the conflicts directory. Please resolve the conflicted file ''%s''.\n', ...
        		datestr(now()), ...
 		        file, ...
		        conflictingFile, ...
		        conflictedDicomPath ...
		);
		fprintf(conflictHandle, conflictError);
		fprintf(errorHandle, conflictError);
		fclose(conflictHandle);
    
		if ( status == 0 )
			throw(MException('PPS:IOError','Error while moving conflicted DICOM "%s" from transfer to conflicts folder. Error message was "%s".', dicomPath, mess));
		end
    	else

		[status, mess, messid]  = movefile(filePath, dicomPath);
	
		if ( status == 0 )
		    throw(MException('PPS:IOError','Failed in moving DICOM "%s" from transfer to subject folder. Error message was "%s".', file, mess));
		end
	end
end

end
