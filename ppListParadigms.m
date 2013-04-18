function [ paradigms ] = ppListParadigms(path)
%reads the content of paradigm.txt
%.txt to String
txt           = textread(path, '%s','delimiter', '\n');
paradigms     = cell(length(txt), 1);

% search for the right paradigm in .txt
for i=1:length(txt)
    
    tmpStr     = txt{i};
    parameters = regexpi(tmpStr,'(?<paradigm>[A-za-z-_0-9]*)\s(?<preproc>[A-za-z-_0-9]*)\s(?<volumes>[\d]*)\s(?<size>[\d]*)', 'names');
    if ( strcmpi(parameters.paradigm,'') || strcmpi(parameters.preproc,'') || strcmpi(parameters.volumes,'') || strcmpi(parameters.size,'') )
	continue;
    end

    paradigm      = parameters.paradigm;
    preproc       = parameters.preproc;
    volumes       = str2num(parameters.volumes);
    size          = str2num(parameters.size);
    
    paradigms{i}  = struct( ...
	'paradigm',    paradigm, ...
	'job',         preproc, ...
	'min_volumes', volumes, ...
	'min_size',    size ...
    );
end
