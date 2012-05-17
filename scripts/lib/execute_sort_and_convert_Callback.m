function data = execute_sort_and_convert_Callback(data)

%whether the conversion is carried out or not depends on the parameter
%data.current_conversion = 'dicom';
%data.current_conversion = 'convert'
%data.current_conversion = 'list';

readfile_dir = data.readfile_dir;
writefile_dir_selected = data.writefile_dir_selected;
default_startpath = data.default_startpath;
data.not_one_series_option = 'Not Set';

%if no output directory is selected (it is still == default), set the
%output directory to be the readfile_dir
if strcmp(writefile_dir_selected, default_startpath) ==1
    writefile_dir_selected = readfile_dir;
end

% get the directory contents
flist = dir(fullfile(readfile_dir,data.readfile_filter));
nfiles = length(flist);
data.total_number_of_files = nfiles;

if(nfiles == 0)
    warndlg(sprintf('No %s files in %s\n', data.readfile_filter, readfile_dir), 'dlgname');
    return;
end

% get the subject ID and accession number from any scan in the series to
% make a new directory name

[res, dcminfo] = isdicomfile(fullfile(readfile_dir,flist(1).name));
if strcmp(dcminfo.PatientID, 'Anonymous') ~= 1
    anon_subdir = [strip_banned_characters_func(dcminfo.PatientID) '_' strip_banned_characters_func(dcminfo.AccessionNumber)];
else
    anon_subdir = strip_banned_characters_func(dcminfo.PatientID);
end
data.anon_subdir = anon_subdir;

%set a subdirectory, or not
switch data.define_writefile_subdir
    case 'yes'
        writefile_dir_stem = fullfile(writefile_dir_selected, anon_subdir);
    otherwise
        writefile_dir_stem = writefile_dir_selected;
end

%set the dicom directory always to be called dicom
switch data.current_conversion
    case 'dicom'
        writefile_dir = fullfile(writefile_dir_stem, 'dicom') ;
    case 'convert'
        switch data.convert_format
            case {'analyze','nifti'}
                writefile_dir = fullfile(writefile_dir_stem, 'nifti') ;
            otherwise
                error('Convert format could not be determined');
        end
    case 'list'
        writefile_dir = fullfile(writefile_dir_stem, 'list') ;
    otherwise
        error('Current conversion could not be determined');
end
data.writefile_dir = writefile_dir;

try
    s = warning ('query', 'MATLAB:MKDIR:DirectoryExists') ;	    % get current state
    warning ('off', 'MATLAB:MKDIR:DirectoryExists') ;
    mkdir(writefile_dir);
    warning (s) ;						    % restore state
catch
    errordlg(['You do not have permission to write to ' data.writefile_dir ' , use the "Select Destination Directory" to choose a folder where you may write']);
end

%Need to establish the form of the filename - how many full stops before
%the scan number?

%   See if the anonymise parameter is set
try
    switch dcminfo.DerivationDescription
        case 'Force Anonymity'
            nfullstopsoffset = 0;
        otherwise
            nfullstopsoffset = 1;
    end
catch
    nfullstopsoffset = 1;
end

data.nfullstopsoffset = nfullstopsoffset;

disp(['Processing files in ' data.readfile_dir]);
disp('Checking all files belong to the same subject and series...');
subject_name = get_dicom_fieldname_func(flist(1).name, 0);
series_name = get_dicom_fieldname_func(flist(1).name, nfullstopsoffset+10);
for n = 1:nfiles
    %check its the same subject
    current_subject_name = get_dicom_fieldname_func(flist(n).name, 0);
    data.current_subject_name = current_subject_name;
    if strcmp(subject_name, current_subject_name) ~= 1
        errordlg(sprintf('Not all images to be sorted belong to the same subject \nSeparate before sorting'), 'dlgname');
        return;
    end
    %check its the same series
    current_series_name = get_dicom_fieldname_func(flist(n).name, nfullstopsoffset+10);
    data.current_series_name = current_series_name;

    if strcmp(series_name, current_series_name) ~= 1
        if (strcmp(data.not_one_series_option, 'Stop and separate the data into separate directories') ~= 1 && strcmp(data.not_one_series_option, 'Continue') ~= 1)
            data.not_one_series_option = questdlg(sprintf('All images to be sorted belong to the same subject, \nbut are not in the same export series \nThis could arise from exporting\ntwo parts of a session separately\nbut could also indicate multiple versions of the same data, \nwhich will lead to the data becoming mixed. \n\nDo you want to'), ...
                'Mixed Series Alert', ...
                'Stop and separate the data into separate directories', ...
                'Continue', ...
                'Stop and separate the data into separate directories');
            switch data.not_one_series_option
                case 'Stop and separate the data into separate directories'
                    return;
                case 'Continue'
            end
        end
    end
end
disp('Done');


%sort by scan number, which is field number 3 (anon), 4 (norm)
disp('Sorting by scan number ...');
flist = sortlist_func2(flist, nfullstopsoffset+2);
disp('Done');

%create a list of the scan names
scan_names=cell(nfiles,1);
for n = 1:nfiles
    %for VB17, need to remove leading '0's (cheat by going to int and back to cell)
    scan_names(n) = cellstr(num2str(str2num(get_dicom_fieldname_func(flist(n).name, nfullstopsoffset+2))));
end

%sort by image number, which is field number 4 (anon), 5 (norm)
disp('Sorting scans by image number ...');
int_scan_names = str2num(char(scan_names));
first_scan = min(int_scan_names(:));
last_scan = max(int_scan_names(:));
for n = first_scan: last_scan
    files_in_scan_series = find(int_scan_names(:)==n);
    if length(files_in_scan_series) > 1
        flist(files_in_scan_series) = sortlist_func2(flist(files_in_scan_series), nfullstopsoffset+3);
    end
end
data.flist = flist ;
disp('Done');


for n = 1:nfiles
    %if this is the first file with this scan number, make a new directory
    %and calls the conversion for this list
    if (n == 1)
        new_scan = 'yes';
    else
        if strcmp(char(scan_names(n)),char(scan_names(n-1))) ~= 1
            new_scan = 'yes';
        else
            new_scan = 'no';
            image_counter = image_counter+1;
        end
    end
    current_scan = char(scan_names(n));
    data.current_scan = current_scan;

    flist_IX = find(int_scan_names(:)==str2num(current_scan));
    data.fsublist = data.flist(flist_IX);

    n_files_in_series = length(data.fsublist);

    switch data.scanlistonly
        case 'no'
        case 'yes'
            if strcmp(data.workbar_off,'no')
                workbar(n/nfiles, ['Processing ' int2str(n_files_in_series) ' files in scan series ' data.current_scan], 'Overall Progress');
            end
    end

    % open log file and set a parameter to decide which things to write to file log
    if strcmp(data.first_scan,'yes') == 1
        scanlistfile = fullfile(writefile_dir_stem,'scan_list.txt');
        data.fp_scanlog = fopen(scanlistfile, 'w');
        if data.fp_scanlog == -1
            errordlg('Can''t write to scan log in this directory: Select output directory with the "Select Destination Directory" button');
        end
        data.write_to_log = 'yes';
        data.current_dir = fullfile(writefile_dir, current_scan);
        write_introductory_comments(data);
        data.first_scan = 'no';
    end

    if strcmp(new_scan,'yes')
        disp(['Scan ' data.current_scan ': processing ' int2str(n_files_in_series) ' files in series ']);
        current_dir = fullfile(writefile_dir, current_scan);
        data.current_dir = current_dir;
        if strcmp(data.current_conversion, 'list') ~=1
            s = warning ('query', 'MATLAB:MKDIR:DirectoryExists') ;	    % get current state
            warning ('off', 'MATLAB:MKDIR:DirectoryExists') ;
            mkdir(current_dir);
            warning (s) ;						    % restore state
        end
        image_counter = 1;
        if strcmp(data.current_conversion, 'convert') || strcmp(data.current_conversion, 'list')
            %   need to update the dcminfo in case this isn't really a scan at
            %   all
            [res, dcminfo] = isdicomfile(fullfile(readfile_dir,flist(n).name));
            if isvar('dcminfo.DerivationDescription')
                if strcmp(dcminfo.DerivationDescription, 'MEDCOM RESAMPLED')
                    fprintf(data.fp_scanlog, 'Scan %s: MEDCOM RESAMPLED; not processing\n', current_scan);
                    continue;
                end
            end

            %   can pick other types of sequences not to convert
            if isvar('dcminfo.ProtocolName')
                switch dcminfo.ProtocolName
                    case 'one hour delay fid'
                        fprintf(data.fp_scanlog, 'Scan %s: 1 hour pause; not processing\n', current_scan);
                    case 'svs_se_270'
                        fprintf(data.fp_scanlog, 'Scan %s: spectroscopy sequence; not processing\n', current_scan);
                        this_warning_text = sprintf('Scan %s was a spectroscopy sequence and was not processed\n', current_scan);
                        data.warning_present = 'yes';
                        data.warning_text = sprintf('%s %s', data.warning_text, this_warning_text);
                        continue;
                end
            end
            if isvar('dcminfo.SeriesDescription')
                switch dcminfo.SeriesDescription
                    case 'StartFMRI'
                        fprintf(data.fp_scanlog, 'Scan %s: Dummy scan StartFMRI; not processing\n', current_scan);
                        continue;
                    case 'intermediate t-Map'
                        fprintf(data.fp_scanlog, 'Scan %s: ; intermediate t-Map; not processing\n', current_scan);
                        continue;
                    case 'Design'
                        fprintf(data.fp_scanlog, 'Scan %s: ; fMRI Design matrix; not processing\n', current_scan);
                        continue;
                end
            end
            data.current_readfile_stem = get_readfile_stem_func(flist(n).name, current_scan);
            data = convert_to_analyze_func(data);
            try
                fclose(data.writefile_th_fp);
            catch
            end
        end
    end

    % Now for DICOM sorting: read, anonymise, rename and write the file
    if strcmp(data.current_conversion, 'dicom')
        if strcmp(data.workbar_off,'no')
            workbar(n/nfiles, ['Sorting DICOM data, ' int2str(n_files_in_series) ' files in scan series ' data.current_scan], 'Overall Progress');
        end
        writefile_name = ('Image0000.dcm');
        try
            writefile_name(10-ceil(log10(image_counter+1)):9)=int2str(image_counter);
        catch
            errordlg('Cannot attribute filename: Are there more than 9999 files in this scan?', 'dlgname');
        end
        readfile_dcm = fullfile(readfile_dir, flist(n).name);
        writefile_name_full = fullfile(current_dir, writefile_name);
        %   try to read the image and get the header info
        try
            dcm_header = dicominfo(readfile_dcm);
            dcm_image = dicomread(readfile_dcm);
        catch
            error(['Could not read ' readfile_dcm]);
        end
        if (strcmp(new_scan,'yes') && (data.number_of_operations == 1))
            disp('');
        end
        switch data.anonymise
            case 'yes'
                version_number = version;
                if ((size(findstr(version_number, '(R2006b)'),1) ~= 0) || size(findstr(version_number, '(R2007a)'),1) ~= 0 || (size(findstr(version_number, '(R2007b)'),1) ~= 0) || (size(findstr(version_number, '(R2008a)'),1) ~= 0) || (size(findstr(version_number, '(R2008b)'),1) ~= 0) || (size(findstr(version_number, '(R2009a)'),1) ~= 0) )
                    %                     %   NEW STYLE ANONIMISATION
                    %                     % get dicom info for first image in scan - leave InstanceNumber because it's not the same for every scan in the series
                    if (strcmp(dcm_header.Private_0029_10xx_Creator,'SIEMENS CSA NON-IMAGE') ~= 1)
                        if strcmp(new_scan,'yes')
                            if strcmp(data.first_scan,'yes')
                                disp('Doing new style DICOM anon');
                                data.first_scan = 'no';
                            end
                            [res, dcminfo] = isdicomfile(fullfile(readfile_dir,flist(n).name));
                            if isvar('dcm_header.PatientName') ; values.PatientName = 'Anonymised by dicom_sort_convert'; end
                            if isvar('dcm_header.PatientID') ; values.PatientID = dcm_header.PatientID; end
                            if isvar('dcm_header.AccessionNumber'); values.AccessionNumber = dcm_header.AccessionNumber; end
                            if isvar('dcm_header.InstitutionAddress'); values.InstitutionAddress = dcm_header.InstitutionAddress;  end
                            if isvar('dcm_header.InstitutionName'); values.InstitutionName = dcm_header.InstitutionName; end
                            if isvar('dcm_header.StationName') ; values.StationName = dcm_header.StationName; end
                            if isvar('dcm_header.StudyDescription'); values.StudyDescription = dcm_header.StudyDescription; end
                            if isvar('dcm_header.SeriesDescription'); values.SeriesDescription = dcm_header.SeriesDescription; end
                            if isvar('dcm_header.PerformingPhysicianName'); values.PerformingPhysicianName = dcm_header.PerformingPhysicianName; end
                            if isvar('dcm_header.OperatorName'); values.OperatorName = dcm_header.OperatorName; end
                            if isvar('dcm_header.PatientBirthDate'); values.PatientBirthDate = dcm_header.PatientBirthDate; end
                            if isvar('dcm_header.PatientSex'); values.PatientSex = dcm_header.PatientSex; end
                            if isvar('dcm_header.PatientAge'); values.PatientAge = dcm_header.PatientAge; end
                            if isvar('dcm_header.PatientWeight'); values.PatientWeight = dcm_header.PatientWeight; end
                            if isvar('dcm_header.PatientComments'); values.PatientComments = dcm_header.PatientComments; end
                            if isvar('dcm_header.DeviceSerialNumber'); values.DeviceSerialNumber = dcm_header.DeviceSerialNumber; end
                            if isvar('dcm_header.ProtocolName'); values.ProtocolName = dcm_header.ProtocolName; end
                            if isvar('dcm_header.StudyInstanceUID'); values.StudyInstanceUID = dcm_header.StudyInstanceUID; end
                            if isvar('dcm_header.SeriesInstanceUID'); values.SeriesInstanceUID = dcm_header.SeriesInstanceUID; end
                            if isvar('dcm_header.StudyID'); values.StudyID = dcm_header.StudyID; end
                            if isvar('dcm_header.AcquisitionNumber'); values.AcquisitionNumber = dcm_header.AcquisitionNumber; end
                            %                     if isvar('dcm_header.InstanceNumber'); values.InstanceNumber = dcm_header.InstanceNumber; end
                            if isvar('dcm_header.FrameOfReferenceUID'); values.FrameOfReferenceUID = dcm_header.FrameOfReferenceUID ; end
                            %     values.Private_0029_10xx_Creator = dcm_header.Private_0029_10xx_Creator;
                            %     values.Private_0029_11xx_Creator = dcm_header.Private_0029_11xx_Creator;
                            %     values.Private_0029_12xx_Creator = dcm_header.Private_0029_12xx_Creator;
                            %     values.Private_0029_1008 = dcm_header.Private_0029_1008;
                            %     values.Private_0029_1009 = dcm_header.Private_0029_1009;
                            %     values.Private_0029_1018 = dcm_header.Private_0029_1018;
                            %     values.Private_0029_1019 = dcm_header.Private_0029_1019;
                            %     values.Private_0029_1131 = dcm_header.Private_0029_1131;
                            %     values.Private_0029_1132 = dcm_header.Private_0029_1132;
                            %     values.Private_0029_1133 = dcm_header.Private_0029_1133;
                            %     values.Private_0029_1134 = dcm_header.Private_0029_1134;
                            %     values.Private_0029_1260 = dcm_header.Private_0029_1260;
                        end
                        dicomanon(readfile_dcm, writefile_name_full, 'update', values);
                    end
                elseif (size(findstr(version_number, '(R2006a)'),1) ~= 0) %(size(findstr(version_number, '(R2007a)'),1) ~= 0 || (size(findstr(version_number, '(R2006b)'),1) ~= 0))%
                    %   OLD STYLE ANONIMISATION
                    disp('Doing old style DICOM anon');
                    if (strcmp(dcm_header.Private_0029_10xx_Creator,'SIEMENS CSA NON-IMAGE') ~= 1)
                        dcm_header.PatientName = 'Anonymised by dicom_sort_convert';
                        end_of_string_marker = strfind(dcm_header.Filename, '.MR.');
                        dcm_header.Filename = ['ANONYMISED' dcm_header.Filename(end_of_string_marker:end)];
                        if length(end_of_string_marker) == 0;
                            dcm_header.Filename = ['ANONYMISED:couldnt_sep_filestring'];
                        end
                        try
                            dicomwrite(dcm_image, writefile_name_full, dcm_header);
                        catch
                            disp('');
                        end
                        if n==1
                            this_warning_text = sprintf('If you plan to use DICOM images with Brain Voyager\nyou will need to run\nthis program with MATLAB 2006b or later\nYou are using %s.', version_number);
                            data.warning_text = sprintf('%s %s', data.warning_text,this_warning_text);
                            data.warning_present = 'yes';
                        end
                    end
                else
                    error(['Do not know what to do for anonimisation in version ' version]);
                end
            case 'no'
                if (strcmp(data.first_scan,'yes'))
                    button = questdlg('This data will not be anonymised: do you want to continue', ...
                        'Anonymisation Alert!',...
                        'continue',...
                        'stop',...
                        'stop');
                    if strcmp(button,'continue')
                        error('Not anonymising data not allowed');
                        %dicomwrite(dcm_image, writefile_name_full, dcm_header);
                        this_warning_text = '!!!Warning!!! Data has not been anonymised';
                        data.warning_present = 'yes';
                        data.warning_text = sprintf('%s \n%s', data.warning_text, data.current_scan, this_warning_text);
                    end
                end
        end
    end
end

disp('');
