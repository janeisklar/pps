#!/usr/bin/env python

import sys, os

os.system('sh /home/rsladky/freesurfer.sh')
os.system('export FSLOUTPUTTYPE=NIFTI')

for dir in sys.argv:
	sys.stdout.write( 'Converting ' + dir +'. ')
	os.system('mri_convert -it siemens_dicom -ot nii ' + dir +'/dicom/*.$nr.0001*.IMA ' + dir + '/nifti/vols.nii &')
	os.system('wait $!')
	sys.stdout.write( 'Done.' )

print 'DICOM conversion complete.'
