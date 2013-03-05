function ppCreateDicomBackup( scanDir )
%Checks the presence of a valid DICOM archive or creates it otherwise

%% Prepare
DS          = filesep();

dicomDir    = strcat(scanDir, 'dicom');
archiveName = 'dicom.tar.gz';
archivePath = strcat(scanDir, 'dicom', DS, archiveName);

%% Retrieve DICOM files
[nDicoms, dicomList] = ppGetFilesUsingPattern(dicomDir, '\.ima$');

%% Check if archive already present
if ( exist(archivePath, 'file') > 0 )
    
    %% Get number of files in the archive
    nFiles      = ppGetTarFileCount(archivePath);
    
    %% Stop futher processing if all files are already in the archive
    if ( nFiles >= nDicoms )
        return
    end

    throw(MException('PPS:CreateDicomBackup','Dicom archive(%s) is already present and contains fewer files(%d vs %d) than present in the dicom folder. Fix and restart the preprocessing.', archivePath, nFiles, nDicoms));
end

%% Create tar archive of all DICOM files
tar(archivePath, dicomList, dicomDir);

%% TODO: Upload backup to remote server
