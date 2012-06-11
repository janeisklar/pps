function [ preproc,volumes,size ] = ppReadParadigm(path,paradigm)


%.txt to String
txt = textread(path, '%s','delimiter', '\n');
foundParadigm=false;

% search for the right paradigm in .txt
for i=1:length(txt)
    
    tmpStr=txt{i};
    parameters=regexpi(tmpStr,'(?<link>[\w]*)\s(?<preproc>[\w|\D]*)\s(?<volumes>[\d]*)\s(?<size>[\d]*)', 'names');
    
%     if parameters.link || parameters.preproc || parameters.volumes || parameters.size == ''
%         x='here'
%          %throw(MException('PPS:DICOMCheck','couldnt find Paradigm in .txt');
%     end
   
    if parameters.link(1:1)==paradigm(1:1)
        
        foundParadigm=true;
        preproc=parameters.preproc;
        volumes=parameters.volumes;
        size=parameters.size;
        %ppDicomCheck(parameters.volumes,parameters.size)  
        
    end
    
    
end

if foundParadigm==false
    %throw(MException('PPS:DICOMCheck','couldnt find Paradigm in .txt');
end


% if parameters.preproc(1:1)~='-'
%     
%     %ppNiftiCheck(dir, parameters.type)
%     
% end


