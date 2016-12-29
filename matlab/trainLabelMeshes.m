function [meshes CVmeshes err CVerr] = trainLabelMeshes(trainPath, crossValidatePath)


getGlobalVariables; 

trainPath( strfind(trainPath, '/') ) = SYSTEM_SLASH;
trainPath( strfind(trainPath, '\') ) = SYSTEM_SLASH;
crossValidatePath( strfind(crossValidatePath, '/') ) = SYSTEM_SLASH;
crossValidatePath( strfind(crossValidatePath, '\') ) = SYSTEM_SLASH;
if trainPath(end) ~= SYSTEM_SLASH
    trainPath(end+1) = SYSTEM_SLASH;
end
if exist('crossValidatePath', 'var') 
    if crossValidatePath(end) ~= SYSTEM_SLASH
        crossValidatePath(end+1) = SYSTEM_SLASH;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get training data %%%%%%%%
fprintf(1, '\n\n\n******** Preprocessing Stage: Reading input meshes **********\n\n');
[meshes labels] = getData(trainPath);
if exist('crossValidatePath', 'var')
    [CVmeshes labels] = getData(crossValidatePath, labels);
else
    CVmeshes = [];
    crossValidatePath = '';
end
if isempty(meshes)
    error('No training meshes found');
end

if length(meshes) <= 3 % too few training data
    disp('Too few training meshes... Merging training and validation meshes - will use default parameters for learning')
    meshes = [meshes CVmeshes];
    CVmeshes = meshes;
end

save tmp0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% piecewise CRF training %%%%%%%%
% optimizes pwparms - parameters of the classifiers used
% cross-validates intparms - regularization parameters of the classifiers
fprintf(1, '\n\n\n******** Piecewise learning Stage: Learning CRF parameters of unary terms **********\n\n');
[pwparms meshes CVmeshes unaryErr] = piecewiseCRFTraining(meshes, CVmeshes, length(labels) );
for i=1:length( meshes )
    meshes{i} = createFaceEdgeStructuresAndData( meshes{i} );
end
for i=1:length( CVmeshes ) 
    CVmeshes{i} = createFaceEdgeStructuresAndData( CVmeshes{i} );
end

minCCFaAll = []; 
maxCCFaAll = []; 
numPartsPerLabel = zeros( length(meshes)+length(CVmeshes), length(labels) );
for i=1:length( meshes )
    [tmp CCFa CCl meshes{i} minCCFaPerLabel] = getConnectedPartComponents(meshes{i}, meshes{i}.L, length(labels));
    minCCFaAll = [minCCFaAll; minCCFaPerLabel{1}];
    maxCCFaAll = [maxCCFaAll; minCCFaPerLabel{2}];
    for j=1:length(labels)
        numPartsPerLabel(i, j) = length( find( CCl == j ) );    
    end     
end
for i=1:length( CVmeshes )
    [tmp CCFa CCl CVmeshes{i} minCCFaPerLabel] = getConnectedPartComponents(CVmeshes{i}, CVmeshes{i}.L, length(labels));
    minCCFaAll = [minCCFaAll; minCCFaPerLabel{1}];
    maxCCFaAll = [maxCCFaAll; minCCFaPerLabel{2}];    
    for j=1:length(labels)
        numPartsPerLabel(length(meshes)+i, j) = length( find( CCl == j ) );    
    end         
end
% for j=1:length(labels)
%     numPartsPerLabel(end, j) = all( numPartsPerLabel(1:end-1, j) == numPartsPerLabel(1, j) );
%     if numPartsPerLabel(end, j) == 0
%        numPartsPerLabel(end, j) = NaN;
%     end
%     numPartsPerLabel(end, j) = numPartsPerLabel(end, j) * numPartsPerLabel(1, j);
% end
numPartsPerLabel = min( numPartsPerLabel );
minLabelArea = min( minCCFaAll );
maxLabelArea = max( maxCCFaAll );
save tmp1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% CRF parameter training %%%%%%%%
fprintf(1, '\n\n\n******** Learning Stage: Learning global CRF parameters **********\n\n');
[tmp unaryErrSortedIndices] = sort( unaryErr( 1:length(meshes) ), 'descend' );
useNumMeshes = min( ceil( length(CVmeshes) / 2 ), length(meshes) );
unaryErrSortedIndices = unaryErrSortedIndices(1:useNumMeshes);
exparms{CRF_SPINV} = getLabelCostMatrix( [meshes CVmeshes], length(labels) );
exparms{CRF_MULT} = repmat( linspace( log(MIN_EXPARM_VALUE), log(MAX_EXPARM_VALUE), INITIAL_SEARCH_SPACE_VALUES)', 1, TOTAL_EXPARMS );

[exparms{CRF_MULT} minf] = searchOptimalCRFParameters(exparms, [meshes(unaryErrSortedIndices) CVmeshes], length(labels));
[exparms{CRF_SPINV} minf] = searchOptimalLabelCostParameters(exparms, [meshes(unaryErrSortedIndices) CVmeshes], length(labels));
[tmp tmp unaryErr] = CRFTotalEnergy(exparms{CRF_MULT}, exparms, meshes, length(labels));
[tmp unaryErrSortedIndices] = sort( unaryErr( 1:length(meshes) ), 'descend' );
unaryErrSortedIndices = unaryErrSortedIndices(1:useNumMeshes);

[exparms{CRF_MULT} minf] = searchOptimalCRFParameters(exparms, [meshes(unaryErrSortedIndices) CVmeshes], length(labels), minf);
[exparms{CRF_SPINV} minf] = searchOptimalLabelCostParameters(exparms, [meshes(unaryErrSortedIndices) CVmeshes], length(labels));
[tmp tmp unaryErr] = CRFTotalEnergy(exparms{CRF_MULT}, exparms, meshes, length(labels));
[tmp unaryErrSortedIndices] = sort( unaryErr( 1:length(meshes) ), 'descend' );
unaryErrSortedIndices = unaryErrSortedIndices(1:useNumMeshes);

[exparms{CRF_MULT} minf] = searchOptimalCRFParameters(exparms, [meshes(unaryErrSortedIndices) CVmeshes], length(labels), minf);
[exparms{CRF_SPINV} minf] = searchOptimalLabelCostParameters(exparms, [meshes(unaryErrSortedIndices) CVmeshes], length(labels));

save tmp2;

%% Saving training file  %%%%%%%%
fprintf(1, '\n\n\n******** Saving Learned Parameters **********\n\n');
trainMatFilename = getOutputFilename(trainPath, crossValidatePath);
save(trainMatFilename, 'trainPath', 'crossValidatePath', 'exparms', 'minf', 'pwparms', 'labels', 'minLabelArea', 'maxLabelArea', 'trainMatFilename', 'unaryErr', 'numPartsPerLabel');
fprintf(1, '\n\n\n******** Done! **********\n\n');

%% Predicting and writing labels for training & CV data  %%%%%%%%
fprintf(1, '\n\n\n******** Predicting and writing labels for training data **********\n\n');
[meshes err] = testLabelMeshes(trainMatFilename, meshes);
fprintf(1, '\n\n\n******** Predicting and writing labels for CV data **********\n\n');
[CVmeshes CVerr] = testLabelMeshes(trainMatFilename, CVmeshes);
save(trainMatFilename, 'trainPath', 'crossValidatePath', 'exparms', 'minf', 'pwparms', 'labels', 'minLabelArea', 'maxLabelArea', 'trainMatFilename', 'meshes', 'err', 'CVmeshes', 'CVerr', 'unaryErr', 'numPartsPerLabel');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of Main Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




