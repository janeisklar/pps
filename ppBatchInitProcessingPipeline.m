function [ steps ] = ppBatchInitProcessingPipeline(steps)
%% Initialize struct that contains the steps and their corresponding position id

i      = 0;
fields = fieldnames(steps);

for n = 1:numel(fields)
    
    step      = steps.(fields{n});
    active    = step(1) > 0;
    necessary = step(2) > 0 || i > 0;
    
    if active && necessary
        i = i+1;
        steps.(fields{n}) = i;
    else
        steps.(fields{n}) = 0;
    end
end

end