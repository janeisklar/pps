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
	print'###################################################################################################'
	print '[' + time.strftime("%H:%M:%S") + '] Importing DICOMs from ' + dir_working
	print'###################################################################################################'

	filelist = os.listdir( dir_working )
	for filename in filelist:
		chunks = string.split( filename, '.' )
		subject = string.split( chunks[0], '_' )[0]
		measurement = string.split( chunks[0], '_' )[1]
		run = chunks[3]
	
		dir_subject = string.lower( dir_base + subject )
		dir_measurement = string.lower( dir_subject + '/' + measurement )
		dir_run = string.lower( dir_measurement + '/scan_' + run ) 
	
		os.umask(0)
		
		if not os.path.exists( dir_subject ):
			os.mkdir( dir_subject, 0775 )
		if not os.path.exists( dir_measurement ):
			os.mkdir( dir_measurement, 0775 )
		if not os.path.exists( dir_run ):
			os.mkdir( dir_run, 0775 )
			os.mkdir( dir_run + '/dicom', 0775 )
			os.mkdir( dir_run + '/nifti', 0775 )
	
		os.system( 'mv ' + filename + ' ' + dir_run + '/dicom' )
	
		if len( actions ) == 0:
			actions.append( dir_run )
	
		if actions[-1] != dir_run:
			print  '%4d File(s) -> %s/dicom' % (lastaction_i, actions[-1])
			lastaction_i = 0
			actions.append( dir_run )

		lastaction_i += 1

		if filename == filelist[-1]:
			print  '%4d File(s) -> %s/dicom' % (lastaction_i, actions[-1])

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
	new_actions = []
	for d in actions:
		for (path, dirs, files) in os.walk( d ):
			for d in dirs:
				#print d[0:4]
				if d[0:4] == 'scan':
					new_actions.append( path + '/' + d )

	actions = new_actions

#print actions

for d in actions:
	if not os.path.exists( d + '/dicom/dicom.tar.gz' ):
		print'###################################################################################################'
		print '[' + time.strftime("%H:%M:%S") + '] Converting DICOMs to NIFTIs in ' + d
		print'###################################################################################################'
#		print dir_script + '/dicomhead ' + d +  '/dicom/*.1.*.IMA'
#		run_name = string.lower( string.split( commands.getoutput(dir_script + '/dicomhead ' + d +  '/dicom/*.1.*.IMA | grep "ID Series Description"'), '//' )[2] )
#		run_id = string.split( d, '/' )[-1]

#		acq_date = string.lower( string.split( commands.getoutput(dir_script + '/dicomhead ' + d +  '/dicom/*.1.*.IMA | grep "ID Acquisition Date"'), '//' )[2] )
#		acq_date = acq_date[0:4] + '-' + acq_date[4:6] + '-' + acq_date[6:8]
#		pat_id = string.lower( string.split( commands.getoutput(dir_script + '/dicomhead ' + d +  '/dicom/*.1.*.IMA | grep "PAT Patient Name"'), '//' )[2] )
#		pat_id = string.replace( pat_id, '^', '_' )

#		link_dir = os.path.normpath( dir_base + '/../measurements/' + acq_date )
#		pwd_dir = os.path.abspath( d )


#		ln_dir = os.path.relpath( pwd_dir, link_dir )

#		if not os.path.exists( link_dir ):
#			os.system( 'mkdir ' + link_dir )

#		if not os.path.exists( link_dir + '/' + pat_id ):
#			os.system( 'cd ' + link_dir + '; ln -s ' + ln_dir + ' ' + pat_id + '; cd ' + pwd_dir )


#		


#	if os.path.exists( d + '/dicom/dicom.tar.gz' ):
#		print'###################################################################################################'
#		print '[' + time.strftime("%H:%M:%S") + '] Converting DICOMs to NIFTIs in ' + d
#		print'###################################################################################################'
#		
#		untar = commands.getoutput( 'cd ' + d + '/dicom/; tar xfz dicom.tar.gz' )
#		if string.find( untar, 'crc error') > -1:
#			os.system( 'echo ' + d + ' >> tarerrors ' )
		run_name = commands.getoutput(dir_script + '/dicomhead ' + d +  '/dicom/*.0001.*.IMA | grep "ID Series Description"')

		if string.find( run_name, 'Cannot open file' ) > -1:
			print "WARNING: Error in DICOM file."
		else:
			run_name = string.lower( string.split( run_name, '//' )[2] )

			run_id = string.split( d, '/' )[-1]

			acq_date = string.lower( string.split( commands.getoutput(dir_script + '/dicomhead ' + d +  '/dicom/*.0001.*.IMA | grep "ID Acquisition Date"'), '//' )[2] )
			acq_date = acq_date[0:4] + '-' + acq_date[4:6] + '-' + acq_date[6:8]
			pat_id = string.lower( string.split( commands.getoutput(dir_script + '/dicomhead ' + d +  '/dicom/*.0001.*.IMA | grep "PAT Patient Name"'), '//' )[2] )
			pat_id = string.replace( pat_id, '^', '_' )

			link_dir = os.path.normpath( dir_base + '/../measurements/' + acq_date )
			pwd_dir = os.path.abspath( d + '/..' )


			ln_dir = os.path.relpath( pwd_dir, link_dir )

			if not os.path.exists( link_dir ):
				os.system( 'mkdir ' + link_dir )

			if not os.path.exists( link_dir + '/' + pat_id ):
				os.system( 'cd ' + link_dir + '; ln -s ' + ln_dir + ' ' + pat_id )

			backup_dir = '/dfh/raid/fmri/ssh11/dicoms/'
			if not os.path.exists( backup_dir ):
				os.system( 'mkdir ' + backup_dir )

			backup_dir = backup_dir + '/' + pat_id
			if not os.path.exists( backup_dir ):
				os.system( 'mkdir ' + backup_dir )

			backup_dir = backup_dir + '/' + run_id
			if not os.path.exists( backup_dir ):
				os.system( 'mkdir ' + backup_dir )


			os.system( dir_script + '/convert_dicom.sh ' + d + ' ' + backup_dir)

			#print commands.getoutput('./dicomhead ' + d +  '/dicom/*.1.*.IMA | grep "ID Series Description"')
		
	#		os.system( 'cd ln -s ' + d + ' ' + re.sub( 'run_.?/', '', d ) + run_id )
	#		os.system( 'cd %s; ln -s run_%d' + d + ' ' + re.sub( 'run_.?/', '', d ) + run_id )
				
			create_link = True
		
			if os.path.exists( d + '/../' + run_name ):
				existing_run_id = string.split( commands.getoutput('ls -l %s/../%s ' % (d, run_name)), '-> ' )[-1]
				if existing_run_id == run_id:
					create_link = False
				else:
					print 'WARNING: Run exisits. Moving old run to %s_in_%s' % (run_name, existing_run_id )
					#os.system( 'cd %s/..; mv %s %s_in_%s;' % (d, run_name, run_name, run_id ) )
					os.system( 'cd %s/..; rm -f %s' % (d, run_name ) )
			if create_link:
				os.system( 'cd %s/..; ln -s %s %s; ls -la epi* | sed s/lrwx.*epi_/epi_/ > scans.txt; ls -la t1* | sed s/lrwx.*t1_/t1_/ >> scans.txt;' % (d, run_id, run_name ) )
			
	
