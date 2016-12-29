function trainMatFilename = getOutputFilename(trainPath, crossValidatePath, isTest)
getGlobalVariables;

slashPos = strfind(trainPath(1:end-1), SYSTEM_SLASH);
trainPath(slashPos) = '_';
slashPos = strfind(trainPath(1:end-1), '-');
trainPath(slashPos) = '_';
if ~exist('isTest', 'var')
    trainMatFilename = sprintf('TRAIN-%s', trainPath(1:end-1));
else
    trainMatFilename = sprintf('TEST-%s', trainPath(1:end-1));    
end

if ~isempty(crossValidatePath)
    slashPos = strfind(crossValidatePath(1:end-1), SYSTEM_SLASH);    
    crossValidatePath(slashPos) = '_';
    slashPos = strfind(crossValidatePath(1:end-1), '-');
    crossValidatePath(slashPos) = '_';
    trainMatFilename = sprintf('%s-CV-%s', trainMatFilename, crossValidatePath(1:end-1));
    if APPEND_TIMEDATE_TO_MAT_FILES
        trainMatFilename = sprintf('%s-%s.mat', trainMatFilename, datestr(now, 30));
    end
end