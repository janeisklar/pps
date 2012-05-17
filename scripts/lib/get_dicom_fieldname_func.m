%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   get_dicom_fieldname_name_func.m - gets a name out of Siemens DICOM
%       filenames
%
%   called in execute_sort_and_convert_Callback
%   
%   fullstops_prior is the number of full stops preceeding the field of
%   interest
%
%   Usual format is 
%   
%   subject_name.MR.starting_scan_protocol_directory.scan_number.subfield.
%
%   
%
%   Subject name:
%   0
%
%   Scan number:
%   3 for normal file names
%   2 for anonymised file names
%
%   Subfield (for separately-save multi-channel data)
%   4 for normal file names
%   3 for anonymised file names
%
%   Simon Robinson. 20.11.2006
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function field_name = get_dicom_fieldname_func(DICOM_filename, fullstops_prior)

%Find the directory via the number of full stops
full_stop_locations=findstr(DICOM_filename, '.');
if fullstops_prior > 1
    field_name=DICOM_filename(full_stop_locations(fullstops_prior)+1:full_stop_locations(fullstops_prior+1)-1);
else
    field_name=DICOM_filename(1:full_stop_locations(fullstops_prior+1)-1);
end
disp('');