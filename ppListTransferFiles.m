function [status, returnList] = ppListTransferFiles( transferPath )
%Returns a list of the first DICOM file of all scans in the transfer folder
returnList = {};

[status, files] = unix(sprintf('for f in $( find "%s" -iname "*.ima" | grep -ohi ".*PHYSIKER[^\\.]*\\.[0-9]*\\." | sort | uniq ); do find $(dirname $f) -name $(basename $f)"*" | head -n 1 | xargs -n1 basename; done', transferPath));
[status, files] = unix(sprintf('for f in $( find "%s" -iname "*.ima" | grep -ohi ".*PHYSIKER[^\\.]*\\.[0-9]*\\." | sort | uniq ); do find $(dirname $f) -name $(basename $f)"*" | head -n 1 | xargs -n1 basename; done', transferPath));

status          = (status == 0);

files    = textscan(files,'%s');
files    = files{1};

%% Keep entries that are directories
for i=1:length(files)
    
    file = files{i};
    
    if ( ~strcmp(file, '') )
        returnList{end+1} = file;
    end
end
    
