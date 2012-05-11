#!/bin/bash

export FREESURFER_HOME=/bilbo/usr/local/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

#. /home/rsladky/freesurfer.sh
export FSLOUTPUTTYPE=NIFTI

wd=`pwd`

cd $1/dicom

mri_convert -it siemens_dicom -ot nii *.0001.*.IMA ../nifti/vols.nii
/usr/local/fsl/bin/fslsplit ../nifti/vols.nii ../nifti/vol -t


/usr/local/fsl/bin/fslmaths ../nifti/vols.nii -Tmean ../nifti/mean.nii
/usr/local/fsl/bin/fslmaths ../nifti/vols.nii -Tstd ../nifti/std.nii
/usr/local/fsl/bin/fslmaths ../nifti/mean.nii -div ../nifti/std.nii ../nifti/snr.nii
		
#gunzip $1/nifti/*.gz
#tar cfz $1/dicom/dicom.tar.gz $1/dicom/*.IMA --remove-files
tar cfz dicom.tar.gz *.IMA

#mkdir $2
cp dicom.tar.gz $2/dicom.tar.gz

cd $wd
