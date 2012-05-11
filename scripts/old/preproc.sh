#!/bin/bash

/usr/local/matlab74/bin/matlab -desktop -nosplash -r "swa( '$1', '^vol[0-9]*.nii$' );exit;"
