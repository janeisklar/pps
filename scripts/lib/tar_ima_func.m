function data = tar_ima_func(data)

flist = data.flist;
readfile_dir = data.readfile_dir;
anon_subdir = data.anon_subdir;
writefile_dir_selected = data.writefile_dir_selected;
delete_data_asat = data.delete_data_asat;

%set a subdirectory, or not
switch data.define_writefile_subdir
    case 'yes'
        fn_ima_tar = fullfile(writefile_dir_selected, anon_subdir, 'ima.tar.gz');
        fn_report_tar = fullfile(writefile_dir_selected, anon_subdir, 'report.tar.gz');
    otherwise
        fn_ima_tar = fullfile(writefile_dir_selected, 'ima.tar.gz');
        fn_report_tar = fullfile(writefile_dir_selected, 'report.tar.gz');
end

switch delete_data_asat % (asat = after sorting and tarring)
    case 'yes'
        ima_tar_command = sprintf('tar cvfz %s %s/*IMA --remove-files',  fn_ima_tar, readfile_dir);
        report_tar_command = sprintf('tar cvfz %s %s/REPORT* --remove-files',  fn_report_tar, readfile_dir);
    case 'no'
        ima_tar_command = sprintf('tar cvfz %s %s/*IMA ',  fn_ima_tar, readfile_dir);
        report_tar_command = sprintf('tar cvfz %s %s/REPORT* ',  fn_report_tar, readfile_dir);
end
[status, result] = unix(ima_tar_command);
if status == 0
    disp(['IMA files tarred and zipped to ' fn_ima_tar ]);
    data.ima_moved = 'yes';
else
    if numel(strfind(result, 'Argument list too long')) ~=0
        flist = data.flist;
        ima_dump_dir = fullfile(data.writefile_dir_selected, 'ima_to_delete');
        mkdir(ima_dump_dir);
        nfiles = data.total_number_of_files;
        disp(['Argument list was too long - moving IMA files to ' ima_dump_dir ' first']);
        for n = 1:nfiles
            source_dicom_file = fullfile(data.readfile_dir, flist(n).name);
            destination_dicom_file = fullfile(ima_dump_dir, flist(n).name);
            try
                movefile(source_dicom_file, destination_dicom_file);
            catch
                disp(['Couldn''t move '  source_dicom_file]);
            end
            data.ima_dump_dir = ima_dump_dir;
        end
        disp('Done');
        disp(['Tarring and zipping IMA files to ' fn_ima_tar ]);
        ima_tar_command = sprintf('tar cvfz %s %s --remove-files',  fn_ima_tar, ima_dump_dir);
        [status, result] = unix(ima_tar_command);
        if status == 0
            disp(['IMA files tarred and zipped to ' fn_ima_tar]);
            data.ima_moved = 'yes';
        else
            disp(['Couldn''t tar and zip IMA, trying to move instead']);
            data.ima_moved = 'no';
        end
    end
    disp(['Couldn''t tar and zip IMA, trying to move instead']);
    data.ima_moved = 'no';
end
report_files = dir(sprintf('%s/REPORT*'));
n_reports = numel(report_files);
switch n_reports
    case 0
        data.reports_moved = 'yes';
    otherwise
        [status, result] = unix(report_tar_command);
        if status == 0
            disp(['REPORT files tarred and zipped to ' fn_report_tar ]);
            data.reports_moved = 'yes';
        else
            disp(['Couldn''t tar and zip REPORT files, trying to move instead']);
            data.reports_moved = 'no';
        end
end
