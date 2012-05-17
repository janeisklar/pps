function flist = sortlist_func2(flist, field_number_to_sort_by)

nfiles = length(flist);
unsorted_field_list = squeeze(rand(nfiles,1));
    
for n=1:nfiles 
    unsorted_field_list(n) = str2double(get_dicom_fieldname_func(flist(n).name, field_number_to_sort_by));
end

[sorted_field_list, IX] = sort(unsorted_field_list);

flist = flist(IX);



