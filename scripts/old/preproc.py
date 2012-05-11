#!/usr/bin/env python

import os, string, sys, time, commands, re, csv


dir_working = os.getcwd()
dir_script = sys.path[0]

paradigmsCSV = open('paradigms.txt', 'rb')
paradigmsReader = csv.reader( paradigmsCSV, delimiter=' ' )

merge_command = 'export FSLOUTPUTTYPE=NIFTI_GZ; /usr/local/fsl/bin/fslmerge -t '
split_command = 'export FSLOUTPUTTYPE=NIFTI; /usr/local/fsl/bin/fslsplit '

actions = [];

option_recursive = False


if len( sys.argv ) > 1:
	if sys.argv[1].startswith( '-' ):
		for i in range( 1, len( sys.argv[1] ) ):
			opt = sys.argv[1][i]
			if opt == 'r':
				option_recursive = True
			
		actions = sys.argv[2:];
	else: 
		actions = sys.argv[1:];


if option_recursive:
	new_actions = []
	for d in actions:
		for (path, dirs, files) in os.walk( d ):
			found = False
			for d in dirs:
				if d[0:4] == 'scan':
					found = True
					break
			if found:
				new_actions.append( path )

	actions = new_actions




for action in actions:
	paradigmsCSV.seek(0)
	for paradigm in paradigmsReader:
		d = action + '/' + paradigm[0]
		
		if not paradigm[1] == '-':

		
			if not os.path.exists( d + '/dicom/dicom.tar.gz' ):
				print'###################################################################################################'
				print '[' + time.strftime("%H:%M:%S") + '] /dicom/dicom.tar.gz does not exist in ' + d
				print'###################################################################################################'
			else:
				if not os.path.exists( d + '/nifti/swavols.nii.gz' ):
				#if os.path.exists( d + '/nifti/swavols.nii.gz' ): # neues preproc bei bestehenden daten
				
					if os.path.exists( d + '/nifti/vols.nii' ):
						#print split_command + d + '/nifti/vols.nii'
						os.system( 'cd ' + d + '/nifti/; ' + split_command + 'vols.nii' )
					

					print'###################################################################################################'
					print '[' + time.strftime("%H:%M:%S") + '] Preprocessing ' + d
					print'###################################################################################################'
	
				
					os.system( '/usr/local/matlab78/bin/matlab -nodesktop -nosplash -r "cd ' + dir_script + '; swa( \'' + d + '/nifti\' );exit;"' )

					print '[' + time.strftime("%H:%M:%S") + '] Done.'


			
					print'###################################################################################################'
					print '[' + time.strftime("%H:%M:%S") + '] Cleaning up NIFTIs in ' + d
					print'###################################################################################################'

			
			
					if os.path.exists( d + '/nifti/vols.nii' ) and os.path.exists( d + '/nifti/swavol0000.nii' ):
						if os.path.getsize( d + '/nifti/vols.nii' ) > 0:
							os.system( 'rm -f ' + d + '/nifti/vol????.nii;' )

					os.system( merge_command + d + '/nifti/avols.nii ' + d + '/nifti/avol0*.nii' )
					if os.path.exists( d + '/nifti/avols.nii.gz' ) and os.path.exists( d + '/nifti/swavol0000.nii' ):
						if os.path.getsize( d + '/nifti/avols.nii.gz' ) > 0:
							os.system( 'rm -f ' + d + '/nifti/avol????.nii;' )

					os.system( merge_command + d + '/nifti/wavols.nii ' + d + '/nifti/wavol0*.nii' )
					if os.path.exists( d + '/nifti/wavols.nii.gz' ) and os.path.exists( d + '/nifti/swavol0000.nii' ):
						if os.path.getsize( d + '/nifti/wavols.nii.gz' ) > 0:
							os.system( 'rm -f ' + d + '/nifti/wavol????.nii;' );

					os.system( merge_command + d + '/nifti/swavols.nii ' + d + '/nifti/swavol0*.nii' )
					print '[' + time.strftime("%H:%M:%S") + '] Done.'
				else:

					print '[' + time.strftime("%H:%M:%S") + '] swavols.nii.gz present. Omitting ' + d

	
