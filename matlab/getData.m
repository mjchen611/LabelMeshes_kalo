function [meshes labels] = getData(path, inputLabels)
% used from trainLabelMeshes and testLabelMeshes*. 
% creates the meshes and labels cell structures based on path.
% inputLabels is used only for testLabelMeshes.
getGlobalVariables;

%% Function: Get training data
meshes = {};
labelMeshes = {};
trainMeshesFilenames = dir( strcat(path, '*.obj') );
trainMeshesFilenames = [trainMeshesFilenames; dir( strcat(path, '*.off') )];
for i=1:size(trainMeshesFilenames, 1)
    trainBaseFileName = strcat(path, trainMeshesFilenames(i).name );
    meshes{end+1} = loadMesh( trainBaseFileName ); %#ok<*AGROW>
    if USE_JOINTBOOST == 0
        meshes{end}.FEATURES = load( strcat(trainBaseFileName, '.txt') );
    end    
    trainBaseFileName(end-3:end) = [];
    labelMeshes{end+1} = loadLabels( strcat( trainBaseFileName, '_labels.txt' ), meshes{end} );
    if isempty( labelMeshes{i} ) && ~exist('inputLabels', 'var')
        meshes(end) = [];
        labelMeshes{end} = [];
        continue;
    end
    if size( meshes{i}.F, 2 ) < 1000
        error('Method does not work well with very coarse meshes (some features may not be computed if mesh has less than ~1000 faces).');
    end    
    meshes{end} = faceAreas( meshes{end}, true );
end

if ~exist('inputLabels', 'var')
    labels = {};
else
    labels = inputLabels;
end
for i=1:length( labelMeshes )
    for j=1:length( labelMeshes{i} )
        if isempty( strmatch(labelMeshes{i}(j).name, labels, 'exact') )
            labels{end+1} = labelMeshes{i}(j).name;
        end
    end
end


for i=1:length( meshes )
    if ~isempty( labelMeshes{i} )
        meshes{i}.L = zeros( size(meshes{i}.F, 2), 1, 'single' );
    end
    for j=1:length( labelMeshes{i} )
        l = strmatch(labelMeshes{i}(j).name, labels, 'exact');
        if ~isempty(l)
            meshes{i}.L( labelMeshes{i}(j).faces ) = l;
        else
            meshes{i}.L( labelMeshes{i}(j).faces ) = 0;
        end
    end
end

% if ~exist('inputLabels', 'var')
%     sumFaceAreas = zeros( length( meshes ), length(labels) );
%     for i=1:length( meshes )
%         for j=1:length(labels)
%             sumFaceAreas(i, j) = sum( meshes{i}.Fa( meshes{i}.L == j) );
%         end
%     end
%     sumFaceAreas = max( sumFaceAreas );
%     [sumFaceAreasPerLabel sortIndices] = sort( sumFaceAreas, 'descend' );
%     labels = labels(sortIndices);
%     for i=1:length( meshes )
%         OLDL = meshes{i}.L;
%         for j=1:length(labels)            
%             meshes{i}.L( OLDL == sortIndices(j) ) = j;
%         end
%     end    
% end

if ~exist('inputLabels', 'var')
    sumFaceAreas = zeros( length( meshes ), length(labels) );
    averageDistances =  zeros( length( meshes ), length(labels) );
    for i=1:length( meshes )
        Fc = (meshes{i}.V(1:3,meshes{i}.F(1,:)) + meshes{i}.V(1:3,meshes{i}.F(2,:)) + meshes{i}.V(1:3,meshes{i}.F(3,:)))/3;        
        meanFc = mean( Fc' );
        Fc = Fc - repmat(meanFc, size(Fc, 2), 1)'; 
        [BFc tmp] = svd( cov( Fc * Fc' ) );
        Fc = BFc * Fc;
        normFc = norm(max(Fc,[],2) - min(Fc,[],2));
        Fc = Fc / normFc;
        for j=1:length(labels)
            sumFaceAreas(i, j) = sum( meshes{i}.Fa( meshes{i}.L == j) );
            averageDistances(i, j) = mean( sum( Fc( :, meshes{i}.L == j ).^2, 1 ) );
        end
    end
    sumFaceAreas( isnan( averageDistances ) ) = NaN;
    contextuality = max( averageDistances,  [], 1 ) .^5 .*  max( sumFaceAreas, [], 1 );
    
    [tmp sortIndices] = sort( contextuality, 'ascend' );
    labels = labels(sortIndices);
    for i=1:length( meshes )
        OLDL = meshes{i}.L;
        for j=1:length(labels)            
            meshes{i}.L( OLDL == sortIndices(j) ) = j;
        end
    end    
end

for i=1:length( meshes )
    meshes{i}.labelsfilename = strcat( meshes{i}.filename(1:end-4), '_labelsN.txt');    
    file = fopen( meshes{i}.labelsfilename, 'wt' );
    fprintf(file, '%d\n', meshes{i}.L);
    fclose(file);
end


