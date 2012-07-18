function [ success, error ] = ppConvertDicomToNifti( dicomPath, niftiPath )
%Converts the DICOMs in the given directory to nifties and saves them to
%the specified directory.

error = '';

%% Determine Freesurfer binary path
if (ismac())
    freesurferhome  = '/Applications/freesurfer';
elseif (isunix())
    freesurferhome  = '/bilbo/usr/local/freesurfer';
else
    disp('Freesurfer tools are not available for Windows. Nifti conversion is therefore skipped.');
    success = 1;
    return;
end

%% Init Freesurfer
command = sprintf('export FREESURFER_HOME="%s";', freesurferhome);
command = strcat(command, 'source $FREESURFER_HOME/SetUpFreeSurfer.sh;');
command = strcat(command, 'export FSLOUTPUTTYPE=NIFTI;');

%% Change to DICOM dir
command = strcat(command, sprintf('cd "%s";', dicomPath));

%% Convert to Nifti
command = strcat(command, sprintf('mri_convert -it siemens_dicom -ot nii *.0001.*.ima "%s"', niftiPath));

[s, error]  = unix(command);

success = (s == 0);

end