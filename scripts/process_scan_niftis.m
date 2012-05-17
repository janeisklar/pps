function process_scan_niftis( scanDir )
%Checks if all the nifti files are present and creates missing files

DS          = filesep();
dicomDir    = strcat(scanDir, 'dicom', DS);
niftiDir    = strcat('..', DS, 'nifti', DS);
nifti4dPath = strcat(niftiDir, 'vols.nii');

%% Checks the presence of the 4D nifti file and creates it if non-existent
if ( exist(strcat(dicomDir, nifti4dPath), 'file') == 0 )

    [success, error] = convert_dicom_to_nifti(dicomDir, nifti4dPath);

    if ( ~ success )
       throw(MException('PPS:DICOMConvert','Failed converting DICOMS to nifties. Error message was "%s".', error));
    end

end