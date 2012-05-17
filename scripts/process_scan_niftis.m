function process_scan_niftis( scanDir )
%Checks the presence of a all niftis or coverts them otherwise

addpath('lib');

data = struct();
data.current_conversion             = 'convert';
data.readfile_dir                   = '/Users/andre/Studium/Master/Master Semester 2/fMRI Project/Preprocessing/pps12/subjects/clu12-p020/7t/scan_0005/dicom';
data.convert_format                 = 'nifti';
data.writefile_dir_selected         = '/Users/andre/Studium/Master/Master Semester 2/fMRI Project/Preprocessing/pps12/subjects/clu12-p020/7t/scan_0005/';
data.default_startpath              = data.writefile_dir_selected;
data.readfile_filter                = '*.ima';
data.define_writefile_subdir        = 'no';
data.scanlistonly                   = 'no';
data.first_scan                     = 'yes';
data.anonymise                      = 'no';
data.warning_text                   = '';
data.workbar_off                    = 'no';
data.number_of_conversions_complete = 0;
data.features                       = '';

execute_sort_and_convert_Callback(data)

end