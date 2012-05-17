function reco_raw_data_func(obj,eventdata)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   reco_raw_data_func.m
%
%   Reconstructing raw Siemens data
%   Simon Robinson. 7. December. 2006
%
%   The raw data should be measured using the RHP tool
%   The files to be analysed here should be ???.IMA files
%   These files consist of four sections
%   1: A Dicom-like binary section, which is not in standard DICOM format
%       from byte byte_num_start_dcm_hd
%       to byte byte_num_end_dcm_hd
%   2: A Text header section, which is bounded by the comments
%       ### ASCCONV BEGIN ###
%       and
%       ### ASCCONV END ###
%       from byte_num_start_text_hd
%       to byte_num_end_text_hd
%   3: Things relating to EVA. There are a few binary lines before and
%   after the
%       beginning of the real <EVAProtocol>, but I'm putting this with the
%       EVA, so there are no bytes discarded if all sections available here
%       are written out
%       from byte_num_start_eva_hd
%       to byte_num_end_eva_hd
%   4: The binary image, preceded by "SIEMENS CSA NON-IMAGE "
%       from byte_num_start_fid
%       to byte_num_end_fid
%
%   Notes
%   1) Notepad can't interpret the line breaks in the text header.  Use
%   Wordpad to view
%
%   After reconstruction, the slices can be converted to a 3D data set,
%   either retaining or deleting the 2D data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global K magnitude_image phase_image

data = guidata(obj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

readfile_dir = data.readfile_dir;
writefile_dir = data.current_dir;

%Specify which files are to be left at the end

write_th='no'; %th=textheader
write_mag='yes'; %mag=magnitude image
write_phase='yes'; %phase=phase image
write_eva='no'; %eva=EVA information
write_fid='no'; %fid=fid=raw k-space data
write_dh='no'; %dh=dicomheader

n_bytes=8;
convert_to_3d = data.convert_to_3d;
remove2d='yes';
interleave_sort='yes';

%Establish information for the directory and a list of files

flist = data.fsublist;
nfiles = length(flist);
disp(sprintf('Found %d files in %s\n',nfiles,readfile_dir));
if(nfiles == 0)
    disp(sprintf('ERROR: no files in %s\n',readfile_dir));
    return;
end

%the main loop, over all the files in the directory

for n = 1:nfiles
    workbar(n/nfiles,['Reconstructing ' int2str(nfiles) ' images in scan series ' data.current_scan],'Reco Progress');
    readfile = fullfile(readfile_dir,flist(n).name);

    %define the writefiles : abbreviations
    %dh=dicomheader
    %th=textheader
    %fid=fid=raw k-space data
    %mag=magnitude image
    %phase=phase image
    
    writefile_dh=fullfile(writefile_dir,sprintf('Slice_%s_dh.txt', int2str(n)));
    writefile_th=fullfile(writefile_dir,sprintf('Slice_%s_th.txt', int2str(n)));
    writefile_eva=fullfile(writefile_dir,sprintf('Slice_%s_eva.txt', int2str(n)));
    writefile_fid=fullfile(writefile_dir,sprintf('Slice_%s_fid.nii', int2str(n)));

    switch data.convert_format
        case 'analyze'
        writefile_mag=fullfile(writefile_dir,sprintf('Slice_%s_mag', int2str(n)));
        writefile_phase=fullfile(writefile_dir,sprintf('Slice_%s_phase', int2str(n)));
        case  'nifti'
        writefile_mag=fullfile(writefile_dir,sprintf('Slice_%s_mag.nii', int2str(n)));
        writefile_phase=fullfile(writefile_dir,sprintf('Slice_%s_phase.nii', int2str(n)));
        otherwise 
        error('conversion type (data.convert_format) not recognised');
    end
    
    % Counters for
    % fis = "first instance of text header start"
    % fie = "first instance of text header end"
    % fisiem = "first instance of Siemens non-image label (beginning of FID)"
    % in case the text is also matched in the binary data. (it is!)

    fis=0;
    fie=0;
    fisiem=0;

    fid=fopen(readfile, 'r');

    %the byte numbers of the starts and ends of the file sections are
    %determined here

    byte_number_start_dcm_hd=0;

    if fid == -1
        error(['!!! Could not find ' readfile]);
    else
        while feof(fid) == 0
            pointer_position=ftell(fid);
            tline = fgetl(fid);
            %identify the beginning of the text header
            matches_start_th = findstr(tline, '### ASCCONV BEGIN ###');
            num_start_th = length(matches_start_th);
            %identify the end of the text header
            matches_end_th = findstr(tline, '### ASCCONV END ###');
            num_end_th = length(matches_end_th);
            if num_start_th > 0
                fis=fis+1;
                %only sets the start byte number if this is the first instance of
                %header comment begin
                if fis==1
                    %advance the pointer to the current line
                    pointer_position=ftell(fid);
                    byte_num_start_text_hd=pointer_position;
                    byte_num_end_dcm_hd=byte_num_start_text_hd-1;
                end
            end
            if num_end_th > 0
                fie=fie+1;
                if fie==1
                    %advance the pointer to the current line
                    pointer_position=ftell(fid);
                    byte_num_end_text_hd=pointer_position;
                    byte_num_start_eva_hd=byte_num_end_text_hd+1;
                end
            end
        end
    end

    %1) write the dicom header out

    if strcmp(write_dh, 'yes')
        fseek(fid, 0, 'bof');
        fp_dh=fopen(writefile_dh, 'w');
        dicom_hd=fread(fid, byte_num_start_text_hd);
        fwrite(fp_dh, dicom_hd);
        fclose(fp_dh);
    end

    %2) write out the text header ; fp=file pointer

    n_bytes_to_read=byte_num_end_text_hd-byte_num_start_text_hd;

    %get to the start of the text header
    fseek(fid, byte_num_start_text_hd, 'bof');
    fp_th=fopen(writefile_th, 'w');

    %cheat, write the opening line in (the real text comes at the end of a line of crap)
    fprintf(fp_th, '### ASCCONV BEGIN ### \n');

    current_fp_pos=0;
    while current_fp_pos < byte_num_end_text_hd
        %read a line in, write one out, and get the new file pointer pos.
        tline=fgets(fid);
        fprintf(fp_th, '%s', tline);
        current_fp_pos=ftell(fid);
    end
    fclose(fp_th);

    %Need to find out the size the fid should be first, by finding out the
    %dimensions of the image
    %Use the function search_text_header_func

    dim_readout = str2num(search_text_header_func(writefile_th, 'sKSpace.lBaseResolution'));
    dim_pe = str2num(search_text_header_func(writefile_th, 'sKSpace.lPhaseEncodingLines'));
    fid_size=dim_readout*dim_pe*n_bytes;

    %go to the end of the file to find how big it is
    fseek(fid, 0, 'eof');
    whole_file_size=ftell(fid);

    byte_num_start_fid=whole_file_size-fid_size;
    byte_num_end_eva_hd=byte_num_start_fid-1;

    %3) write out the eva header

    if strcmp(write_eva, 'yes')
        fseek(fid, byte_num_start_eva_hd, 'bof');
        fp_eva=fopen(writefile_eva, 'w');
        eva_hd=fread(fid, byte_num_end_eva_hd-byte_num_start_eva_hd);
        fwrite(fp_eva, eva_hd);
        fclose(fp_eva);
    end

    %4) write out the fid

    fseek(fid, byte_num_start_fid, 'bof');
    fp_fid=fopen(writefile_fid, 'w');
    raw_fid=fread(fid);
    fwrite(fp_fid, raw_fid);
    fclose(fp_fid);

    %Now do the reconstruction
    try
        reco_func(writefile_fid, dim_readout, dim_pe);
    catch
        disp('');
    end
    
    %Rotate
    %   for non-raw data this is done with process_one_slice_func.m
    try
        temp = imrotate(magnitude_image(:,:,1:end), 0);
        magnitude_image = (temp);
        temp = imrotate(phase_image(:,:,1:end), 0);
        phase_image = (temp);
        clear temp;
    catch
        error('could not rotate');
    end
     
    %write out the reconstructed data

    %   first get header parameters into the data structure
    guidata(obj,data);
    get_header_parameters(obj, eventdata);
    data = guidata(obj);

    %   magnitude
    data.current_analyze_struct = make_nii(magnitude_image);
    guidata(obj,data);
    make_analyze_header(obj, eventdata);
    data = guidata(obj);
    save_nii(data.current_analyze_struct, writefile_mag);

    %   phase (the header parameters are the same so don't change them
    data.current_analyze_struct = make_nii(phase_image);
    guidata(obj,data);
    make_analyze_header(obj, eventdata);
    data = guidata(obj);
    save_nii(data.current_analyze_struct, writefile_phase);
    
    fclose(fid);

    % get rid of unwanted files
    if strcmp(write_th, 'no')
        [status, result]=dos(['erase "' writefile_th '"']);
    end
    if strcmp(write_fid, 'no');
        [status, result]=dos(['erase "' writefile_fid '"']);
    end
end

% convert to 3d
if strcmp(convert_to_3d, 'yes');
    switch data.convert_format
        case 'analyze'
            convert_2dto3d_func2(obj, eventdata, interleave_sort, writefile_dir, 'Slice_', '_mag.img', 'Magnitude')
            convert_2dto3d_func2(obj, eventdata, interleave_sort, writefile_dir, 'Slice_', '_phase.img', 'Phase')
        case 'nifti'
            convert_2dto3d_func2(obj, eventdata, interleave_sort, writefile_dir, 'Slice_', '_mag.nii', 'Magnitude.nii')
            convert_2dto3d_func2(obj, eventdata, interleave_sort, writefile_dir, 'Slice_', '_phase.nii', 'Phase.nii')
    end
    if strcmp(remove2d, 'yes');
        for n = 1:nfiles
            delete (fullfile(writefile_dir,sprintf('Slice_%s_mag*', int2str(n))));
            delete (fullfile(writefile_dir,sprintf('Slice_%s_phase*', int2str(n))));
        end
    end
end

disp(sprintf('The measured matrix size was %i x %i', dim_readout, dim_pe));
disp(sprintf('The data were reconstructed to %i x %i, 32-bit floats (reals)', dim_readout, dim_readout));
disp('*** Finished ***');

%finished

