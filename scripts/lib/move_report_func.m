function move_report_func(data)

flist = dir(fullfile(data.readfile_dir,'REPORT*'));
destination_dir = fullfile(data.writefile_dir, '../report');
mkdir(destination_dir);
nfiles = length(flist);
if nfiles ~=0
    disp(['Moving REPORT files to ' destination_dir]);
    for n = 1:nfiles
        source_report_file = fullfile(data.readfile_dir, flist(n).name);
        destination_report_file = fullfile(destination_dir, flist(n).name);
        try
            movefile(source_report_file, destination_report_file);
        catch
            disp(['Couldn''t move '  source_report_file]);
        end
    end
    disp('Done')
end
