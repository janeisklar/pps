%   a script-call to dicom_sort_convert_main, for performing convertions
%   and sorting on multiple data sets

function example_dscm_call

%%%%%%%USER-DEFINED PARAMETERS START HERE%%%%%%%%%%%%%%%

%COMPULSORY PARAMETERS
rootfile_dir = '/dfh/raid/data/simon/patients_kinn_spr';
readfile_dirs = {'kinn/k8/dicom'}; 

%PARAMETERS V. LIKELY NEEDED
data.retain_dicom = 'no';
data.convert = 'yes';
data.convert_format = 'nifti';
data.scanlistonly = 'yes'; %

%OPTIONAL PARAMETERS
data.workbar_off = 'yes';
data.test = 'yes'; % if test='no', the .IMA data are made into a tarball after sorting
data.define_writefile_subdir = 'no';
data.writefile_dir='/tmp/';

%%%%%%%END OF USER-DEFINED PARAMETERS, UNLESS DIFFERENT OPTIONS ARE REQUIRED FOR DIFFERENT SCANS%%%%%%%%%%%%%%%

data.readfile_filter = '*.IMA';

%first check that the directories exist and that they've got data in them
%to process
errors_present = 'no';
error_text = '';

for i=1:length(readfile_dirs)
    readfile_dir = fullfile(rootfile_dir, char(readfile_dirs(i)));
    if isdir(readfile_dir)~=1
        error_text = sprintf('%s%s is not a valid directory\n', error_text, readfile_dir);
        errors_present = 'yes';
    end
    flist = dir(fullfile(readfile_dir, data.readfile_filter));
    nfiles = length(flist);
    if(nfiles == 0)
        error_text = sprintf('%sNo %s files in %s\n', error_text, data.readfile_filter, readfile_dir);
        errors_present = 'yes';
    end
end

if strcmp(errors_present,'yes')
    disp(error_text);
    return;
end

%pre-check that these are all the same subject - this is done in execute_sort_convert_Callback but this is the chance to sort multiple
%subjects
num_subs=1;
current_subject_name = get_dicom_fieldname_func(flist(1).name, 0);
subject_names(1) = {current_subject_name};
for n = 1:nfiles
    %check its the same subject
    if strcmp(get_dicom_fieldname_func(flist(n).name, 0), current_subject_name) ~= 1
        num_subs = num_subs+1;
        current_subject_name = get_dicom_fieldname_func(flist(n).name, 0);
        subject_names(num_subs) = {current_subject_name};
    end
end

if num_subs > 1
    multiple_subject_alert_continue = questdlg(sprintf('Images belong to different subjects, \nDo you want to sort them all?'), ...
        'Multiple Subject Alert', ...
        'Yes', ...
        'No', ...
        'No');
    switch multiple_subject_alert_continue
        case 'No'
            return;
    end
end

%do the conversion
for j=1:num_subs
    for i=1:length(readfile_dirs)
        if num_subs > 1
            data.readfile_filter = [char(subject_names(j)) '*.IMA'];
            flist = dir(fullfile(readfile_dir, data.readfile_filter));
            nfiles = length(flist);
        end
        data.readfile_dir = fullfile(rootfile_dir, char(readfile_dirs(i)));
        if isvar('data.writefile_dir')
            data.writefile_dir_selected = data.writefile_dir;
        else
            data.writefile_dir_selected = data.readfile_dir;
        end
        if strcmp(data.retain_dicom,'yes') || strcmp(data.convert,'yes')
            data.scanlistonly = 'no';
        end
        dicom_sort_convert_main(data);
    end
end
