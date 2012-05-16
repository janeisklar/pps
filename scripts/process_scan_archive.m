function process_scan_archive( scanDir )
%Checks the presence of a valid DICOM archive or creates it otherwise

%% Prepare
DS          = filesep();

dicomDir    = strcat(scanDir, 'dicom');
archiveName = 'dicom.tar.gz';
archivePath = strcat(scanDir, 'dicom', DS, archiveName);

dicomList   = ls(dicomDir);
dicomList   = textscan(dicomList,'%s','EndOfLine');
dicomList   = dicomList{1};

%% Check if archive already present
if ( exist(archivePath, 'file') > 0 )

    %% Count DICOM files
    nDicoms     = 0;

    for i=1:length(dicomList)
        file = dicomList{i};
        
        if (regexpi(file, '\.ima$'))
            nDicoms = nDicoms + 1;
        end
    end
    
    %% Get number of files in the archive
    nFiles      = get_tar_file_count(archivePath);
    
    %% Stop futher processing if all files are already in the archive
    if ( nFiles >= nDicoms )
        return
    end
    
    %% Otherwise the archive needs to be deleted prior to further processing
    delete(archivePath);
end

%% Create tar archive of all DICOM files
tar(archivePath, dicomList, dicomDir);
