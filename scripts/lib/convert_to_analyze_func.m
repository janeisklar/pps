function data = convert_to_analyze_func(data)

warning off MATLAB:nonIntegerTruncatedInConversionToChar;

fsublist = data.fsublist;
nfiles = length(fsublist);
data.current_nfiles = nfiles;

readfile_dir = data.readfile_dir;
writefile_dir = data.current_dir;

if strcmp(data.convert_format, 'analyze')
    writefile_4d_img = fullfile(writefile_dir,'Image.img');
    writefile_4d_hdr = fullfile(writefile_dir,'Image.hdr');
end
if strcmp(data.convert_format, 'nifti')
    writefile_4d_nii = fullfile(writefile_dir,'Image.nii');
end

% get info out of the first DICOM header
data.current_readfile_example=fullfile(readfile_dir,fsublist(1).name);
[res, dcminfo] = isdicomfile(data.current_readfile_example);
data.current_dcminfo = dcminfo;

if strcmp(dcminfo.Private_0029_10xx_Creator,'SIEMENS CSA NON-IMAGE') == 1
    data.current_header_pars.raw_flag = 'raw';
else
    data.current_header_pars.raw_flag = 'not raw';
end

%   write a header for the first file in the series
switch data.current_conversion
    case 'list'
        s = warning ('query', 'MATLAB:MKDIR:DirectoryExists') ;	    % get current state
        warning ('off', 'MATLAB:MKDIR:DirectoryExists') ;
        mkdir(data.writefile_dir);
        warning (s) ;						    % restore state
        data.current_writefile_th=fullfile(data.writefile_dir, sprintf('%s_text_header.txt', data.current_scan));
    otherwise
        data.current_writefile_th=fullfile(data.current_dir, 'text_header.txt');
end
write_dcm_text_header(fullfile(readfile_dir, char(fsublist(1).name)), data.current_writefile_th);

% check DICOM and if raw data, whether to reconstruct
if res ~= 1
    errordlg([data.current_readfile_example ' is not a DICOM file']);
    return;
end

%   Replacement for raw data reco options below - now just get the hell out
%   of there
if (strcmp(dcminfo.Private_0029_10xx_Creator,'SIEMENS CSA NON-IMAGE') == 1)
    data.raw_data = 'yes';
    return;
else
    data.raw_data = 'no';
end
%   No-one is using raw data saved with the RHP tool - leave in case needed
%   in the future
%     if (strcmp(dcminfo.Private_0029_10xx_Creator,'SIEMENS CSA NON-IMAGE') == 1) && (strcmp(data.scanlistonly, 'yes') ~= 1)
%         if strcmp(data.reco_option,'Reconstruct All Raw Scans') ~= 1
%                  data.reco_option = questdlg(['Scan ' data.current_scan  ' appears to be raw data - do you want to'], ...
%                 'Raw Data Alert!',...
%                 'Reconstruct All Raw Scans',...
%                 'Reconstruct This Scan',...
%                 'Do not reconstruct',...
%                 'Reconstruct All Raw Scans');
%         end
%         data.slice_reorder = 'yes';
%         data.raw_data = 'yes';
%         guidata(obj,data);
%         switch data.reco_option
%             case 'Reconstruct All Raw Scans'
%                 data.convert_to_3d = 'yes';
%             case 'Reconstruct This Scan'
%                 data.convert_to_3d = 'yes';
%             case 'Do not reconstruct'
%                 get_header_parameters(data);
%                 write_scan_details(data);
%                 return;
%         end
%     else
%         data.raw_data = 'no';
%     end
% end

%   write dcminfo to text header file
data.writefile_th_fp = fopen(data.current_writefile_th, 'a');
dump_struct_func(data.current_readfile_example, data.writefile_th_fp, data.anonymise);

%   Finish here is only a scan list is wanted
if strcmp(data.current_conversion, 'list')
    data = get_header_parameters(data);
    write_scan_details(data);
    return;
end

%   Reconstruct data and finish for this scan if this is raw data
if (strcmp(dcminfo.Private_0029_10xx_Creator,'SIEMENS CSA NON-IMAGE') == 1) && ((strcmp(data.reco_option, 'Reconstruct All Raw Scans') == 1) || (strcmp(data.reco_option, 'Reconstruct This Scan') == 1))
    data = get_header_parameters(data);
    reco_raw_data_func(data);
    return;
end

%   get header parameters into the data structure
data = get_header_parameters(data);

%   if this is time-series data with separate channels, the file order could be fv*#!ed - need to go through the DICOM info AcquisitionNumber
if strcmp(data.current_header_pars.sep_channels,'yes') && (data.current_header_pars.dim_nr > 1)
    %disp('  -  scan is separate channel time-series - checking the order of files in the series');
    %data = deep_sort(data);
end
    

fclose(data.writefile_th_fp);

%   write scan parameters to log
write_scan_details(data)

%   get an example image
example_image = dicomread(data.current_readfile_example);

%   convert (mosaic to 3D if necc., swap dimensions, rotate) one slice

data.first_image_in_series = 'yes';
data = process_one_slice_func(data, example_image);
data.first_image_in_series = 'no';
vol = data.vol;

data.current_analyze_struct = make_nii(vol);

%   create an analyze structure for the example image
%   this will be used to set the header parameters
data = make_analyze_header(data);
analyze_struct = data.current_analyze_struct;
precision = data.current_precision;

%write the header to Analyze
if strcmp(data.convert_format, 'analyze')
    fp_writefile_4d_hdr = fopen(writefile_4d_hdr, 'w');
    analyze_struct.hdr.dime.vox_offset = 0;
    analyze_struct.hdr.hist.magic = 'ni1';
    save_nii_hdr(analyze_struct.hdr, fp_writefile_4d_hdr);
    fclose(fp_writefile_4d_hdr);
    fp_writefile_4d_img = fopen(writefile_4d_img, 'w');
    %  So earlier versions of SPM can also open it with correct originator
    %
    M=[[diag(analyze_struct.hdr.dime.pixdim(2:4)) -[analyze_struct.hdr.hist.originator(1:3).*analyze_struct.hdr.dime.pixdim(2:4)]'];[0 0 0 1]];
    save(strrep(writefile_4d_hdr,'.hdr',''), 'M');
end

if strcmp(data.convert_format, 'nifti')
    %make changes to nifti header here
    analyze_struct.hdr.dime.glmax = round(double(max(analyze_struct.img(:))));
    analyze_struct.hdr.dime.glmin = round(double(min(analyze_struct.img(:))));
    analyze_struct.hdr.dime.vox_offset = 352;
    analyze_struct.hdr.hist.magic = 'n+1';

    %write the header to nifti
    fp_writefile_4d_nii = fopen(writefile_4d_nii, 'w');
    save_nii_hdr(analyze_struct.hdr, fp_writefile_4d_nii);
    skip_bytes = double(analyze_struct.hdr.dime.vox_offset) - 348;
    if skip_bytes
        fwrite(fp_writefile_4d_nii, ones(1,skip_bytes), 'uint8');
    end
end


for n = 1:nfiles
    if strcmp(data.workbar_off,'no')
        workbar((data.number_of_conversions_complete)/data.total_number_of_files, ['Converting ' int2str(nfiles) ' files in scan series ' data.current_scan], 'Overall Progress');
    end
    readfile = fullfile(readfile_dir,fsublist(n).name);
    data.current_readfile = readfile;
    try
        single_image = dicomread(readfile);
    catch
        error(['Error reading ' readfile]);
    end
    if size(single_image,1)==0
        disp('');
    end
    %   convert (mosaic to 3D if necc., swap dimensions, rotate) one slice
    data = process_one_slice_func(data, single_image);
    vol = data.vol;
    whos_vol = whos('vol');
    if strcmp(data.convert_format, 'analyze')
        count = fwrite(fp_writefile_4d_img, vol, precision);
    end
    if strcmp(data.convert_format, 'nifti')
        count = fwrite(fp_writefile_4d_nii, vol, precision);
    end    
    if count ~= whos_vol.bytes/2
        %error('Some data not written');
    end
    data.number_of_conversions_complete = data.number_of_conversions_complete + 1;
    if strcmp(data.workbar_off,'no')
        if n == nfiles
            workbar((data.number_of_conversions_complete)/data.total_number_of_files, ['Converting ' int2str(nfiles) ' files in scan series ' data.current_scan], 'Overall Progress');
        end
    end
end

switch data.convert_format
    case 'analyze'
        fclose(fp_writefile_4d_img);
    case 'nifti'
        fclose(fp_writefile_4d_nii);
end

switch data.convert_format
    case {'analyze','nifti'}
        %   The data has now all been written.  The next function allows it to be
        %   reformatted, depending on the scan type.
        if strcmp(data.features, 'Advanced')
            data = reformat_data_func(data);
        end
end
%useful breakpoint
disp('');