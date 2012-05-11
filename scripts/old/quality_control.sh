#!/bin/bash

export FREESURFER_HOME=/bilbo/usr/local/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export FSLOUTPUTTYPE=NIFTI

wd=`pwd`

for a in `ls ../subjects/*/m*/epi_*/nifti/vols.nii | sed -e 's/vols.nii//'`
do
	echo $a
	cd $a
	if [ ! -f mean.nii ]
	then
		echo "Creating quality control images... "
		fslmaths vols.nii -Tmean mean.nii
		fslmaths vols.nii -Tstd std.nii
		fslmaths mean.nii -div std.nii snr.nii
		echo "Done."
	fi
	cd $wd
done
