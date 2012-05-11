#!/usr/bin/env python

import os, string, sys, time, commands, re, csv
VERSION = 'check-1.07.111125 rsl'

print '\nfMRI Check Script %s\n' % VERSION

def help( error='' ):
	
	if len( error ) > 1:
		print 'Error: ' + error
		print

	
	print 'Usage:  check ../measurements/DATE'
	print '  or:   check ../subjects/SUBJECT'
	print
	print 'DATE and SUBJECT can contain wildcards.'
	sys.exit(0)

def removelogs( path ):
	if os.path.exists( path + '/ERROR.fmri' ):
		os.remove( path + '/ERROR.fmri' );
	if os.path.exists( path + '/WARNING.fmri' ):
		os.remove( path + '/WARNING.fmri' );
	if os.path.exists( path + '/OKAY.fmri' ):
		os.remove( path + '/OKAY.fmri' );
	if os.path.exists( path + '/FINDINGS.fmri' ):
		os.remove( path + '/FINDINGS.fmri' );


def errorlog( text='', path='', severity='OKAY', log=True ):
	#severity_shell = '[\033[91m%s   \033[0m]\t' % severity
	severity_shell = {}
	severity_shell['ERROR']   = u' \u251C\u2574[\033[91mE\033[0m]\u2576\u2500 '
	severity_shell['WARNING'] = u' \u251C\u2574[\033[93mW\033[0m]\u2576\u2500 '
	severity_shell['OKAY']    = u'\u2500\u2500\u2574[\033[92mO\033[0m]\u2576\u2500 '
	severity_shell['FINDINGS']= u'\u2500\u2518 \033[91m      '
	
	if len( text ) > 0:
		print u'%s%s\t%s \033[0m' % (severity_shell[severity], text, path )
	else:
		print u'%s%s' % (severity_shell[severity], path )
	
	if log==True:
		status_path = string.replace( path, '/nifti', '' )
		status_path = string.replace( status_path, '/dicom', '' )
		status_path = status_path + '/' + severity + '.fmri'

		if not os.path.exists( status_path ):
			status_fh = open( status_path, "w")
		else:
			status_fh = open( status_path, "a")
		status_fh.write( ('%s\n' % text) )
		status_fh.close();





dir_working = os.getcwd()
dir_script = sys.path[0]




actions = [];

option_recursive = True

if len( sys.argv ) <= 1:
	help()


if len( sys.argv ) > 1:
	#if sys.argv[1].startswith( '-' ):
#		for i in range( 1, len( sys.argv[1] ) ):
#			opt = sys.argv[1][i]#
#			if opt == 's':
#				d = dir_script + '/../subjects/'
#			if opt == 'm':
#				d = dir_script + '/../measurements/'
				
			
	actions = sys.argv[1:];
else: 
	help( 'No valid argument given.' )

if option_recursive:
	new_actions = []
	for d in actions:
		for (path, dirs, files) in os.walk( d, followlinks=True ):
			found = False
			for d in dirs:
				if d[0:5] == 'scan_':
					found = True
					break
			if found:
				new_actions.append( path )

	actions = new_actions

SEV_ERROR = 'ERROR'
SEV_WARNING = 'WARNING'
SEV_OKAY = 'OKAY'
SEV_FINDINGS = 'FINDINGS'

pNAME = 0
pPREPROC = 1
pVOLS = 2
pDICOM = 3

errGlobal = 0;
warnGlobal = 0;



for action in actions:
	paradigmType = string.split(string.split(action, sep='/')[-1], sep='_')[-1]
	errLocal = 0;
	warnLocal = 0;

	removelogs( action )

	if os.path.exists( 'paradigms.txt' ):
		paradigmsCSV = open('paradigms.txt', 'rb')
	else:
		paradigmsCSV = open('paradigms_' + paradigmType + '.txt', 'rb')
	paradigmsReader = csv.reader( paradigmsCSV, delimiter=' ' )

	#os.remove( action + '/OKAY.fmri' );
	paradigmsCSV.seek(0)
	for paradigm in paradigmsReader:
		removelogs( action + '/' + paradigm[pNAME] )


############### Step 1: Check if all paradigms are present.
		if not os.path.exists( action + '/' + paradigm[pNAME] ):
			#print '%s %s/%s - Paradigm does not exist.' % (SEV_ERROR, action, paradigm[pNAME] )
			errorlog( 'Paradigm %s does not exist.' % (paradigm[pNAME]), \
				  '%s' % (action), \
				  SEV_ERROR )
			errLocal += 1
		else:


####################### Step 2: Check if DICOMs exist and are not null.
			dicomarchiveExists = False;
			if os.path.exists( action + '/' + paradigm[pNAME] + '/dicom/dicom.tar.gz' ):
				if os.path.getsize( action + '/' + paradigm[pNAME] + '/dicom/dicom.tar.gz' ) < int(paradigm[pDICOM])*1000000:
					#print '%s %s/%s/dicom - DICOM file is too small.' % (SEV_WARNING, action, paradigm[pNAME] )
					errorlog( 'DICOM file is too small.', \
						  '%s/%s/dicom' % (action, paradigm[pNAME]), \
						  SEV_WARNING )
					warnLocal += 1
				else:
					dicomarchiveExists = True;
			
			dicom_files = os.walk( action + '/' + paradigm[pNAME] + '/dicom/' ).next()[2]
			cnt = 0;
			for f in dicom_files:
				if str.lower(f).endswith( '.ima' ):
					cnt += 1
				#print '%s %s/%s - DICOM is not yet archived.' % (SEV_WARNING, action, paradigm[pNAME] )
				#warnLocal += 1
			if cnt < int( paradigm[pVOLS] ) and not( dicomarchiveExists ):
				#print '%s %s/%s/dicom - %d DICOM images missing.' % (SEV_ERROR, action, paradigm[pNAME], int( paradigm[pVOLS] ) - cnt )
				
				errorlog( '%d DICOM images missing.' % (int( paradigm[pVOLS] )-cnt), \
					  '%s/%s/dicom' % (action, paradigm[pNAME]), \
					  SEV_ERROR )
				errLocal += 1

####################### Step 3: Check if NIFTIs exist according to defined pre-processing methods
			if not os.path.exists( action + '/' + paradigm[pNAME] + '/nifti/vols.nii' ):
				#print '%s %s/%s/nifti - Original NIFTI file not found.' % (SEV_ERROR, action, paradigm[pNAME] )
				errorlog( 'Original NIFTI file not found.', \
					  '%s/%s/dicom' % (action, paradigm[pNAME]), \
					  SEV_ERROR )
				errLocal += 1

			else:
				nifti_path = action + '/' + paradigm[pNAME] + '/nifti/';
				nifti_files = os.walk( nifti_path ).next()[2]
				cnt = 0
				preproc_cnt = 0
				for f in nifti_files:
					if str.lower(f).endswith( '.nii' ):
                                                if str.lower(f).startswith( 'vols' ):
                                                        cnt = -999999 # Merged NIFI exists.
						if str.lower(f).startswith( 'vol0' ):
							cnt += 1
							if paradigm[pPREPROC] == '-':
								preproc_cnt = float("inf")
						if str.lower(f).startswith( paradigm[pPREPROC]+'vol' ):
							preproc_cnt += 1
				if cnt < 0:
					cnt = commands.getoutput( 'export FSLOUTPUTTYPE=NIFTI_GZ; /usr/local/fsl/bin/fslhd ' + nifti_path + '/vols.nii | grep ^dim4' )
					cnt = int( cnt[5:] )
				if cnt < int( paradigm[pVOLS] ):
					#print '%s %s/%s/nifti - %d original NIFTI images missing.' % (SEV_ERROR, action, paradigm[pNAME], int( paradigm[pVOLS] ) - cnt )
					errorlog( '%d original NIFTIs missing.' % (int( paradigm[pVOLS] ) - cnt ), \
						  '%s/%s/nifti' % (action, paradigm[pNAME]), \
						  SEV_ERROR )
					errLocal += 1

				if preproc_cnt == 0:
					#print '%s %s/%s/nifti - NIFTI images not yet preprocessed.' % (SEV_WARNING, action, paradigm[pNAME] )
					errorlog( 'NIFTIs not yet preprocessed.', \
						  '%s/%s/nifti' % (action, paradigm[pNAME]), \
						  SEV_WARNING )
					warnLocal += 1
				elif preproc_cnt < int( paradigm[pVOLS] ):
					#print '%s %s/%s/nifti - %d preprocessed NIFTI images missing.' % (SEV_ERROR, action, paradigm[pNAME], int( paradigm[pVOLS] ) - preproc_cnt )
					errorlog( '%d preproc. NIFTIs missing.' % (int( paradigm[pVOLS] ) - preproc_cnt ), \
						  '%s/%s/nifti' % (action, paradigm[pNAME]), \
						  SEV_ERROR )
					errLocal += 1

	if errLocal == 0 and warnLocal == 0:
		errorlog( '', \
			  '%s' % (action), \
			  SEV_OKAY )
	else:
		errGlobal += errLocal
		warnGlobal += warnLocal
		#print u'\u2500\u2518 \033[91m%s - %d Errors, %d Warnings.\033[0m\n' % (action, errLocal, warnLocal )
		errorlog( u'%d Errors, %d Warnings.\t' % (errLocal, warnLocal), \
			  '%s' % (action), \
			  SEV_FINDINGS )
	print ''

print ' '
if errGlobal == 0 and warnGlobal == 0:
	#print '%s' % (SEV_OKAY)
	#errorlog( '', \
	#	  '%s/%s/nifti' % (action, paradigm[pNAME]), \
	#	  SEV_OKAY )
	print 'Total:\t \033[92m0 Errors, 0 Warnings.\033[0m\n'
else:
	print 'Total:\t \033[91m%d Errors, %d Warnings.\033[0m\n' % (errGlobal, warnGlobal)





