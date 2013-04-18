function [ preproc,volumes,size ] = ppReadParadigm(path,paradigm)
%reads the content of paradigm.txt for a specified paradigm

paradigms     = ppListParadigms(path);

% search for the right paradigm in .txt
for i=1:length(paradigms)
    
    p = paradigms{i};

    if strcmpi( p.paradigm, paradigm )
        preproc       = p.job;
        volumes       = p.min_volumes;
        size          = p.min_size;
	return;
    end
end

%error if paradigm isn't listed in paradigm.txt
throw(MException('PPS:DICOMCheck','couldnt find Paradigm in .txt'));
