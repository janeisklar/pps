function select_sort_and_convert_Callback(obj,eventdata)

% clear the persistent workbar variables to set the time to zero in case it
% was quit
clear progfig progpatch starttime lastupdate % Clear persistent vars
clear workbar
warning('off','Images:genericDICOM');

if strcmp(obj,'no gui')
    data = eventdata;
else
    data = guidata(obj);
end

% reset some options for repeated sorts
data.reco_option = 'Not Set';
data.first_scan = 'yes';
data.warning_present = 'no';
data.write_an_extra_scanlist = 'no';
data.warning_text = '';
data.number_of_conversions_complete = 0;
data.conversion_time = 0;

if strcmp(data.writefile_dir_selected, 'not set') == 1
    errordlg('Select unsorted data directory with the "Select Unsorted DICOM Directory" button');
    return;
end

%   Find the number of operations to carry out
data.number_of_operations = 0;
if strcmp(data.convert,'yes')
    data.number_of_operations = data.number_of_operations + 1;
end
if strcmp(data.retain_dicom,'yes')
    data.number_of_operations = data.number_of_operations + 1;
end
if strcmp(data.scanlistonly,'yes')
    data.number_of_operations = data.number_of_operations + 1;
end

if strcmp(data.convert,'yes')
    tic
    data.current_conversion = 'convert';
    data = execute_sort_and_convert_Callback(data);
    data.conversion_time = secs2hms(toc);
    disp(['Conversion took ' data.conversion_time]);
    data.write_to_log = 'no';
end

if strcmp(data.retain_dicom,'yes')
    tic
    data.current_conversion = 'dicom';
    data = execute_sort_and_convert_Callback(data);
    data.sorting_time = secs2hms(toc);
    disp(['Dicom sorting took ' data.sorting_time]);
    data.write_to_log = 'no';
    if (data.number_of_operations == 1)
        data.write_an_extra_scanlist = 'yes';
    else
        data.write_an_extra_scanlist = 'no';
    end
end

if strcmp(data.scanlistonly,'yes') || strcmp(data.write_an_extra_scanlist, 'yes')
    tic
    data.current_conversion = 'list';
    data = execute_sort_and_convert_Callback(data);
    data.list_time = secs2hms(toc);
    data.write_to_log = 'no';
end

% close all open files, other than the scan log
fids = fopen('all');
for i = 1:numel(fids)
    if fids(i) ~= data.fp_scanlog
        try
            fclose(fids(i));
        catch
            disp('Warning: Couldn''t close all open file pointers');
        end
    end
end

switch data.test
    case 'yes'
    case 'no'
        tic
        if data.total_number_of_files > 0 && strcmp(data.scanlistonly,'no')
            data = tar_ima_func(data);
            if strcmp(data.ima_moved, 'yes') ~= 1 || strcmp(data.reports_moved, 'yes') ~= 1
                data = move_ima_func(data);
            end
        end
        disp(['Time to move files after sorting = ' secs2hms(toc)]);
        if strcmp(data.scanlistonly,'no')
            move_report_func(data);
        end
        disp(['Time to move files after sorting = ' secs2hms(toc)]);
end

if data.number_of_operations == 0;
    warndlg('No processing options selected.');
end

if data.number_of_operations >= 1;
    if strcmp(data.warning_present, 'yes')
        if (data.gui == 1)
            warndlg(sprintf('Important information about the scans has been written to scan_list.txt\n\n%s', data.warning_text));
        else
            sprintf('Important information about the scans has been written to scan_list.txt\n\n%s', data.warning_text);
        end
    end
end

fprintf(data.fp_scanlog, '..................................................\n');
summary_string = sprintf('*** Sorted with dicom_sort_convert version %s.', data.version_number);
summary_string = sprintf('%s \nKey:\nTE = echo time\nTR = repetition time\nTI = inversion time\nNR = number of repetitions\nFA = Flip Angle\nNF = number of files\nNE = number of echoes\nNGD = number of gradient directions (DTI)\nMC = Multi-Channel\nMP = magnitude and phase\nFS = FatSat pulse used\nEPI_f = EPI Factor\n', summary_string);
if strcmp(data.convert,'yes'); summary_string = sprintf('%s \nTime for conversion to NIfTI: %s. ', summary_string, data.conversion_time); end
if strcmp(data.retain_dicom,'yes'); summary_string = sprintf('%s \nTime for DICOM sorting and anonymisation: %s. ', summary_string, data.sorting_time); end
if strcmp(data.scanlistonly,'yes'); summary_string = sprintf('%s \nTime for creating a scan list: %s. ', summary_string, data.list_time); end
summary_string = sprintf('%s \nFinished @ %s ***\n', summary_string, datestr(now));

fprintf(data.fp_scanlog, '%s', summary_string);

if strcmp(data.warning_present, 'yes')
    fprintf(data.fp_scanlog, '\n\nThere were warnings or info\n');
    fprintf(data.fp_scanlog, '%s\n', data.warning_text);
end

fclose(data.fp_scanlog);
status = fclose('all');
if status ~= 0
    disp('Couldnt close some files');
end

if data.number_of_operations >= 1;
    if strcmp(data.current_conversion,'list')
        switch data.test
            case 'yes'
            case 'no'
                %clean up headers
                delete(fullfile(data.writefile_dir, '*_text_header.txt'));
                %if there's nothing else in the analyze directory, remove it
                analyze_dir_contents = dir(fullfile(data.writefile_dir, '*'));
                if length(analyze_dir_contents) <= 2
                    rmdir(data.writefile_dir,'s');
                end
        end
        if (strcmp(data.retain_dicom,'yes') ~= 1)  && data.gui == 1
            msgbox('Produced scan list');
        end
    elseif strcmp(data.retain_dicom,'yes') == 1 && strcmp(data.convert,'yes') == 1 && data.gui == 1
        msgbox(sprintf('Finished DICOM sorting and conversion\n\nThe Patient Name field has been\nremoved from dicom headers.\nFinal responsibility that no sensitive information \nis released from this lab lies with each researcher.\nPlease check that your data is anonymised.'));
    elseif strcmp(data.retain_dicom,'yes') == 1 && strcmp(data.convert,'no') == 1 && data.gui == 1
        msgbox(sprintf('Finished DICOM sorting\n\nThe Patient Name field has been\nremoved from dicom headers.\nFinal responsibility that no sensitive information \nis released from this lab lies with each researcher.\nPlease check that your data is anonymised.'));
    elseif strcmp(data.retain_dicom,'no') == 1 && strcmp(data.convert,'yes') == 1 && data.gui == 1
        msgbox('Finished conversion');
    end
end
warning('on','Images:genericDICOM');
warning on MATLAB:nonIntegerTruncatedInConversionToChar;
disp('***Finished***');