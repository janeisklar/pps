function [ success, error ] = ppConvertDicomToNifti( dicomPath, niftiDir, niftiName)
%Converts the DICOMs in the given directory to nifties and saves them to
%the specified directory.

error = '';

% %% Determine Freesurfer binary path
% if (ismac())
%     freesurferhome  = '/Applications/freesurfer';
% elseif (isunix())
%     freesurferhome  = '/z/fmrilab/lab/freesurfer';
% else
%     disp('Freesurfer tools are not available for Windows. Nifti conversion is therefore skipped.');
%     success = 1;
%     return;
% end
% 
% %% Init Freesurfer
% command = sprintf('export FREESURFER_HOME="%s";', freesurferhome);
% command = strcat(command, 'source $FREESURFER_HOME/SetUpFreeSurfer.sh;');
% command = strcat(command, 'export FSLOUTPUTTYPE=NIFTI;');
%
% Change to DICOM dir
%command = strcat(command, sprintf('cd "%s";', dicomPath));
command = sprintf('cd "%s";', dicomPath);

%% Convert to Nifti
%command = strcat(command, sprintf('f=`ls *.ima | head -n 1`; export UNPACK_MGH_DTI=0; mri_convert -it siemens_dicom -ot nii $f "%s"', niftiPath));
command = strcat(command, sprintf('/z/fmrilab/lab/mcverter/mcverter -o "%s" -F "%s" -f nifti --nii -d "%s"', niftiDir,niftiName,dicomPath));

[s, error]  = unix(command);

success = (s == 0);

CdDicomFolder = sprintf('cd "%s";', dicomPath);
unix([CdDicomFolder, sprintf('fslorient -copyqform2sform "%s".nii',fullfile(niftiDir,niftiName))]);

end
