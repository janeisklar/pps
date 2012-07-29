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
    
    %% Otherwise the archive needs to be deleted prior to further processing
    delete(archivePath);
end

%% Create tar archive of all DICOM files
tar(archivePath, dicomList, dicomDir);
