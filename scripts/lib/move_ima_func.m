function data = move_ima_func(data)

flist = data.flist;
ima_dump_dir = fullfile(data.writefile_dir_selected, 'ima_to_delete');
mkdir(ima_dump_dir);
nfiles = data.total_number_of_files;
disp(['Moving IMA files to ' ima_dump_dir]);
for n = 1:nfiles
    if (data.gui == 1)
        workbar((n)/nfiles, ['Moving ' int2str(nfiles) ' files to ' ima_dump_dir], 'Progress');
    end
    source_dicom_file = fullfile(data.readfile_dir, flist(n).name);
    destination_dicom_file = fullfile(ima_dump_dir, flist(n).name);
    try
        movefile(source_dicom_file, destination_dicom_file);
    catch
        disp(['Couldn''t move '  source_dicom_file]);
    end
    data.ima_dump_dir = ima_dump_dir;
end
disp('Done')
