function [ preproc,volumes,size ] = ppReadParadigm(path,paradigm)
%reads the content of paradigm.txt
%.txt to String
txt           = textread(path, '%s','delimiter', '\n');
foundParadigm = false;

% search for the right paradigm in .txt
for i=1:length(txt)
    
    tmpStr     = txt{i};
    parameters = regexpi(tmpStr,'(?<link>[A-za-z-_0-9]*)\s(?<preproc>[A-za-z-_0-9]*)\s(?<volumes>[\d]*)\s(?<size>[\d]*)', 'names');
    if ( strcmpi(parameters.link,'') || strcmpi(parameters.preproc,'') || strcmpi(parameters.volumes,'') || strcmpi(parameters.size,'') )
         throw(MException('PPS:DICOMCheck','couldnt find Paradigm in .txt'));
    end
    %rsl if ( parameters.link(1:1)==paradigm(1:1) )
    if strcmpi( parameters.link, paradigm )
        foundParadigm = true;
        preproc       = parameters.preproc;
        volumes       = parameters.volumes;
        size          = str2num(parameters.size);
    end
    
end

%error if paradigm isn't listed in paradigm.txt
if ( foundParadigm==false )
    throw(MException('PPS:DICOMCheck','couldnt find Paradigm in .txt'));
end
