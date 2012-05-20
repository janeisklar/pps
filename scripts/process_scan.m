function [ output_args ] = process_scan( scanDir )
%Process a directory of a scan
%   handles nifti-conversion and DICOM-archiving

%% Check presence of niftis
process_scan_niftis(scanDir);

%% Check presence of DICOM tar archive
process_scan_archive(scanDir);
    
end