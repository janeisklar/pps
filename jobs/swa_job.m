%-----------------------------------------------------------------------
% Simple example of a job definition. 
% The prefix 'swa'--although not making sense--has been chosen to obtain
% the expected volume name for the paradigm used for testing.
%-----------------------------------------------------------------------
matlabbatch{1}.spm.spatial.smooth.data = '<UNDEFINED>';
matlabbatch{1}.spm.spatial.smooth.fwhm = [4 4 4];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 'swa';