function dicom_sort_convert_main(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   dicom_sort_convert_main.m
%        - creates directory structure and converts to ANALYZE or NIfTI
%
%   Simon Robinson. 15.6.2010
%    Latest Version: v1.17
%                   : v1.14 9.1.2009
%                   : v1.13 1.12.2008
%                   : v1.12 21.10.2008
%                   : v1.8  1.8.2007
%                   : v1.6 30.3.2007
%                   : v1.5 17.1.2007
%                   : v1.4 16.1.2007
%                   : v1.3 20.12.2006
%
%   Widget-based
%   Usage: (GUI)        dicom_sort_convert_main
%        : (script)     dicom_sort_convert_main(data)
%
%           see
%
%   Writes an activity log "dicom_sort_convert_log.txt" to the writefile directory selected.  Error
%   messages and warnings should be written here.  Check in the event of
%   problems.
%
%   Also writes acquisition information (TR/TE etc) in "text_header.txt" in each scan
%   directory %
%
%   Functions called, written by other groups
%cbiReadNifti(readfile, {[],[],[(i-1)*d4+1 i*d4],[]});
%     MGH Freesurfer Toolbox
%
%     isdicomfile.m
%     defmossize.m
%     mos2vol.m
%     mossub2volsub.m
%     mosind2volind.m
%
%     NIfTI toolbox - Jimmy Shen -
%     http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=8797&objectType=File
%
%     workbar.m -
%     Daniel Claxton - %     http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=7109&objectType=file
%
%   GUI data:
%   data.default_startpath =
%   data.readfile_dir = unsorted data directory
%   data.writefile_dir_selected = the writefile directory selected by user
%   data.writefile_dir = writefile_dir_selected appended by dicom/analyze
%   data.current_dir = current directory to write to
%   data.current_scan = scan series being processed
%   data.current_readfile_stem = stem for current scan series
%   data.first_scan = 'yes'/'no'
%   data.readfile_filter = '*.IMA' (could be set to '*.dcm')
%   data.flist = a list of files to be copied/converted
%   data.fsublist = a list of the files to be copied/converted in current scan
%   data.NFullstopsPrior = how many full stops before the scan number? -  set in select_sort_and_convert_Callback.m
%   data.retain_dicom = 'no'/'yes'
%   data.scanlistonly = 'yes'/'no'
%   data.fp_scanlist ; file pointer of scan list file
%   data.log_style = 'verbose'/'normal' ; set to 'verbose' in test mode ;%   not currently used
%   data.warning_present = 'yes'/'no'
%   data.warning_text = a string into which all warnings are concatenated;
%   data.convert = 'yes'/'no'
%   data.convert_format = 'nift'/'analyze'
%   data.current_conversion = 'dicom'/'convert'/'list'
%   data.current_readfile_example ; first file in each scan dir
%   data.current_dcminfo; dcminfo for first file in scan dir
%   data.current_nfiles ; number of files in current scan
%   data.current_writefile_th ; text header for current scan
%   data.current_mosaic_flag ; mosaic flag for current scan
%   data.current_header_pars ; header pars for current scan
%   data.current_header_pars.dim_FOV_phase = dim_FOV_phase;
%   data.current_header_pars.dim_FOV_read = dim_FOV_read;
%   data.current_header_pars.dim_VS_phase = dim_VS_phase;
%   data.current_header_pars.dim_VS_read = dim_VS_read;
%   data.current_header_pars.dim_nslices = dim_nslices;
%   data.current_header_pars.nechos = nechos;
%   data.current_header_pars.echo_times = echo_times;
%   data.current_header_pars.dim_phase = dim_phase;
%   data.current_header_pars.dim_read = dim_read;
%   data.current_header_pars.dim_slice_thick = dim_slice_thick;
%   data.current_header_pars.PE_dir ; 'ROW' or 'COL'
%   data.current_header_pars.rescaled = 'yes'/'no';
%   data.current_header_pars.rescale_intercept
%   data.current_header_pars.rescale_slope
%   data.current_analyze_struct ; analyze structure for current scan
%   data.test = 'yes'/'no'
%   data.anonymise = 'yes'/'no'
%   data.current_series_name = extension
%   data.number_of_operations = (counts 1 per sort/convert);
%   data.reco_option = 'Not Set' at start, then changed to
%   data.total_number_of_files
%   data.number_of_conversions_complete
%        'Reconstruct All Raw Scans'
%        'Reconstruct This Scan'
%        'Do not reconstruct'
%       by questdlg in convert_to_analyze_func.m
%   data.slice_reorder = 'yes'/'no'
%	data.convert_to_3d = 'yes'/'no' - for recon data ('no' for multi-echo)
%   data.conversion_time ; for timing processing
%
%   Credits
%   1) Jimmy Shen's NIfTI toolbox
%   http://www.mathworks.com/matlabcentral/fileexchange/8797
%   2) Stefano Gianoli : A lot of the GUI operation copied from renamefiles.m
%   http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectI
%   d=7077&objectType=file
%
%
%   Bugs and shortcomings
%   3) Series title, scan number and image number are identified by their
%   relation to a series of "."s in the .IMA name.  Probably different for other scanners
%   4) Doesn't really provide orientation infomation in the analyze header.
%   Strictly speaking this should all be done according to "Method 3"
%   -http://nifti.nimh.nih.gov/pub/dist/src/niftilib/nifti1.h- using the
%   hdr.hist.srow_* parameters
%
%
%   Modifications
%   v1.1 i) Repaired selection of output directory
%        ii) Added log of the conversion
%        iii) Included version numbering in logs and title
%   v1.2 i) Included reconstruction of raw data (slice order and
%   orientation needs fixing)
%        ii) Fixed ui object handles (everything now refers to parent
%        "obj")
%        iii) Checks on write permissions for log and making directories in writefile directory
%        iv) Changed behaviour with unknown sequence types.  Now guesses
%        matrix sizes and issues a warning
%        v) Dumps dicominfo to same file as the text section of the dicom
%        header (Gives TE, TR, operator name, coil etc)
%   v1.3 i) Asymmetric fields of view and matrix sizes handled properly
%        ii) Slice gap included in slice thickness if present
%        iii) Voxel size calculation modified to work for 3D
%        iv) Corrected slice order and rotation in reconstruction
%   v1.4 i) Put getting of header parameters and putting these into the
%   analyze header as two separate functions,  get_header_parameters.m and
%   make_analyze_header.m, which are called by the reco_raw_data_func as
%   well, so reconstructed data has complete (well, better) header info
%       ii) Introduced the scaling factors .hdr.dime.scl_inter and
%       .hdr.dime.scl_slope
%       iii) A less verbose log, except in test mode
%       iv) Identification of sag, axial or cor (not currently used)
%       v) Bug sorted. Until now a two-column shift was introduced in the NIfTI (but not analyze)
%       option. Corrected.
%       vi) More asymmetric matrix sizes / imaging orientations working.
%       vii) Put conversion of a single image from mosaic and image
%       rotation as a separate function - process_one_slice_func.m
%       viii) Introduced a warning string which is displayed at the end if
%       there were warnings
%       ix) Modified start-up positioning on display - needed for
%       laptops/small monitors
%   v1.5 1) Replaced findstr (which searches for any match between str1 and
%       str2) by strfind (which looks for str1 in str2) in
%       write_dcm_text_header.m. Ellimated bogus finding of search strings
%       2) write_dcm_text_header.m replaced by write_dcm_text_header_with_guidata.m.
%       It's not text header info, but it's too useful to leave
%       unavailable to further programs.  Orientation is now written into
%       each text header.
%   v1.6 1) Tidied up extraction of scan and image name via the
%   data.NFullstopsPrior parameter. Works automatically with anonymised images (those exported as anonymised on export from the scanner) and should
%   allow easier extension to other sites
%        2) Allows data to be reformatted after conversion with the
%        reformat_data.m function, called in convert_to_analyze.m
%        3) Added a scan log, containing useful info about each scan (type,
%        protocol name, parameters); write_scan_details. One-off info is
%        written in convert_to_analyze.
%        4) Via a new checkbox, allows the user to select only to produce a scan list
%        "scanlistonly".
%        5) Modified the progressbar so it doesn't pop up annoyingly
%        with every new scan
%        6) Anonymises dicom images
%           If data.anonymise is set to 'yes', as it now is by default, this removes
%   	the subject/Patient name from dicom headers, takes the name out of the
%   	text_header.txt, record of the original file name, and out of the scan
%   	list. The dicom header still full details of:
%           Patient ID			:
%           Patient Date of Birth		:
%           Patient Sex		:
%           Patient Age		:
%           Patient Weight		:
%           Additional Patient History	:
%           Acquisition Date		:
%           Acquisition Time		:
%           Accession Number		:
%           Institution Name		:
%           Performing Physician's Name	:
%           Operator's Name		:
%       If you wish to remove these please use another anonymiser (such as
%       the LONI De-identification Debablet -
%       http://www.loni.ucla.edu/Software/Software_Detail.jsp?software_id=23)
%           Given that this is an open-source WIP (in which data.anonymise can be set to 'no'
%           for instance, the responsibility
%           for ensuring that no subject/patient
%           details are communicated to people not authorised to know these
%           remains with the person sending images or taking them off site.
%   v1.7 1) Sorted out reformatting of mosaic images with odd matrix sizes.
%    An even number of pixels seems always to be assigned.  Needs the
%    isodd.m function
%        2) Sorted out the workbar (progress bar) again.  But properly this
%        time
%        3) The has been a problem with the originator in early versions of SPM (pre-SPM5), meaning that the originator was taken to be [256 0 0], and there was no overlap with SPM templates, so normalisation didn't work. Jimmy Shen has modified his "save_nii.m" so that a .mat file with the affine transform is written, and I have put the same mods in convert_to_analyze.m.
%   v1.8 1) A new form of 'light' anonimisation introduced using dicomanon.
%   v1.9 1) If NIfTI format is selected, the sorted data is written to a directory called 'nifti', not 'analyze'.
%   v1.10 1) Bug fix of Anonymisation, so that it now does new-style 'light' (and slow) anon for MATLAB versions 2006b and above, old-style anon (whose DICOM output can't be interpreted correctly by Brain Voyager) for older MATLAB versions.
%         2) More possibilities for reformatting data, and more transparent in reformat_data_func.m (multi-echo, multi-channel, mag and phase)
%         3) Got rid of many of the get_ functions, replaced by a single get_dicom_fieldname_func.m
%         4) Introduced a data.features variable ('Basic'/'Advanced') to limit control some more fragile functions, and so I can modify
%         the output (particular of multi-echo, multi-channel data with reformat_data) to suit development needs, without pissing people off
%         5) Introduced a 'data.user' parameter so I can tailor some function to users.
%         6) Moves all .IMA into a subdirectory as a final step, unless in test mode or no .IMA files present
%   v1.11 1) Sorts into a directory named subjectID_accessionnumber
%         2) Moves sorted IMA to ima_to_delete at same directory level as subjectID_accessionnumber (fps of all
%         files now closed properly), making it easy to find and delete the
%         source data. To turn this off (e.g. for testing/debugging), change test from 'no' to 'yes' in
%         dicom_sort_convert_main.m
%   v1.12 1) Removed DICOM warnings
%         2) Added orientation and angle logging in scan list
%         3) Switched to using dicominfo.ProtocolName as label in scan_list.txt rather than tProtocolName[0]in
%         text header, which has a tendency to get messed up
%         4) There is now a separate time reported for creating scan list,
%         sorting and conversion which uses the new function
%         secs2hms
%         5) pixel dimensions (hdr.dime.pixdim) corrected for reformatted
%         data (multi-channel and/or multi-echo and/or phase&magnitude)
%         6) previously no introductory details were written into the scan log if dicom sorting only was done. These are now written by
%            write_introductory_comments.m
%         7) reformatting of data with more than 3 dimensions (non-mosaic)
%         and more than 4 dimensions (mosaic) using reformat_data_func.m
%         thoroughly reworked
%   v1.13 1) script call to dicom_sort_convert_main introduced - see
%   example_dscm_call.m
%   v1.14 1) reformats DTI data, treating number of gradient directions
%   like repetitions in non-mosaic EPI
%   v1.15 1) If the patient ID or accession number contain illegal characters, suggests alternative directory name
%         2) Improved reformatting of multi-channel data into [x][y][z][time][echos][channels][phase/mag] in the reformat directory, which works for 8, 24 and 32-element coils
%   v1.17 1) Two-file NIfTI (.img/.hdr) method repaired
%         2) REPORT files are now moved to separate directory (report). There is one REPORT file per scan and they can be used to pheonix protocols
%         3) abbreviated scan parameters in the summary list (scan_list.txt)
%         4) made compatible with new VB17 file and dicom formats
%               - removes leading zeros in directory name list (scan_names)
%               - jumps over a new kind of DUMMY scan with dcminfo.SeriesDescription 'StartFMRI' in execute_sort_and_convert_Callback.m
%         5) writes a few obvious acquisition parameters for unknown sequence types
%         6) Fixed: a bug in the > 4D reformatting for interleaved sequences with an odd number of slices, that meant that the last odd slice was getting lost
%         7) Renamed buttons a bit to make it clearer what they do
%   v1.18 1) In the test = 'no' mode, IMA data and REPORT files are zipped to ima.tar.gz. If data.delete_data_asat = 'yes', the original IMA data are deleted after tarring (--remove-files). If tarring and zipping fails for some reason, IMA data are moved to an ima_to_delete directory instead
%         2) Converting from mosaic format.  If the mosaic image size does not tally with the read or phase matrix size, an attempt is made to identify the right matrix size
%           If it crashes in this function (process_one_slice.m) it now writes which IMA file it was processing when it crash (so it's easier to check if this was corrupt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%% Begin User-defined Parameters %%%%%%%%%%%%%%%%%%

%   these choices are overwritten by data.* parameters in function calls to dicom_sort_convert_main

    function data = set_data_defaults
        data.anonymise = 'no';
        data.test = 'no'; % no = move data to ima_to_delete directory after sort/convert, delete scan directories in list mode
        data.define_writefile_subdir = 'yes';
        data.version_number = '1.18';
        data.readfile_filter = '*.IMA' ; %data.readfile_filter is set to this
        switch ispc
            case 1
                data.default_startpath = 'C:\';
            case 0
                data.default_startpath = '/data';
        end
        data.features = 'Advanced'; %'Basic'/'Advanced'
        % features = 'Advanced'; %'Basic'/'Advanced'
        %        data.user = 'Manuela'; %''/'Simon''Manuela',
        data.user = 'Simon'; %''/'Simon''Manuela',
        % Everyone can have their own most useful startpath, overrides general
        % defaults here
        switch data.user
            case 'Simon'
                data.default_startpath = 'F:\dicom_sort_test';
            otherwise
        end
        data.log_style = 'normal';
        data.readfile_dir = data.default_startpath;
        data.writefile_dir_selected = data.default_startpath;
        data.retain_dicom = 'no';
        data.convert = 'yes';
        data.convert_format = 'nifti';
        data.current_conversion = '';
        data.slice_reorder = 'yes';
        data.scanlistonly = 'no';
        data.write_an_extra_scanlist = 'no';
        data.workbar_off = 'no';
        data.delete_data_asat = 'yes'; % delete data After Sorting And Tarring
        data.number_of_operations = 0;
        warning off MATLAB:nonIntegerTruncatedInConversionToChar;
    end

%%%%%%%%%%%%%%%%%%%  End User-defined Parameters  %%%%%%%%%%%%%%%%%%

if (nargin == 0)
    clear data;
    data = set_data_defaults;
    data.gui = 1;
    %%%%%%%%%%%%%%%%%%%  GUI definition               %%%%%%%%%%%%%%%%%%
    grey_level=0.8;
    set(0,'Units','pixels') ;
    scnsize = get(0,'ScreenSize');
    figure('MenuBar','none',...
        'Name', ['Sort and/or Convert Siemens DICOM to NIfTI. v' data.version_number],...
        'NumberTitle','off',...
        'Position',[40,scnsize(4)-40-600,430,600],...
        'CreateFcn', @figure_CreateFcn,...
        'HandleVisibility','callback');
else
    clear data;
    data = set_data_defaults;
    script_selections = varargin{:};
    % overwrite all fields of 'data.' with selections in 'script_selections'
    fieldnames_script_selections = fieldnames(script_selections);
    for i=1:length(fieldnames_script_selections);
        data.(fieldnames_script_selections{i})=script_selections.(fieldnames_script_selections{i});
    end
    data.gui = 0;
    obj = 'no gui';
    select_sort_and_convert_Callback(obj,data);
end

    function figure_CreateFcn(obj, eventdata, handles)
        % Construct the components
        butt_select_us_dicom = uicontrol(obj,...
            'Style','pushbutton',...
            'String','Select IMA directory',...
            'Position',[10,600-25-10,200,25],...
            'Callback',{@select_us_dicom_Callback});
        butt_select_destination = uicontrol(obj,...
            'Style','pushbutton',...
            'String','Select Destination directory',...
            'Position',[10+200+10,600-25-10,200,25],...
            'Callback',{@select_destination_Callback});
        butt_sort_and_convert = uicontrol(obj,...
            'Style','pushbutton',...
            'String','GO!',...
            'Position',[10,10,410,25],...
            'Callback',{@select_sort_and_convert_Callback});
        checkbox_convert = uicontrol(obj,...
            'Style','CheckBox',...
            'BackgroundColor', [grey_level grey_level grey_level],...
            'String','Convert to',...
            'Position',[10,600-70,90,25],...
            'Callback',{@convert_Callback});
        checkbox_retain_dicom = uicontrol(obj,...
            'Style','CheckBox',...
            'BackgroundColor', [grey_level grey_level grey_level],...
            'String','Sort DICOMs into dirs and anonymise',...
            'Position',[10,600-115,300,25],...
            'Callback',{@dicom_retain_Callback});
        checkbox_scanlistonly = uicontrol(obj,...
            'Style','CheckBox',...
            'BackgroundColor', [grey_level grey_level grey_level],...
            'String','Only produce a list of scans',...
            'Position',[10,600-140,250,25],...
            'Callback',{@scanlistonly_Callback});
        p = uibuttongroup('Position',[.25,.84,.3,.1],...
            'BackgroundColor', [grey_level grey_level grey_level],...
            'BorderType', 'none');
        radiobutton_NIfTI = uicontrol('Style','RadioButton',...
            'String','NIfTI (.nii)',...
            'BackgroundColor', [grey_level grey_level grey_level],...
            'Position',[10,30,150,20],...
            'Parent',p);
        radiobutton_analyze = uicontrol('Style','RadioButton',...
            'String','two-file NIfTI (.img/.hdr pair)',...
            'BackgroundColor', [grey_level grey_level grey_level],...
            'Position',[10,10,220,20],...
            'Parent',p);
        splash_figure_filename = which('splash_figure.png');
        splash_image = imread(splash_figure_filename);
        splash_figure_pushbutton = uicontrol('style','pushbutton',...
            'Position',[10,40,410,411],...
            'CData',splash_image,...
            'Enable','Inactive');
        set(p,'SelectionChangeFcn',@radiobuttongroup_action);
        set(p,'SelectedObject');  % Default is NIfTI
        set(checkbox_convert,'Value',1);
        guidata(obj,data);
        
        function dicom_retain_Callback(obj,eventdata)
            data = guidata(obj);
            if (get(checkbox_retain_dicom,'Value') == get(checkbox_retain_dicom,'Max'))
                data.retain_dicom = 'yes';
            else
                data.retain_dicom = 'no';
            end
            guidata(obj,data);
        end
        
        function scanlistonly_Callback(obj,eventdata)
            data = guidata(obj);
            if (get(checkbox_scanlistonly,'Value') == get(checkbox_scanlistonly,'Max'))
                data.scanlistonly = 'yes';
                data.convert = 'no';
                data.retain_dicom = 'no';
                data.current_conversion = '';
                data.convert_format = '';
                set(p,'SelectedObject',[]);
                set(checkbox_convert,'Value',0);
                set(checkbox_retain_dicom,'Value',0);
                set(checkbox_retain_dicom,'Enable','off');
                set(checkbox_convert,'Enable','off');
                set(radiobutton_NIfTI,'Enable','off');
                set(radiobutton_analyze,'Enable','off');
            else
                data.scanlistonly = 'no';
                set(checkbox_retain_dicom,'Enable','on');
                set(checkbox_convert,'Enable','on');
                set(radiobutton_NIfTI,'Enable','on');
                set(radiobutton_analyze,'Enable','on');
                convert_Callback(obj,eventdata);
                dicom_retain_Callback(obj,eventdata);
            end
            guidata(obj,data);
        end
        
        function convert_Callback(obj,eventdata)
            data = guidata(obj);
            data.scanlistonly = 'no';
            get(checkbox_convert,'Value');
            if (get(checkbox_convert,'Value') == get(checkbox_convert,'Max'))
                data.convert = 'yes';
                data.convert_format = 'nifti';
                set(p,'SelectedObject',radiobutton_NIfTI);  % Select NIfTI first
            else
                data.convert = 'no';
                data.convert_format = '';
                set(p,'SelectedObject',[]);  % Deselect both
            end
            guidata(obj,data);
        end
        
        function radiobuttongroup_action(obj,eventdata)
            data = guidata(obj);
            format_select_string = (get(get(obj,'SelectedObject'),'String'));
            if findstr(format_select_string, 'two-file NIfTI (.img/.hdr pair)')
                data.convert_format = 'analyze';
            elseif findstr(format_select_string, 'NIfTI (.nii)')
                data.convert_format = 'nifti';
            else
                data.convert_format = 'Analyze Format Not Attributed';
            end
            guidata(obj,data);
        end
    end

    function select_us_dicom_Callback(obj,eventdata)
        data = guidata(obj);
        readfile_dir = uigetdir(data.readfile_dir);
        if ~isnumeric(readfile_dir)
            data.readfile_dir = readfile_dir;
            data.writefile_dir_selected = readfile_dir;
            guidata(obj,data);
        end
    end

    function select_destination_Callback(obj,eventdata)
        data = guidata(obj);
        writefile_dir_selected = uigetdir(data.writefile_dir_selected);
        if ~isnumeric(writefile_dir_selected)
            data.writefile_dir_selected = writefile_dir_selected;
            guidata(obj,data);
        end
    end
end