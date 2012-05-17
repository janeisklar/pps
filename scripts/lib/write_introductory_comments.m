function write_introductory_comments(data)

warning off MATLAB:nonIntegerTruncatedInConversionToChar;

fsublist = data.fsublist;
nfiles = length(fsublist);
data.current_nfiles = nfiles;

readfile_dir = data.readfile_dir;
writefile_dir = data.current_dir;

% get info out of the first DICOM header
data.current_readfile_example=fullfile(readfile_dir,fsublist(1).name);
[res, dcminfo] = isdicomfile(data.current_readfile_example);
data.current_dcminfo = dcminfo;

%check that it is possible to write the logfile
fprintf(data.fp_scanlog, '\n');
if isvar('dcminfo.DerivationDescription')
    fprintf(data.fp_scanlog, 'This Study was Anonimised on Export \n');
    fprintf(data.fp_scanlog, 'Study name:  \n');
    fprintf(data.fp_scanlog, 'Subject ID: \n');
    fprintf(data.fp_scanlog, 'AccessionNumber: \n');
else
    fprintf(data.fp_scanlog, 'Subject Project ID: \n');
    subject_namestring = '';
    subject_initials_code = 'XXXX';
    if isvar('dcminfo.PatientName.GivenName')
        subject_name = dcminfo.PatientName.GivenName;
    else
        subject_name = '';
    end
    if isvar('dcminfo.PatientName.FamilyName')
        subject_name = [subject_name ' ' dcminfo.PatientName.FamilyName];
    end
    if isvar('dcminfo.PatientName.GivenName')
        subject_initials_code = upper(dcminfo.PatientName.GivenName(1:2:3));
    end
    if isvar('dcminfo.PatientName.FamilyName')
        subject_initials_code = [subject_initials_code upper(dcminfo.PatientName.FamilyName(1:2:3))];
    end
    %         fprintf(data.fp_scanlog, 'Subject Name: %s \n', subject_namestring);  % Not ANON!
    %        fprintf(data.fp_scanlog, 'Subject Name: %s\n', subject_initials);   % Just initials
    fprintf(data.fp_scanlog, 'Subject Name: %s\n', subject_name);   % Anon
    fprintf(data.fp_scanlog, 'Subject ID: %s \n', dcminfo.PatientID);
    fprintf(data.fp_scanlog, 'AccessionNumber: %s \n', dcminfo.AccessionNumber);
    dob_string = [dcminfo.PatientBirthDate(7:8) '/' dcminfo.PatientBirthDate(5:6) '/' dcminfo.PatientBirthDate(1:4) ];
    rough_minutes = num2str(sprintf('%02.0f', (15*floor(str2num(dcminfo.AcquisitionTime(3:4))/15))));
    time_string = [dcminfo.AcquisitionTime(1:2) rough_minutes];
    patient_code = [dcminfo.PatientBirthDate subject_initials_code '_'  dcminfo.AcquisitionDate time_string];
    fprintf(data.fp_scanlog, 'D.O.B: %s \n', dob_string);
    fprintf(data.fp_scanlog, 'Age: %s years\n', dcminfo.PatientAge(2:3));
end
date_string = [dcminfo.AcquisitionDate(7:8) '/' dcminfo.AcquisitionDate(5:6) '/' dcminfo.AcquisitionDate(1:4) ];
fprintf(data.fp_scanlog, 'Acquired on: %s\n', date_string);
fprintf(data.fp_scanlog, 'Patient code: %s\n', patient_code);
if isvar('dcminfo.DerivationDescription') == 1
    fprintf(data.fp_scanlog, 'By: (anon) : \n');
else
    if isvar('dcminfo.OperatorName.FamilyName') == 1
        fprintf(data.fp_scanlog, 'By: %s\n', dcminfo.OperatorName.FamilyName);
    else
        fprintf(data.fp_scanlog, 'By unnamed operator\n');
    end
end
if isvar('dcminfo.PatientComments') == 1
    fprintf(data.fp_scanlog, 'Comments (additional info): %s \n', dcminfo.PatientComments);
end
fprintf(data.fp_scanlog, 'Purpose of Study\n');
fprintf(data.fp_scanlog, '1:\n\n');
fprintf(data.fp_scanlog, '2:\n\n');
fprintf(data.fp_scanlog, '3:\n\n');
fprintf(data.fp_scanlog, 'Data location: %s\n', writefile_dir);
fprintf(data.fp_scanlog, '..................................................\n');
