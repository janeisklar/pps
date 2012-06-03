function [ output_args ] = ppReadParadigm(path)
%clc;
path='paradigms.txt';

%.txt to String
txt = textread(path, '%s','delimiter', '\n');


for i=1:length(txt)
    
    tmpStr=txt{i};
    search=regexpi(tmpStr,'(?<link>[\w]*)\s(?<preproc>[\w|\D]*)\s(?<volumes>[\d]*)\s(?<size>[\d]*)', 'names');
    
    ppSearchLink(search.link, search.preproc, search.volumes, search.size);
    
end


% if parameters.type(1:1)~='-'
%     
%     %ppNiftiCheck(dir, parameters.type)
%     
% end

%ppDicomCheck(parameters.amount)

%parameters=regexpi(txt, '\A(?<link>\w*) (?<procedure>\w*) (?<amount>\d*) (?<size>\d*)', 'names');
