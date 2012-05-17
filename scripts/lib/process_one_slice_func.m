function data = process_one_slice_func(data, example_image)

mosaic_flag = data.current_mosaic_flag;
dim_phase = data.current_header_pars.dim_phase;
dim_read = data.current_header_pars.dim_read;
dim_nslices = data.current_header_pars.dim_nslices;

%   do the conversion
if strcmp(mosaic_flag, 'mosaic')
    %   mosaic images allocate even numbers of pixels in each dimension
    if isodd(dim_phase)
        mdim_phase = dim_phase + 1;
    else
        mdim_phase = dim_phase;
    end
    if isodd(dim_read)
        mdim_read = dim_read + 1;
    else
        mdim_read = dim_read;
    end
    %   new, SR, setting the same number of pixels in read and phase if the matrix size is asymmetric - is this always the case ?
    %   nope (see /sacher/raid/data/simon/acquired_data/sorting_spot/msp_100803/ series 6) - removing
    %     if dim_phase < dim_read
    %         mdim_phase = mdim_read;
    %     end
    %   do some checks and try to bodge through if there are problems
    phase_ratio=size(example_image,1)/mdim_phase;
    read_ratio=size(example_image,2)/mdim_read;
    if phase_ratio-floor(phase_ratio) ~=0
        if read_ratio-floor(read_ratio) ==0
            phase_ratio=read_ratio;
            mdim_phase_wrong=mdim_phase;
            mdim_phase=size(example_image,1)/phase_ratio;
            if mdim_phase - floor(mdim_phase) == 0
                switch data.first_image_in_series
                    case 'yes'
                        data.warning_present = 'yes';
                        this_warning_text = sprintf('Had to change phase matrix size from %i to %i to be able to convert from mosaic, check series', mdim_phase_wrong, mdim_phase);
                        data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
                end
            else
                error(sprintf('Could establish matrix size to convert from mosaic in process_one_slice_func.m'));
            end
        else
            error(sprintf('Could establish matrix size to convert from mosaic in process_one_slice_func.m'));
        end
    end
    if read_ratio-floor(read_ratio) ~=0
        if phase_ratio-floor(phase_ratio) ==0
            mdim_read_wrong = mdim_read;
            read_ratio=phase_ratio;
            mdim_read=size(example_image,2)/read_ratio;
            if mdim_phase - floor(mdim_phase) == 0
                switch data.first_image_in_series
                    case 'yes'
                        data.warning_present = 'yes';
                        this_warning_text = sprintf('Had to change read matrix size from %i to %i to be able to convert from mosaic, check series', mdim_read_wrong, mdim_read);
                        data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
                end
            else
                error(sprintf('Could establish matrix size to convert from mosaic in process_one_slice_func.m'));
            end
        else
            error(sprintf('Could establish matrix size to convert from mosaic in process_one_slice_func.m'));
        end
    end
    n_mosaic_slices = phase_ratio*read_ratio;
    switch data.current_header_pars.PE_dir
        case 'COL'
            try
                vol = mos2vol(example_image,double([mdim_phase,mdim_read,n_mosaic_slices]));
            catch
                error(sprintf('Crashed processing %s : check that these data aren''t corrupt', data.current_readfile));
            end
        case 'ROW'
            try
                vol = mos2vol(example_image,double([mdim_read,mdim_phase,n_mosaic_slices]));
            catch
                error(sprintf('Crashed processing %s : check that these data aren''t corrupt', data.current_readfile));
            end
    end
    try
        vol(:,:,dim_nslices+1:end) = [];
    catch
        error(sprintf('Crashed processing %s : check that these data aren''t corrupt', data.current_readfile));
    end
else
    vol=example_image;
end
clear example_image;

%rotate
try
    temp = imrotate(vol(:,:,1:end), -90);
    third_dimension = size(temp,3);
    vol = temp;
    if third_dimension > 1
        for i=1:third_dimension
            %             vol(:,:,i) = fliplr(temp(:,:,i));
        end
    else
        %         vol = fliplr(temp);
    end
    clear temp;
catch
    error('could not rotate');
end
data.vol = vol;
