function [ output_args ] = ppSearchParadigm3(workingDir)

% workingDir='E:/Uni/CognitiveScience/fMRI/pps12/';

dicom='DICOM';
nifti='NIFTI';

pathDir=dir(workingDir);



for i=3:length(pathDir)
    if pathDir(i).isdir==1
        %measurement
        name=[pathDir(i).name]
        
        if strcmp(name, dicom) == 1
            
            for j=3:length(pathDir)
                name2=[pathDir(j).name]
                if strcmp(name2, nifti) == 1
                   
                    workingDir
                   
                    % cut=regexpi(workingDir, '(?<x>[^\\]+$)', 'names');
                    % cutFolder=cut.x;
                    
                end
            end
            
        else
            
            subDir=strcat(workingDir,'/', name)
            ppSearchParadigm3(subDir)
            
        end
        
    end
end