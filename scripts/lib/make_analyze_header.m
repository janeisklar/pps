function data = make_analyze_header(data)

nfiles = data.current_nfiles;
dcminfo = data.current_dcminfo;
mosaic_flag = data.current_mosaic_flag;

%   voxel size
dim_FOV_read = data.current_header_pars.dim_FOV_read;
dim_VS_read = data.current_header_pars.dim_VS_read;
dim_FOV_phase = data.current_header_pars.dim_FOV_phase;
dim_VS_phase = data.current_header_pars.dim_VS_phase;
dim_slice_thick = data.current_header_pars.dim_slice_thick;

%   matrix size
dim_phase = data.current_header_pars.dim_phase;
dim_read = data.current_header_pars.dim_read;
dim_nslices = data.current_header_pars.dim_nslices;
orientation = data.current_header_pars.orientation;

analyze_struct = data.current_analyze_struct;

%   name

analyze_struct.hdr.hist.descrip = data.current_header_pars.sequence_type;

% all data encountered so far was int16 - see save_nii.m  and below for datatypes
% corresponding to precisions.  These can all be written.
analyze_struct.hdr.dime.datatype = 4;
switch  double(analyze_struct.hdr.dime.datatype),
    case   1,
        analyze_struct.hdr.dime.bitpix = int16(1 ); precision = 'ubit1';
    case   2,
        analyze_struct.hdr.dime.bitpix = int16(8 ); precision = 'uint8';
    case   4,
        analyze_struct.hdr.dime.bitpix = int16(16); precision = 'int16';
    case   8,
        analyze_struct.hdr.dime.bitpix = int16(32); precision = 'int32';
    case  16,
        analyze_struct.hdr.dime.bitpix = int16(32); precision = 'float32';
    case  32,
        analyze_struct.hdr.dime.bitpix = int16(64); precision = 'float32';
    case  64,
        analyze_struct.hdr.dime.bitpix = int16(64); precision = 'float64';
    case 128,
        analyze_struct.hdr.dime.bitpix = int16(24); precision = 'uint8';
    case 256
        analyze_struct.hdr.dime.bitpix = int16(8 ); precision = 'int8';
    case 512
        analyze_struct.hdr.dime.bitpix = int16(16); precision = 'uint16';
    case 768
        analyze_struct.hdr.dime.bitpix = int16(32); precision = 'uint32';
    case 1024
        analyze_struct.hdr.dime.bitpix = int16(64); precision = 'int64';
    case 1280
        analyze_struct.hdr.dime.bitpix = int16(64); precision = 'uint64';
    case 1792,
        analyze_struct.hdr.dime.bitpix = int16(128); precision = 'float64';
    otherwise
        error('This datatype is not supported');
end

% find out the number of dimensions

switch data.raw_data
    case 'no'
        if (strcmp(mosaic_flag, 'mosaic') == 1) && (nfiles > 1)
            number_of_dimensions = 4;
        end
        if (strcmp(mosaic_flag, 'mosaic') == 1) && (nfiles == 1)
            number_of_dimensions = 3;
        end
        if (strcmp(mosaic_flag, 'regular') == 1) && (nfiles > 1)
    %   BELOW - commented out below is certainly wrong for a localiser with 1 slice, and one average
            %             % need to distinguish for the rare case that there is only one slice, but many acquisitions
%             n_avs = str2num(search_text_header_func(data.current_writefile_th, 'lAverages'));
%             % regular 2d anatomical and localizer, respectively
%             if ( (dim_nslices > 1) || ((dim_nslices == 1) && (n_avs > 1)))
%                 number_of_dimensions = 3;
%             else
%                 number_of_dimensions = 4;
%             end
            number_of_dimensions = 3;
        end
        if (strcmp(mosaic_flag, 'regular') == 1) && (nfiles == 1)
            number_of_dimensions = 2;
        end
    case 'yes'
        number_of_dimensions = 2;
end

analyze_struct.hdr.dime.dim(1) = number_of_dimensions;

switch number_of_dimensions
    case 4
        analyze_struct.hdr.dime.dim(4) = dim_nslices;
        analyze_struct.hdr.dime.dim(5) = nfiles;
    case 3
        switch mosaic_flag
            case 'mosaic'
                analyze_struct.hdr.dime.dim(4) = dim_nslices;
            case 'regular'
                analyze_struct.hdr.dime.dim(4) = nfiles;
        end
    case 2
        switch data.raw_data
            case 'yes'
                analyze_struct.hdr.dime.datatype = 16;
                analyze_struct.hdr.dime.bitpix = int16(32); precision = 'float32';
                if (strcmp(mosaic_flag, 'regular') == 1) && (nfiles == 1)
                    analyze_struct.hdr.dime.dim(2) = nfiles;
                end
            case 'no'
                analyze_struct.hdr.dime.dim(1) = 2;
                analyze_struct.hdr.dime.dim(4) = nfiles;
        end
end

%if the voxel dimensions calculated from the text header make sense put
%these in the header. Otherwise warn....

if (dim_FOV_phase == -1) || (dim_FOV_read == -1) || (dim_slice_thick == -1)
    data.warning_text = sprintf('%s Could not identify the FOV', data.warning_text);
end

% Method 1 - http://nifti.nimh.nih.gov/nifti-1/documentation/faq
switch data.current_header_pars.PE_dir
    case 'ROW'
        analyze_struct.hdr.dime.pixdim(2) = dim_VS_read;
        analyze_struct.hdr.dime.pixdim(3) = dim_VS_phase;
        analyze_struct.hdr.dime.pixdim(4) = dim_slice_thick;
    case 'COL'
        analyze_struct.hdr.dime.pixdim(2) = dim_VS_phase;
        analyze_struct.hdr.dime.pixdim(3) = dim_VS_read;
        analyze_struct.hdr.dime.pixdim(4) = dim_slice_thick;
end

%   set the origin as the centre of the images
analyze_struct.hdr.hist.originator(1) = floor(analyze_struct.hdr.dime.dim(2)/2);
analyze_struct.hdr.hist.originator(2) = floor(analyze_struct.hdr.dime.dim(3)/2);
analyze_struct.hdr.hist.originator(3) = floor(analyze_struct.hdr.dime.dim(4)/2);

switch data.current_header_pars.rescaled
    case 'yes'
        analyze_struct.hdr.dime.scl_inter = data.current_header_pars.rescale_intercept;
        analyze_struct.hdr.dime.scl_slope = data.current_header_pars.rescale_slope;
        this_warning_text = sprintf('Images contain rescaling, y=%i*value +%i', analyze_struct.hdr.dime.scl_slope, analyze_struct.hdr.dime.scl_inter);
        data.warning_present = 'yes';
        data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
    case 'no'
        analyze_struct.hdr.dime.scl_inter = 0;
        analyze_struct.hdr.dime.scl_slope = 1;
end

%   update data
data.current_analyze_struct = analyze_struct;
data.current_precision = precision;

