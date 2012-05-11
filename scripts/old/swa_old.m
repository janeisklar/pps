
function swa( directory )
% % % function swa( directory )
% % %   Preprocessing script to perform slice time correction, realignment,
% % %   normalization and smoothing.
% % %
% % %   Usage e.g.:     swa( '.' );
% % %                   assuming your file directory is your current directory
% % %                   and your .nii files are named vol0001.nii etc.
% % %
% % addpath(genpath('/bilbo/usr/local/spm8/'));
% % 
     filelist = dir( directory );


     i = 1;
     for fid = 1:length( filelist )
         filename = filelist( fid ).name;
         if regexpi( filename, '^vol[0-9]*\.nii$')
             filelist_spm{i,1} = [ directory '/' filename ',1' ];
             i = i+1;
         end;
     end;



     if ~exist( 'filelist_spm', 'var' )
	['File not found in ' directory ]
	exit;
	%return;
     end;


     matlabbatch{1}.spm.temporal.st.scans = {filelist_spm};
matlabbatch{1}.spm.temporal.st.nslices = 32;
matlabbatch{1}.spm.temporal.st.tr = 1.4;
matlabbatch{1}.spm.temporal.st.ta = matlabbatch{1}.spm.temporal.st.tr-matlabbatch{1}.spm.temporal.st.tr/matlabbatch{1}.spm.temporal.st.nslices;
matlabbatch{1}.spm.temporal.st.so = [2:2:32 1:2:32];
matlabbatch{1}.spm.temporal.st.refslice = 2;
matlabbatch{1}.spm.temporal.st.prefix = 'a';
matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep;
matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1).tname = 'Session';
matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1).tgt_spec{1}(1).value = 'image';
matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1).tgt_spec{1}(2).value = 'e';
matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1).sname = 'Slice Timing: Slice Timing Corr. Images (Sess 1)';
matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1).src_output = substruct('()',{1}, '.','files');
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 8;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = {};
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [0 1];
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.source(1) = cfg_dep;
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.source(1).tname = 'Source Image';
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.source(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.source(1).tgt_spec{1}(1).value = 'image';
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.source(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.source(1).tgt_spec{1}(2).value = 'e';
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.source(1).sname = 'Realign: Estimate & Reslice: Mean Image';
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.source(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.source(1).src_output = substruct('.','rmean');
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.wtsrc = {};
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.resample(1) = cfg_dep;
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.resample(1).tname = 'Images to Write';
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.resample(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.resample(1).tgt_spec{1}(1).value = 'image';
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.resample(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.resample(1).tgt_spec{1}(2).value = 'e';
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.resample(1).sname = 'Realign: Estimate & Reslice: Realigned Images (Sess 1)';
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.resample(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.resample(1).src_output = substruct('.','sess', '()',{1}, '.','cfiles');
matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.template = {'/bilbo/usr/local/spm8/templates/EPI.nii,1'};
matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.weight = {};
matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.bb = [-78 -112 -50
                                                             78 76 85];
matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.vox = [2 2 2];
matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.interp = 1;
matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
matlabbatch{3}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';
matlabbatch{4}.spm.spatial.smooth.data(1) = cfg_dep;
matlabbatch{4}.spm.spatial.smooth.data(1).tname = 'Images to Smooth';
matlabbatch{4}.spm.spatial.smooth.data(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{4}.spm.spatial.smooth.data(1).tgt_spec{1}(1).value = 'image';
matlabbatch{4}.spm.spatial.smooth.data(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{4}.spm.spatial.smooth.data(1).tgt_spec{1}(2).value = 'e';
matlabbatch{4}.spm.spatial.smooth.data(1).sname = 'Normalise: Estimate & Write: Normalised Images (Subj 1)';
matlabbatch{4}.spm.spatial.smooth.data(1).src_exbranch = substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{4}.spm.spatial.smooth.data(1).src_output = substruct('()',{1}, '.','files');
matlabbatch{4}.spm.spatial.smooth.fwhm = [8 8 8];
matlabbatch{4}.spm.spatial.smooth.dtype = 0;
matlabbatch{4}.spm.spatial.smooth.prefix = 's';

spm_jobman('run_nogui',matlabbatch);
