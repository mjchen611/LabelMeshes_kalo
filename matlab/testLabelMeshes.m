function [testmeshes testerr] = testLabelMeshes(trainFile, testPathOrMeshes)

%% Initialization
getGlobalVariables;

if ~iscell(testPathOrMeshes)
    testPathOrMeshes( strfind(testPathOrMeshes, '/') ) = SYSTEM_SLASH;
    testPathOrMeshes( strfind(testPathOrMeshes, '\') ) = SYSTEM_SLASH;
    if testPathOrMeshes(end) ~= SYSTEM_SLASH
        testPathOrMeshes(end+1) = SYSTEM_SLASH;
    end
end

load(trainFile);

%% Get test data %%%%%%%%
if ~iscell(testPathOrMeshes)
    fprintf(1, '\n\n\n*** Reading test meshes ***\n\n');
    testmeshes = getData(testPathOrMeshes, labels);
else
    testmeshes = testPathOrMeshes;
end

%% predict unary terms
if ~isfield( testmeshes{1}, 'NLOGW')
    fprintf(1, '\n\n\n*** Predicting unary terms ***\n\n');
    [tmp testmeshes] = piecewiseCRFTraining(testmeshes, [], length(labels), pwparms );
end
if ~isfield( testmeshes{1}, 'el')
    for i=1:length( testmeshes )
        testmeshes{i} = createFaceEdgeStructuresAndData( testmeshes{i} );
    end
end
save tmp3;

%% create CRF and get labels per meshes
fprintf(1, '\n\n\n*** Predicting labels ***\n\n');
testerr = nan(length(testmeshes), 1);
exparms{CRF_MULT} = exp( exparms{CRF_MULT} );

for i=1:length(testmeshes)
    disp( testmeshes{i}.filename );
    testmeshes{i}.PL = createCRFGraph(exparms, testmeshes{i}, length(labels) );
    testmeshes{i}.PL = testmeshes{i}.PL + 1;
    testmeshes{i} = removeSmallComponents(testmeshes{i}, minLabelArea/5);
    
    if isfield(testmeshes{i}, 'L')
        testerr(i) = sum( ( testmeshes{i}.L ~= testmeshes{i}.PL ) .* testmeshes{i}.Fa' );
    end
end
save tmp4;

%% Saving results on matlab file  %%%%%%%%
if ~iscell(testPathOrMeshes)
    testMatFilename = getOutputFilename(testPathOrMeshes, '', true);
    save(testMatFilename, 'testPathOrMeshes', 'testmeshes', 'testerr');
    fprintf(1, '\n\n\n******** Done! **********\n\n');
end



fprintf(1, '\n\n\n*** Done! ***\n\n');
fprintf(1, 'Average error was: %.2f%%\n\n', 100 * mean(testerr) );

