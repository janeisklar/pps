%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   current_readfile_stem.m - extracts the readfile_stem for the current scan series
%
%   called by execute_sort_and_convert and used by convert_to_analyze
%
%   Simon Robinson. 24.11.2006
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function current_readfile_stem = get_readfile_stem_func(DICOM_filename, current_scan);

%Again, establish the readfile_stem from the number of full stops
full_stop_locations=findstr(DICOM_filename, '.');
current_readfile_stem=DICOM_filename(1:full_stop_locations(4));

end