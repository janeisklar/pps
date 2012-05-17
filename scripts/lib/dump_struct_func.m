%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   dump_struct_func(readfile, fp_writefile)
%
%   for dumping struct information to a file
%   gets information out of the dicom header and
%
%   Bugs: Generally fragile and tested for DICOM header structs only
%       Only works to two levels of structures (ie. struct.struct)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dump_struct_func(readfile, fp_writefile, anonymise)

fprintf(fp_writefile, '\n\n*** Parameters extracted using MATLAB''s dicominfo ***\n\n');

[res, dcminfo] = isdicomfile(readfile);

try
names=fieldnames(dcminfo);
catch
    disp('');
end

No_fields = length(names);

for n = 1:No_fields
    if length (dcminfo.(char(names(n)))) < 200
        one_field = dcminfo.(char(names(n)));
        field_type = class(one_field);
        value_string = '';
        switch field_type
            case 'logical'
            case 'char'
                value_string = string_convert(one_field);
            case 'int8'
                value_string = number_convert(one_field);
            case 'uint8'
                value_string = number_convert(one_field);
            case 'int16'
                value_string = number_convert(one_field);
            case 'uint16'
                value_string = number_convert(one_field);
            case 'int32'
                value_string = number_convert(one_field);
            case 'uint32'
                value_string = number_convert(one_field);
            case 'int64'
                value_string = number_convert(one_field);
            case 'uint64'
                value_string = number_convert(one_field);
            case 'double'
                value_string = number_convert(one_field);
            case 'single'
                value_string = number_convert(one_field);
            case 'cell'
            case 'struct'
                value_string = struct_convert(one_field);
            otherwise
        end
        if strcmp(anonymise, 'yes') == 1
            switch char(names(n))
                case 'Filename'
                    end_of_string_marker = strfind(value_string, '.MR.');
                    value_string = ['ANONYMISED' value_string(end_of_string_marker:end)];
                    if length(end_of_string_marker) == 0;
                        value_string = ['ANONYMISED:couldnt_sep_filestring']
                    end
                case 'PatientName'
                    value_string = 'ANONYMISED';
            end
        end
        full_string = [char(names(n)) ':' value_string];
        fprintf(fp_writefile, '%s\n', full_string);
    end
end

fprintf(fp_writefile, '\n\n*** End of Parameters extracted using MATLAB''s dicominfo ***\n\n');

end

function value_string = number_convert(one_field)
value_string = ' ';
x_dim_one_field = size(one_field, 1);
if numel(one_field) >=1
    try
        for i=1:x_dim_one_field
            value_string=[value_string num2str(one_field(i)) ' '];
        end
    catch
        disp('');
    end
end
end

function value_string = string_convert(one_field)
value_string = ' ';
if numel(one_field) >=1
    value_string=[value_string char(one_field(1:end))];
end
end

function value_string = struct_convert(one_field)
names_one_field=fieldnames(one_field);
No_names_one_field = length(names_one_field);
value_string = ' ';
for j=1:No_names_one_field
    one_subfield = one_field.(char(names_one_field(j)));
    if isnumeric(one_subfield) == 1 && numel(one_subfield) >=1
        value_string = [value_string char(one_subfield(1:end))];
    elseif ischar(one_subfield) == 1 && numel(one_subfield) >=1
        value_string=[value_string char(one_subfield(1:end))];
    end
end
end