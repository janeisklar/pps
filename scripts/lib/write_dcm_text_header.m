function write_dcm_text_header(dicom_readfile, writefile_th)

fid=fopen(dicom_readfile, 'r');

%the byte numbers of the starts and ends of the file sections are
%determined here

fis = 0;
fie=0;

begin_search_for_endstring = 'no';
num_end_th = 0;

while feof(fid) == 0
    pointer_position=ftell(fid);
    tline = fgetl(fid);
    %identify the beginning of the text header
    matches_start_th = strfind(tline, '### ASCCONV BEGIN ###');
    num_start_th = length(matches_start_th);
    %identify the end of the text header
    if num_start_th > 0
        begin_search_for_endstring = 'yes';
    end
    if strcmp(begin_search_for_endstring, 'yes')
        matches_end_th = strfind(tline, '### ASCCONV END ###');
        num_end_th = length(matches_end_th);
    end
    if num_start_th > 0
        fis=fis+1;
        %only sets the start byte number if this is the first instance of
        %header comment begin
        if fis==1
            %advance the pointer to the current line
            pointer_position=ftell(fid);
            byte_num_start_text_hd=pointer_position;
            %break;
        end
    end
    if num_end_th > 0
        fie=fie+1;
        if fie==1
            %advance the pointer to the current line
            pointer_position=ftell(fid);
            byte_num_end_text_hd=pointer_position;
        end
    end
end

% write out the text header ; fp=file pointer

n_bytes_to_read=byte_num_end_text_hd-byte_num_start_text_hd;

%get to the start of the text header
fseek(fid, byte_num_start_text_hd, 'bof');
fp_th=fopen(writefile_th, 'w');

%cheat, write the opening line in (the real text comes at the end of a line of crap)
try
    fprintf(fp_th, '### ASCCONV BEGIN ### \n');
catch
    disp('');
end

current_fp_pos=0;
while current_fp_pos < byte_num_end_text_hd
    %read a line in, write one out, and get the new file pointer pos.
    tline=fgets(fid);
    fprintf(fp_th, '%s', tline);
    current_fp_pos=ftell(fid);
end
fclose(fp_th);

