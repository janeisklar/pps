function [ required ] = ppBatchPreprocessingStepNecessary(file)
    required = exist(file) == 0;
end
