function [ preproc,volumes,size ] = ppReadParadigm(path,paradigm)
%reads the content of paradigm.txt

%.txt to String
txt           = textread(path, '%s','delimiter', '\n');
foundParadigm = false;

% search for the right paradigm in .txt
for i=1:length(txt)
    
    tmpStr     = txt{i};
    parameters = regexpi(tmpStr,'(?<link>[\w]*)\s(?<preproc>[\w|\D]*)\s(?<volumes>[\d]*)\s(?<size>[\d]*)', 'names');
    
    if ( strcmp(parameters.link,'') || strcmp(parameters.preproc,'') || strcmp(parameters.volumes,'') || strcmp(parameters.size,'') )
         throw(MException('PPS:DICOMCheck','couldnt find Paradigm in .txt'));
    end
   
    if ( parameters.link(1:1)==paradigm(1:1) )
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