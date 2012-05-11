#!/usr/bin/env python

import sys, os, time

for d in sys.argv[1:]:
	if os.path.exists( d + '/dicom/dicom.tar.gz' ):
		if os.path.getsize( d + '/dicom/dicom.tar.gz' ) > 0:
			print '[' + time.strftime("%H:%M:%S") + '] Okay.'
