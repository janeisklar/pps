function data = get_header_parameters(data)

writefile_th = data.current_writefile_th;
current_scan = data.current_scan;
fullstopsoffset = data.nfullstopsoffset;

data.current_header_pars.sep_channels = 'no';
dimension = '2D';

%   get the DICOM info out of an example
% [res, dcminfo] = isdicomfile(data.current_readfile_example);

if length(strfind(search_all_header_func(writefile_th, 'ImageType'),'mosaic')) > 0 || length(strfind(search_all_header_func(writefile_th, 'ImageType'),'MOSAIC'))
    data.current_mosaic_flag = 'mosaic';
else
    data.current_mosaic_flag = 'regular';
end
% if length(strfind(dcminfo.ImageType, 'MOSAIC')) > 0
%     data.current_mosaic_flag = 'mosaic';
% else
%     data.current_mosaic_flag = 'regular';
% end

sequence_type_full = search_text_header_func(writefile_th, 'tSequenceFileName');
sequence_type = sequence_type_full(strfind(sequence_type_full,'\')+1:end-1);
sequence_type = strrep(sequence_type,'"','');

%   Get some parameters from the DICOM text header
%   matrix size
dim_read = str2num(search_text_header_func(writefile_th, 'sKSpace.lBaseResolution'));
dim_phase = str2num(search_text_header_func(writefile_th, 'sKSpace.lPhaseEncodingLines'));
%dim_nslices comes later, depends on 2D or 3D
dim_nr = str2num(search_all_header_func(writefile_th, 'lRepetitions')) + 1;
if (dim_nr == -1 || dim_nr == 0)
    dim_nr = 1;
end

%   Field of view
dim_FOV_phase = str2num(search_text_header_func(writefile_th, 'sSliceArray.asSlice[0].dPhaseFOV'));
dim_FOV_read = str2num(search_text_header_func(writefile_th, 'sSliceArray.asSlice[0].dReadoutFOV'));

%   voxel size
dcminfo.PixelSpacing = num2str(search_all_header_func(writefile_th, 'PixelSpacing'));
if dcminfo.PixelSpacing ~= -1
    [dim_VS_phase, dim_VS_read] = strtok(dcminfo.PixelSpacing, ' ');
    dim_VS_phase = str2num(dim_VS_phase);
    dim_VS_read = str2num(dim_VS_read);
else
    dim_VS_phase = dim_FOV_phase/dim_phase ;
    dim_VS_read = dim_FOV_read/dim_read ;
end

%   number of slices and slice thickness
dcminfo.MRAcquisitionType = search_all_header_func(writefile_th, 'MRAcquisitionType');
if strcmp(dcminfo.MRAcquisitionType, '-1')==0
    switch dcminfo.MRAcquisitionType
        case '2D'
            dim_nslices = str2num(search_text_header_func(writefile_th, 'sGroupArray.asGroup[0].nSize'));
            dcminfo.SpacingBetweenSlices = str2num(search_all_header_func(writefile_th, 'SpacingBetweenSlices'));
            if dcminfo.SpacingBetweenSlices ~= -1
                dim_slice_thick = dcminfo.SpacingBetweenSlices;
            else
                dim_slice_thick = str2num(search_text_header_func(writefile_th, 'sSliceArray.asSlice[0].dThickness'));
            end
        case '3D'
            dim_nslices = str2num(search_text_header_func(writefile_th, 'sKSpace.lImagesPerSlab'));
            dim_slab_thick = str2num(search_text_header_func(writefile_th, 'sSliceArray.asSlice[0].dThickness'));
            dim_slice_thick =  dim_slab_thick / dim_nslices;
            dimension = '3D';
        case '' %   bodges - some MPRAGEs don't have the dimensions set in dcminfo.MRAcquisitionType
            %   also EPIs corrected after acquisition for motion or with
            %   PSF
            switch data.current_mosaic_flag
                case 'mosaic'   % behave as 2D
                    dim_nslices = str2num(search_text_header_func(writefile_th, 'sGroupArray.asGroup[0].nSize'));
                    dcminfo.SpacingBetweenSlices = str2num(search_all_header_func(writefile_th, 'SpacingBetweenSlices'));
                    if dcminfo.SpacingBetweenSlices ~= -1
                        dim_slice_thick = dcminfo.SpacingBetweenSlices;
                    else
                        dim_slice_thick = str2num(search_text_header_func(writefile_th, 'sSliceArray.asSlice[0].dThickness'));
                    end
                    data.warning_present = 'yes';
                    this_warning_text = 'Warning!!!: The dimension of the scan could not be identified.  Assuming EPI corrected for PSF or similar';
                    data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
                case 'regular'  %   call 3D for the moment
                    pos_slice1 = str2num(search_text_header_func(writefile_th, 'sSliceArray.asSlice[0].sPosition.dTra'));
                    pos_slice2 = str2num(search_text_header_func(writefile_th, 'sSliceArray.asSlice[1].sPosition.dTra'));
                    if pos_slice1 ~= -1 && pos_slice2 ~= -1
                        dim_slice_thick = abs(pos_slice2 - pos_slice1);
                    else
                        dim_slice_thick = str2num(search_text_header_func(writefile_th, 'sSliceArray.asSlice[0].dThickness'));
                    end
                    dim_nslices = str2num(search_text_header_func(writefile_th, 'sKSpace.lImagesPerSlab'));
                    dim_slab_thick = str2num(search_text_header_func(writefile_th, 'sSliceArray.asSlice[0].dThickness'));
                    dim_slice_thick =  dim_slab_thick / dim_nslices;
            end
        otherwise
            error('Scan %s: Dimension of scan not recognised', data.current_scan);
    end
else
    data.warning_present = 'yes';
    this_warning_text = 'Warning!!!: The dimension of the scan could not be identified.  Assuming 2D';
    data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
end

%   Number of echos and echo times

nechos = str2num(search_text_header_func(writefile_th, 'lContrasts'));
if nechos == -1
    nechos = 1;
end
TEs = [];
for i=1:nechos
    TEs(i)= str2double(search_text_header_func(writefile_th, sprintf('alTE[%i]',i-1)));
end
TEs = TEs./1000;


%	DTI - treat diffusion directions like time points - only could be a
%	problem if multiple repetitions/averages
if str2num(search_text_header_func(writefile_th,'sDiffusion.lDiffDirections')) ~= -1
    dim_ngd = str2num(search_text_header_func(writefile_th,'sDiffusion.lDiffDirections'));
else
    dim_ngd = 1;
end


%   Get TR
dcminfo.RepetitionTime = str2num(search_all_header_func(writefile_th, 'RepetitionTime'));
if dcminfo.RepetitionTime ~= -1
    TR = dcminfo.RepetitionTime;
else
    TR = 0;
end

%   if this is a 3D-EPI replace the TR by the effective TR, the volume repetition time
switch sequence_type
    case 'BP_ep_multipurpose'
        dcminfo.RepetitionTime = str2num(search_all_header_func(writefile_th, 'Private_0019_100b'));
        if dcminfo.RepetitionTime ~= -1
            TR = dcminfo.RepetitionTime;
        else
            TR = 0;
        end
end

%   Get TI
dcminfo.InversionTime = str2num(search_all_header_func(writefile_th, 'InversionTime'));
if dcminfo.InversionTime ~= -1
    TI = dcminfo.InversionTime;
else
    TI = 0;
end

%   Get FA

dcminfo.FlipAngle = str2num(search_all_header_func(writefile_th, 'FlipAngle:'));
if dcminfo.FlipAngle ~= -1
    FA = dcminfo.FlipAngle;
else
    FA = 0;
end

%   get protocol name - for anonymized data this parameter is removed from
%   the DICOM
dcminfo.ProtocolName = search_all_header_func(writefile_th, 'ProtocolName');
if strcmp(dcminfo.ProtocolName, '-1') ~= 0
    ProtocolName = dcminfo.ProtocolName;
else
    ProtocolName = search_text_header_func(writefile_th, 'tProtocolName');
    ProtocolName = strrep(ProtocolName, '+','');
    ProtocolName = strrep(ProtocolName, '-','_');
    ProtocolName = strrep(ProtocolName, 'AF8','');
    ProtocolName = strrep(ProtocolName, '"','');
end

%   Orientation
%   Get a label describing the axial, coronal or sagittal plane from row
%   and column unit vectors (direction cosines) as found in ImageOrientationPatient
%   The first three parameters are dir cosines between the image x direction and the scanner axes (i,j,k), the second
%   three are the dir cosines between the image y direction and the scanner axes (i,j,k)
%   The plane_angle is the (other than for sagittal, the symmetry-retaining) inclination of
%       i) the ant edge of the plane to the AP direction - for AXIAL
%       ii) the sup edge of the plane to the SI direction - for CORONAL
%       iii) the ant edge of the plane to the SI direction - for SAGITTAL
dcminfo.ImageOrientationPatient = str2num(search_all_header_func(writefile_th, 'ImageOrientationPatient'));
if dcminfo.ImageOrientationPatient ~= -1
    [C, row_orient]=max(abs(dcminfo.ImageOrientationPatient(1:3)));
    [C, col_orient]=max(abs(dcminfo.ImageOrientationPatient(4:6)));
    princ_axes = [row_orient col_orient];
    if (row_orient == 1 && col_orient == 2) || (row_orient == 2 && col_orient == 1)
        orientation = 'axial';
        plane_angle=180*acos(dcminfo.ImageOrientationPatient(5))/pi;
        if dcminfo.ImageOrientationPatient(6) > 0; plane_angle=-plane_angle; end;
    end
    if (row_orient == 1 && col_orient == 3) || (row_orient == 3 && col_orient == 1)
        orientation = 'coronal';
        plane_angle=180*acos(dcminfo.ImageOrientationPatient(6))/pi;
    end
    if (row_orient == 2 && col_orient == 3) || (row_orient == 2 && col_orient == 3)
        orientation = 'sagittal';
        plane_angle=180-180*acos(dcminfo.ImageOrientationPatient(6))/pi;
    end
    if isfield(data,'writefile_th_fp')
        if (data.writefile_th_fp ~= -1)
            fprintf(data.writefile_th_fp, 'Additional Information\n');
            fprintf(data.writefile_th_fp, 'Orientation = %s,%2.1f\n', orientation, plane_angle);
            fprintf(data.writefile_th_fp, 'End of Additional Information\n');
        end
    end
else
    data.warning_present = 'yes';
    this_warning_text = 'Warning!!!: The orientation of this scan could not be identified.  Assuming axial.';
    data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
    orientation = 'axial';
    plane_angle = 999;
end

if isvar('current_header_pars') == 1
    current_header_pars=data.current_header_pars;
end


EPI_factor = str2num(search_text_header_func(writefile_th, 'sFastImaging.lEPIFactor'));
if (EPI_factor == -1 || EPI_factor == 0)
    EPI_factor = 1;
end

% scan time
scan_time = search_text_header_func(writefile_th, 'lTotalScanTimeSec');
if scan_time == -1
    scan_time = search_text_header_func(writefile_th, 'lScanTimeSec');
end

%   PE direction
dcminfo.InPlanePhaseEncodingDirection = num2str(search_all_header_func(writefile_th, 'InPlanePhaseEncodingDirection'));
if dcminfo.InPlanePhaseEncodingDirection ~= -1
    switch dcminfo.InPlanePhaseEncodingDirection
        case 'ROW'
            PE_dir = 'ROW';
        case 'COL'
            PE_dir = 'COL';
        otherwise
            PE_dir = 'ROW';
            this_warning_text = 'Warning!!!: Could not identify directions of PE and Readout, assuming PE=AP';
            data.warning_present = 'yes';
            data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
    end
else
    PE_dir = 'ROW';
    this_warning_text = 'Warning!!!: Could not identify directions of PE and Readout, assuming PE=AP';
    data.warning_present = 'yes';
    data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
end

%   rescale present?
if isvar('dcminfo.RescaleIntercept') == 1 || isvar('dcminfo.RescaleSlope') == 1
    data.current_header_pars.rescaled = 'yes';
    if isvar('dcminfo.RescaleIntercept') == 1
        data.current_header_pars.rescale_intercept = dcminfo.RescaleIntercept;
    else
        data.current_header_pars.rescale_intercept = 0;
    end
    if isvar('dcminfo.RescaleSlope') == 1
        data.current_header_pars.rescale_slope = dcminfo.RescaleSlope;
    else
        data.current_header_pars.rescale_slope = 1;
    end
else
    data.current_header_pars.rescaled='no';
end

%%%   working out the number of channels via the number of subscans - unreliable as, for EPI runs, each subscan doesn't get the same number of scans
% if isvar('data.fsublist')
%     %   count the number of scans with the same field after the scan number
%     %   1 = normal
%     %   8=MC - multi-channel
%     %   16=MCMP - multi-channel magnitude and phase
%     datalabel='';
%     if size(data.fsublist,1) > 1
%         number_of_identical_subscan_numbers=1;
%         subscannumber1=get_dicom_fieldname_func(data.fsublist(1).name, fullstopsoffset+3);
%         for i=2:size(data.fsublist,1)
%             subscannumber=get_dicom_fieldname_func(data.fsublist(i).name, fullstopsoffset+3);
%             if strcmp(subscannumber,subscannumber1)
%                 number_of_identical_subscan_numbers=number_of_identical_subscan_numbers+1;
%             else
%                 break;
%             end
%         end
%         %   the following works for 8, 24 and 32 channel coils, and seems to be the only way to identify the number of elements used
%         %   if we need to work with a 4 or 16 channel coil, this is f?=#@d!
%         %   added 25 coils, for 24+VC mode
%         switch number_of_identical_subscan_numbers
%             case 1
%                 datalabel='';
%                 data.current_header_pars.sep_channels = 'no';
%             case {8,24,25,32,33}
%                 datalabel='MC';
%                 data.current_header_pars.sep_channels = 'yes';
%                 data.current_header_pars.n_channels = number_of_identical_subscan_numbers;
%             case {16,48,50,64,66}
%                 datalabel='MCMP';
%                 data.current_header_pars .sep_channels = 'yes';
%                 data.current_header_pars.n_channels = number_of_identical_subscan_numbers/2;
%             otherwise
%                 disp('Couldn''t identify if the scans were normal, MC or MCMP from the number of subscans');
%                 datalabel = '';
%                 data.current_header_pars.sep_channels = 'no';
%                 data.warning_present = 'yes';
%                 this_warning_text = 'Warning!!!: Couldn''t identify if the scans were normal, MC or MCMP from the number of subscans.  This depends on the matching the number of subscans to the number of channels of commonly-used coils. - See get_header_parameters.m';
%                 data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
%         end
%     end
%
%     % %   separate channels saved for multi-channel coil?
%     % save_uncombined_flag = search_all_header_func(data.current_writefile_th, 'ucUncombImages');
%     % switch save_uncombined_flag
%     %     case '0x1' % separate channels
%     %     data.current_header_pars.sep_channels = 'yes';
%     %     otherwise
%     %     data.current_header_pars.sep_channels = 'no';
%     % end
%
%     %   check the series and see if there are phase (P), magnitude (M), or both
%     %   (MP - or theoretically PM) images in there.
%     %   just checking the first image and the series and the next after all the
%     %   elements have been gone through (hierarchy is x, y, z, t, echo, phase/mag, element)
%     data_type = '';
%     [res, dcminfo] = isdicomfile(fullfile(data.readfile_dir,data.fsublist(1).name));
%     if size(findstr(dcminfo.ImageType,'\M\'),1)~=0
%         data_type=[data_type 'M'];
%     elseif size(findstr(dcminfo.ImageType,'\P\'),1)~=0
%         data_type=[data_type 'P'];
%     end
% else
%     datalabel = '';
%     data_type = '';
% end


% get the number of coils from the maximum index of 'asCoilSelectMeas[0].asList[' (VB) or 'sCOIL_SELECT_MEAS.asList[' (VA)
if isvar('data.fsublist')
    maxNoCoils = 32;
    datalabel='';
    NCoils = 1;
    if size(data.fsublist,1) > 1
        for i=maxNoCoils:-1:1
            NCoils = search_text_header_func(writefile_th, ['asCoilSelectMeas[0].asList[' num2str(i) ']']);
            if strcmp(NCoils,'-1') ~= 1
                NCoils = i+1;
                break
            end
        end
    end
    if strcmp(NCoils,'-1') == 1 % could be other text style (VA)
        if size(data.fsublist,1) > 1
            for i=maxNoCoils:-1:1
                NCoils = search_text_header_func(writefile_th, ['sCOIL_SELECT_MEAS.asList[' num2str(i) ']']);
                if strcmp(NCoils,'-1') ~= 1
                    NCoils = i+1;
                    break
                end
            end
        end
    end
    data.current_header_pars.n_channels = NCoils;
    switch NCoils
        case -1
            disp('Couldn''t identify the number of coils used');
            datalabel = '';
            data.current_header_pars.sep_channels = 'no';
            data.warning_present = 'yes';
            this_warning_text = 'Warning!!!: Couldn''t identify the number of coils used - See get_header_parameters.m';
            data.warning_text = sprintf('%sScan: %s. %s\n', data.warning_text, data.current_scan, this_warning_text);
        case 1
            data.current_header_pars.sep_channels = 'no';
        otherwise
            %   so there's more than one coil - now try to find out if the coil images were combined - indicated by a 'C:' in this obscure DICOM field
            combine_code = search_all_header_func(writefile_th, 'Private_0051_100f');
            if isempty(findstr(combine_code, 'C:')) && isempty(findstr(combine_code, 'T:'))
                data.current_header_pars.sep_channels = 'yes';
            else
                data.current_header_pars.sep_channels = 'no';
            end
    end
    %   check the series and see if there are phase (P), magnitude (M), or both (MP - or theoretically PM) images in there.
    %   just checking the first image and the series and the next after all the elements have been gone through (hierarchy is x, y, z, t, echo, phase/mag, element)
    data_type = '';
    [res, dcminfo] = isdicomfile(fullfile(data.readfile_dir,data.fsublist(1).name));
    if size(findstr(dcminfo.ImageType,'\M\'),1)~=0
        data_type=[data_type 'M'];
    elseif size(findstr(dcminfo.ImageType,'\P\'),1)~=0
        data_type=[data_type 'P'];
    end
else
    datalabel = '';
    data_type = '';
end


if strcmp(data.current_header_pars.sep_channels,'no')
    increment_to_next_possible_phase_file = 1;
else
    increment_to_next_possible_phase_file = 8;
end

try
    [res, dcminfo] = isdicomfile(fullfile(data.readfile_dir,data.fsublist(1+increment_to_next_possible_phase_file).name));
    if size(findstr(dcminfo.ImageType,'\M\'),1)~=0 && strcmp(data_type,'P')
        data_type=[data_type 'M'];
    elseif size(findstr(dcminfo.ImageType,'\P\'),1)~=0 && strcmp(data_type,'M')
        data_type=[data_type 'P'];
    end
catch   % if there is only one file in the sublist
    data_type=[data_type 'M'];
end
%   Useful debug point

if strcmp(current_scan,'13')
    disp('');
end

data.current_dcminfo.BitsAllocated = search_all_header_func(writefile_th, 'BitsAllocated');
if str2num(data.current_dcminfo.BitsAllocated) ~= -1
    switch str2num(data.current_dcminfo.BitsAllocated)
        case  16
            precision = 'int16';
        otherwise
            error('In get_header_parameters - call Simon - this dcminfo.BitsAllocated value needs adding');
    end
end


data.current_header_pars.sequence_type = sequence_type;
data.current_header_pars.dim_FOV_phase = dim_FOV_phase;
data.current_header_pars.dim_FOV_read = dim_FOV_read;
data.current_header_pars.dim_VS_phase = dim_VS_phase;
data.current_header_pars.dim_VS_read = dim_VS_read;
data.current_header_pars.dim_nslices = dim_nslices;
data.current_header_pars.nechos = nechos;
data.current_header_pars.echo_times = TEs;
data.current_header_pars.tr = TR;
data.current_header_pars.fa = FA;
data.current_header_pars.ti = TI;
data.current_header_pars.dim_phase = dim_phase;
data.current_header_pars.dim_read = dim_read;
data.current_header_pars.dim_nr = dim_nr;
data.current_header_pars.dim_ngd = dim_ngd;
data.current_header_pars.dim_slice_thick = dim_slice_thick;
data.current_header_pars.PE_dir = PE_dir;
data.current_header_pars.orientation = orientation;
data.current_header_pars.plane_angle = plane_angle;
data.current_header_pars.data_type = data_type;
data.current_header_pars.datalabel = datalabel;
data.current_header_pars.precision = precision;
data.current_header_pars.EPI_factor = EPI_factor;
data.current_header_pars.scan_time = scan_time;
data.current_header_pars.dimension = dimension;
data.current_header_pars.ProtocolName = ProtocolName;
