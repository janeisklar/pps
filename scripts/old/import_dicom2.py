#!/usr/bin/env python

import os, string, sys, time, commands, re

dir_base = "/sacher/mokka/fmri/ssh11/subjects/"
dir_working = os.getcwd()
dir_script = sys.path[0]

merge_command = 'export FSLOUTPUTTYPE=NIFTI_GZ; /usr/local/fsl/bin/fslmerge -t '
actions = [];

lastaction = ''
lastaction_i = 0

option_recursive = False



actions = sys.argv[1:];




print actions

for d in actions:
	if os.path.exists( d + '/dicom/dicom.tar.gz' ):
		print'###################################################################################################'
		print '[' + time.strftime("%H:%M:%S") + '] Converting DICOMs to NIFTIs in ' + d
		print'###################################################################################################'

		run_name = string.lower( string.split( commands.getoutput(dir_script + '/dicomhead ' + d +  '/dicom/*.1.*.IMA | grep "ID Series Description"'), '//' )[2] )
		run_id = string.split( d, '/' )[-1]

		acq_date = string.lower( string.split( commands.getoutput(dir_script + '/dicomhead ' + d +  '/dicom/*.1.*.IMA | grep "ID Acquisition Date"'), '//' )[2] )
		pat_id = string.lower( string.split( commands.getoutput(dir_script + '/dicomhead ' + d +  '/dicom/*.1.*.IMA | grep "PAT Patient Name"'), '//' )[2] )
		pat_id = string.replace( pat_id, '^', '_' )

		acq_date = acq_date[0:4] + '-' + acq_date[4:6] + '-' + acq_date[6:8]

		link_dir = os.path.normpath( dir_base + '/../measurements/' + acq_date )
		pwd_dir = os.path.abspath( d )


		ln_dir = os.path.relpath( pwd_dir, link_dir )

		if not os.path.exists( link_dir ):
			os.system( 'mkdir ' + link_dir )

		if not os.path.exists( link_dir + '/' + pat_id ):
			os.system( 'cd ' + link_dir + '; ln -s ' + ln_dir + ' ' + pat_id + '; cd ' + pwd_dir )

#		if not os.path.exists( dir_base + '/../measurements/' + acq_date + pat_id ):
#			print 'cd ' + dir_base + '/../measurements/' + acq_date + '; ln -s ../' + pat_id



		

		#os.system( dir_script + '/convert_dicom.sh ' + d )

		#print commands.getoutput('./dicomhead ' + d +  '/dicom/*.1.*.IMA | grep "ID Series Description"')
		
#		os.system( 'cd ln -s ' + d + ' ' + re.sub( 'run_.?/', '', d ) + run_id )
#		os.system( 'cd %s; ln -s run_%d' + d + ' ' + re.sub( 'run_.?/', '', d ) + run_id )
				

			
	
