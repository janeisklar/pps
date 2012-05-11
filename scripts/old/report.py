#!/usr/bin/env python

import os, string, sys, time, commands, re, csv, webbrowser
VERSION = 'report-0.99.110606 rsl'

print '\nfMRI Report Script %s\n' % VERSION

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


#LOGLEV_ALL = 0
#LOGLEV_ERR = 1



dir_working = os.getcwd()
dir_script = sys.path[0]

paradigmsCSV = open('paradigms.txt', 'rb')
paradigmsReader = csv.reader( paradigmsCSV, delimiter=' ' )


actions = [];

option_recursive = True

if len( sys.argv ) < 1:
	help()
else:
	if sys.argv[1].startswith( '-' ):
		for i in range( 1, len( sys.argv[1] ) ):
			opt = sys.argv[1][i]
			if opt == 'h':
				help()
			else:
				help()
		actions = sys.argv[2:]
	else:
		actions = sys.argv[1:]


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
	
	if os.path.exists( action + '/FINDINGS.fmri' ):
		print action


webbrowser.open( 'http://www.orf.at' )


