function data = reformat_data_func(data)

%   if the 'Advanced' feature are selected in dicom_sort_convert_main, this
%   function reformats a dataset with 3 or 4 dimensions into one with up to
%   7.  The dimensions of these are specified by the dims parameters, and
%   are, in order
%   [x][y][z][time][echos][channels][phase/mag]
%   The first 3 dimensions are always image x,y,z. After that, dimensions
%   are only used if variation in that dimension is present (more than one
%   time point, echo, channel, p/m)


% NON-MOSIAC
% odims(1) = x
% odims(2) = y
% odims(3) = time-echo-z-p/m-channels (changes least frequently -> changes most frequently)

% MOSIAC
% odims(1) = x
% odims(2) = y
% odims(3) = z
% odims(4) = ???time-echo-p/m-channels (changes least frequently -> changes most frequently)???

% dims(1) = x
% dims(2) = y
% dims(3) = z
% dims(4) = time
% dims(5) = echos
% dims(6) = channels
% dims(7) = phase/magnitude

dims(1:7) = 1;
odims = 0;
reformat = 'no';
datalabel = '[x,y,z';

convert_format = data.convert_format;
current_dir = data.current_dir;
current_nfiles = data.current_nfiles;
n_channels = data.current_header_pars.n_channels;

if data.current_analyze_struct.hdr.dime.dim(1) == 4
    odims (1:4) = data.current_analyze_struct.hdr.dime.dim(2:5);
else
    odims (1:3) = data.current_analyze_struct.hdr.dime.dim(2:4);
end

z = data.current_header_pars.dim_nslices;

dims (1) = odims(1);
dims (2) = odims(2);
dims (3) = z;

%   next dimension time (for EPI-type) or diffusion gradient
dims(4) = data.current_header_pars.dim_nr;
if data.current_header_pars.dim_nr > 1
    switch data.current_header_pars.sequence_type
        case 'ep2d_diff'
            if data.current_header_pars.dim_ngd > 1
                dims(dim) = data.current_header_pars.dim_ngd;
                datalabel = [datalabel ',diff_g'];
                %DTI with multiple repetitions
                if (data.current_header_pars.dim_nr > 1)
                    disp('!!! lRepetitions gives NR > 1 - assuming this is number of diffusion directions');
                    dims(dim) = data.current_header_pars.dim_nr;
                    data.warning_present = 'yes';
                    this_warning_text = 'lRepetitions gives NR > 1 - assuming this is number of diffusion directions - check reformatted data';
                    data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
                end
            end
        otherwise
            %   for time-series data
            datalabel = [datalabel ',t'];
    end
end
%   next dimension is echo number
if (data.current_header_pars.nechos > 1)
    reformat = 'yes';
    dims(5) = data.current_header_pars.nechos;
    datalabel = [datalabel ',echo'];
end
%   next dimension is channel
if strcmp(data.current_header_pars.sep_channels, 'yes')
    if z > 1 % only reformat if more than one slice
        reformat = 'yes';
    end
    dims(6) = n_channels;
    datalabel = [datalabel ',channel'];
end
%   next dimension is phase/magnitude
if strcmp(data.current_header_pars.data_type, 'MP')
    dim = dim + 1;
    reformat = 'yes';
    dims(7) = 2;
    datalabel = [datalabel ',phase/mag'];
end
datalabel = [datalabel ']'];

if (strcmp(data.current_mosaic_flag, 'mosaic') ~= 1 && (dims(4) > 1)) %only reformat NR>1 data if not MOSAIC
    reformat = 'yes';
end

%   below, some scans that shouldn't be reformatted
if numel(findstr(data.current_dcminfo.ImageType, 'T2 MAP'))==1 ||  numel(findstr(data.current_dcminfo.ImageType, 'T2_STAR MAP'))==1
    reformat = 'no';
end

if strcmp(reformat,'yes')
    disp([' - scan ' data.current_scan ' is ' datalabel ', reformatting into those dimensions']);
    current_reform_dir = fullfile(current_dir,'reform');
    s = warning ('query', 'MATLAB:MKDIR:DirectoryExists') ;	    % get current state
    warning ('off', 'MATLAB:MKDIR:DirectoryExists') ;
    mkdir(current_reform_dir);
    warning (s) ;						    % restore state
    switch convert_format
        case 'nifti'
            extension = '.nii';
        case 'analyze'
            extension = '';
    end
    readfile = fullfile(current_dir, sprintf('Image%s', extension));
    %   check that the product of the reformatted dimensions equals the old dimensions, and the number of files
    if prod(odims(3:end)) ~= current_nfiles
        disp(sprintf('!!! The scan dimensions are %i, which means there should be %i files, but there are %i', num2str(odims), prod(odims(3:end)), current_nfiles));
        data.warning_present = 'yes';
        this_warning_text = sprintf('!!! There should be %i files in this series, but there are %i',prod(odims(3:end)), current_nfiles);
        data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
        return;
    end
    if prod(odims(3:end)) ~= prod(dims(3:end))
        dim_ratio = prod(dims(3:end))/prod(odims(3:end));
        if round(dim_ratio) == dim_ratio && round(n_channels/dim_ratio) == n_channels/dim_ratio
            disp(sprintf('!!! The old scan dimensions are %s, and the new dimensions %s, which differ by a factor %f', num2str(odims), num2str(dims(1:dim)), dim_ratio));            
            disp(sprintf('!!! Assuming that the real number of channels is %i, not %i, trying to continue, check scan', n_channels/dim_ratio, n_channels));
            data.warning_present = 'yes';
            this_warning_text = sprintf('!!! Changed number of coil channels from %i to %i to reformat', n_channels, n_channels/dim_ratio);
            data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
            n_channels = n_channels/dim_ratio;
            if strcmp(data.current_header_pars.data_type, 'MP')
                dims(dim-1) = n_channels;
            else
                dims(dim) = n_channels;
            end  
        else
            disp(sprintf('!!! The old scan dimensions are %s, and the new dimensions %s, which differ by the a factor %f, and would make the guess of the real number of channel %f', num2str(odims), num2str(dims), dim_ratio, n_channels/dim_ratio));
            data.warning_present = 'yes';
            this_warning_text = sprintf('!!! The number of old and new dimensions doesn''t match (scan incomplete?), not reformatting', n_channels, n_channels/dim_ratio);
            data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
            return;
        end
    end
    try
        new_image = zeros(dims(1),dims(2),dims(3),dims(4),dims(5),dims(6),dims(7),data.current_header_pars.precision);
    catch
        disp('!!! Could not create the image for reformatting');
        return;
    end
    try
        old_image_nii = load_nii(readfile);
    catch
        disp('!!! Could not load the old image to perform reformatting');
        data.warning_present = 'yes';
        this_warning_text = '!!! Image couldn''t be loaded prior to reformatting';
        data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
        return;
    end
    if (strcmp(data.current_mosaic_flag, 'mosaic') ~= 1)
        try
            %         logical indexing slices
            for j = 1:dims(4) % time
                for k = 1:dims(5) % echos
                    for l = 1:dims(6) % channels
                        for m = 1:dims(7) % phase/magnitude
                            %disp(['putting elements ' num2str((j-1)*dims(5)*dims(3)*dims(7)*dims(6)+(k-1)*dims(3)*dims(7)*dims(6)+((1:1:dims(3))-1)*dims(7)*dims(6)+(m-1)*dims(6)+l) ' into ' num2str(k) ',' num2str(1:1:dims(3)) ',' num2str(j) ',' num2str(m) ',' num2str(l)]);
                            new_image(:,:,1:1:dims(3),j,k,l,m) = old_image_nii.img(:,:,(j-1)*dims(5)*dims(3)*dims(7)*dims(6)+(k-1)*dims(3)*dims(7)*dims(6)+((1:1:dims(3))-1)*dims(7)*dims(6)+(m-1)*dims(6)+l);
                        end
                    end
                end
            end
            data.warning_present = 'yes';
            this_warning_text = ['was reformatted to ' datalabel ' in /reformat)' ];
            data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
            if strcmp(data.current_header_pars.sep_channels,'yes') && (data.current_header_pars.dim_nr > 1)
                disp('  -  swapping slice order');
                %%
                if iseven(z)
                    slice_acq_order=[2:2:z 1:2:z-1];
                else
                    slice_acq_order=[1:2:z 2:2:z];
                end
                [dummy, new_slice_order] = sort(slice_acq_order);
                new_image=new_image(:,:,new_slice_order,:,:,:);
                %%
            end
        catch
            disp(['!!!' data.current_scan ': Couldn''t reformat data into new matrix - in reformat_data_func.m']);
            data.warning_present = 'yes';
            this_warning_text = ['Warning!!!: couldn''t be reformatted to ' datalabel];
            data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
        end
    else
        disp(['Scan ' data.current_scan ': reformatting not yet programmed for MOSAIC format']);
    end
    old_image_hdr = load_nii_hdr(readfile);
    %   sort out VC mode for the 24-channel coil
    if (dims(6) == 23) || (dims(6) == 25) || (dims(6) == 50) %23 = VC with 2 broken channels turned off - clutching at straws here
        current_reform_dir_vc = fullfile(current_reform_dir,'vc');
        s = warning ('query', 'MATLAB:MKDIR:DirectoryExists') ;	    % get current state
        warning ('off', 'MATLAB:MKDIR:DirectoryExists') ;
        mkdir(current_reform_dir_vc);
        current_reform_dir = fullfile(current_reform_dir,'other');
        s = warning ('query', 'MATLAB:MKDIR:DirectoryExists') ;	    % get current state
        warning ('off', 'MATLAB:MKDIR:DirectoryExists') ;
        mkdir(current_reform_dir);
        warning (s) ;						    % restore state
        new_image_vc = squeeze(new_image(:,:,:,:,:,1));
        new_image_vc_nii = make_nii_sr(new_image_vc, 4);
        new_image_vc_nii.hdr = centre_header(new_image_vc_nii.hdr);
        new_image_vc_nii.hdr.dime.pixdim(2:4) = old_image_hdr.dime.pixdim(2:4);
        save_nii(new_image_vc_nii, fullfile(current_reform_dir_vc, ['Image' extension]));
        new_image = new_image(:,:,:,:,:,2:end);
    end
    new_image = squeeze(new_image);
    new_image_nii = make_nii_sr(new_image, 4);
    new_image_nii.hdr = centre_header(new_image_nii.hdr);
    new_image_nii.hdr.dime.pixdim(2:4) = old_image_hdr.dime.pixdim(2:4);
    save_nii(new_image_nii, fullfile(current_reform_dir, ['Image' extension]));
end

