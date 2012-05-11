#!/usr/bin/env python

import os, string, sys, time, commands, re

dir_base = "/mokka/fmri/ssh11/subjects/"
dir_working = os.getcwd()
dir_script = sys.path[0]

merge_command = 'export FSLOUTPUTTYPE=NIFTI_GZ; /usr/local/fsl/bin/fslmerge -t '
actions = [];

lastaction = ''
lastaction_i = 0

option_recursive = False


if len( sys.argv ) <= 1:
	print '[' + time.strftime("%H:%M:%S") + '] Done.'
else:
	if sys.argv[1].startswith( '-' ):
		#print sys.argv[1][0];
		for i in range( 1, len( sys.argv[1] ) ):
			opt = sys.argv[1][i]
			if opt == 'r':
				option_recursive = True
			
		actions = sys.argv[2:];
	else: 
		actions = sys.argv[1:];


if option_recursive:
	print 'Recursive.'
	new_actions = []
	for d in actions:
		print d
		for (path, dirs, files) in os.walk( d ):
			for d in dirs:
				if d[0:4] == 'scan':
					new_actions.append( path + '/' + d )

	actions = new_actions



for d in actions:
	if os.path.exists( d + '/dicom/dicom.tar.gz' ):
		print'###################################################################################################'
		print '[' + time.strftime("%H:%M:%S") + '] Converting DICOMs to NIFTIs in ' + d
		print'###################################################################################################'
		
		untar = commands.getoutput( 'cd ' + d + '/dicom/; tar xfz dicom.tar.gz' )
		if string.find( untar, 'crc error') > -1:
			os.system( 'echo ' + d + ' >> tarerrors ' )
	run_name = commands.getoutput(dir_script + '/dicomhead ' + d +  '/dicom/*.1.*.IMA | grep "ID Series Description"')

	if string.find( run_name, 'Cannot open file' ) > -1:
		print "WARNING: Error in DICOM file."
	else:
		run_name = string.lower( string.split( run_name, '//' )[2] )

		run_id = string.split( d, '/' )[-1]

		acq_date = string.lower( string.split( commands.getoutput(dir_script + '/dicomhead ' + d +  '/dicom/*.1.*.IMA | grep "ID Acquisition Date"'), '//' )[2] )
		acq_date = acq_date[0:4] + '-' + acq_date[4:6] + '-' + acq_date[6:8]
		pat_id = string.lower( string.split( commands.getoutput(dir_script + '/dicomhead ' + d +  '/dicom/*.1.*.IMA | grep "PAT Patient Name"'), '//' )[2] )
		pat_id = string.replace( pat_id, '^', '_' )

		link_dir = os.path.normpath( dir_base + '/../measurements/' + acq_date )
		pwd_dir = os.path.abspath( d + '/..' )


		ln_dir = os.path.relpath( pwd_dir, link_dir )

		if not os.path.exists( link_dir ):
			os.system( 'mkdir ' + link_dir )

		if not os.path.exists( link_dir + '/' + pat_id ):
			os.system( 'cd ' + link_dir + '; ln -s ' + ln_dir + ' ' + pat_id )

 
		#os.system( dir_script + '/convert_dicom.sh ' + d )

		#print commands.getoutput('./dicomhead ' + d +  '/dicom/*.1.*.IMA | grep "ID Series Description"')
		
#		os.system( 'cd ln -s ' + d + ' ' + re.sub( 'run_.?/', '', d ) + run_id )
#		os.system( 'cd %s; ln -s run_%d' + d + ' ' + re.sub( 'run_.?/', '', d ) + run_id )
				
#		create_link = True
#		
#		if os.path.exists( d + '/../' + run_name ):
#			existing_run_id = string.split( commands.getoutput('ls -l %s/../%s ' % (d, run_name)), '-> ' )[-1]
#			if existing_run_id == run_id:
#				create_link = False
#			else:
#				print 'WARNING: Run exisits. Moving old run to %s_in_%s' % (run_name, existing_run_id )
#				os.system( 'cd %s/..; mv %s %s_in_%s;' % (d, run_name, run_name, run_id ) )
#		
#		if create_link:
#			os.system( 'cd %s/..; ln -s %s %s; ls -la epi* | sed s/lrwx.*epi_/epi_/ > scans.txt; ls -la t1* | sed s/lrwx.*t1_/t1_/ >> scans.txt;' % (d, run_id, run_name ) )
#			
	
