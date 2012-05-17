%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% convert_2dto3d_func2
% Converting a number of slices into a 3D data set
% Simon Robinson. 11.11.2006
%
% Usage convert_2dto3d_func2(readfile_dir, interleave_sort, file_name_start, filename_end, writefile)
%
% where
%   readfile_dir is the directory containing the slices
%   interleave_sort is a keyword ('yes' or 'no') - useful for EPI
%   file_filter is the filename key to identify the slices
%   writefile is the name of the 3D data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function convert_2dto3d_func2(obj, eventdata, interleave_sort, readfile_dir, file_name_start, filename_end, writefile)

data = guidata(obj);

flist = dir(fullfile(readfile_dir, [file_name_start '*' filename_end]));
writefile = fullfile(readfile_dir, writefile);

disp(sprintf('\n%s\n','Converting slices to 3D data set'));
nfiles = length(flist);
if(nfiles == 0)
    disp(sprintf('ERROR: no files in %s\n',readfile_dir));
    return;
end
disp(sprintf('Found %d files in %s\n',nfiles,readfile_dir));

%for n = 1:nfiles, disp([file_name_start int2str(n) filename_end]); end;

for n = 1:nfiles
    readfile = [file_name_start int2str(n) filename_end];
    ss_nii = load_nii(fullfile(readfile_dir,readfile));
    if n==1
        all_slices_nii=ss_nii;
        all_slices_nii.img=zeros(ss_nii.hdr.dime.dim(2),ss_nii.hdr.dime.dim(3),nfiles);
    end
    all_slices_nii.img(:,:,n)=ss_nii.img(:,:);
end;

all_slices_nii.hdr.dime.dim(1)=3;
all_slices_nii.hdr.dime.dim(4)=nfiles;

%swap order

switch interleave_sort
    case 'yes'
        disp('!!! Re-ordered interleaved slices. Check it is right!!!!');
        %   Normal Interleaved scheme
        acquisition_order=squeeze(zeros(n,1));
        acquisition_order(1:2:n)=(floor(n/2)+1:1:n);
        acquisition_order(2:2:n)=(1:1:floor(n/2));
        %   Sort the slices according to the acquisition order
        all_slices_nii.img(:,:,:)=all_slices_nii.img(:,:,acquisition_order);
        disp('!!! Re-ordered interleaved slices.');
    case 'no'
end

% this is where the header parameters are modified for raw data
% data.current_analyze_struct = all_slices_nii;

% guidata(obj,data);
% get_header_parameters(obj, eventdata);
% data = guidata(obj);
% make_analyze_header(obj, eventdata)
% data = guidata(obj);

if (nfiles > 1)
    all_slices_nii.hdr.dime.dim(1) = 3;
    all_slices_nii.hdr.dime.dim(4) = nfiles;
end
if (nfiles == 1)
    all_slices_nii.hdr.dime.dim(1) = 2;
    all_slices_nii.hdr.dime.dim(4) = nfiles;
end

% all_slices_nii = data.current_analyze_struct;

save_nii(all_slices_nii, writefile);
disp(['Written 3D data: ' writefile]);
