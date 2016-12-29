function [pwparms meshes CVmeshes unaryErr] = piecewiseCRFTraining(meshes, CVmeshes, numlabels, inputPwparms)
% used from trainLabelMeshes. Essentially runs the Trimesh2Wrapper
% executable. 

%% Function: Piecewise CRF Training
getGlobalVariables;

file = fopen( MESHES_LABELS_FILE, 'wt' );
for i=1:length(meshes)
    fprintf(file, '%s %s\n', meshes{i}.filename, meshes{i}.labelsfilename);
end
if ~isempty(CVmeshes)    
    fprintf(file, '-\n');
end
for i=1:length(CVmeshes)
    fprintf(file, '%s %s\n', CVmeshes{i}.filename, CVmeshes{i}.labelsfilename);
end
fclose(file);

if USE_JOINTBOOST == 1
%% training with MeshSegmentationFeatures.exe
if ~exist('inputPwparms', 'var')    
    command = sprintf('%s %d %s', EXEC_PATH, numlabels, MESHES_LABELS_FILE);
    command( strfind(command, '/') ) = SYSTEM_SLASH;    
    command( strfind(command, '\') ) = SYSTEM_SLASH;
    disp(command);
    status = system(command);
    if status < 0
        error('Piecewise training failed during executing %s...', EXEC_PATH);
    end
    
    pwparms{1} = load( PWPARMS_FILE );
    pwparms{2} = load( EDGESPWPARMS_FILE );    
%     pwparms{3} = load( WHITENING_FILE );   
%     pwparms{4} = load( KMEANS_FILE );
else
    pwparms = inputPwparms;
    savedata = pwparms{1};
    save(PWPARMS_FILE, 'savedata', '-ASCII'); clear savedata;
    savedata = pwparms{2};
    save(EDGESPWPARMS_FILE, 'savedata', '-ASCII'); clear savedata;
%     savedata = pwparms{3};
%     save(WHITENING_FILE, 'savedata', '-ASCII', '-DOUBLE'); clear savedata;    
%     savedata = pwparms{4};
%     save(KMEANS_FILE, 'savedata', '-ASCII', '-DOUBLE'); clear savedata;        
    command = sprintf('%s %d %s %s', EXEC_PATH, numlabels, MESHES_LABELS_FILE);
    command( strfind(command, '/') ) = SYSTEM_SLASH;    
    command( strfind(command, '\') ) = SYSTEM_SLASH;    
    disp(command);
    status = system(command);
    if status < 0
        error('Evaluation of piecewise terms failed during executing %s...', EXEC_PATH);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


NLOGW = load( NLOGW_FILE );
ii = 1;
for f=1:length( FEATURE_ORDER )
    for i=1:length(meshes)
        meshes{i}.NLOGW{ FEATURE_ORDER(f) } = single( NLOGW(ii:ii+size(meshes{i}.F, 2)-1, 3:3+numlabels-1) );
        ii = ii + size(meshes{i}.F, 2);
    end
end

unaryErr = [];
for i=1:length(meshes)
    meshes{i}.NLOGW{ UNARY_POS } = zeros( numlabels, size(meshes{i}.NLOGW{FEATURE_ORDER(1)}, 1) );
    for f=1:length( FEATURE_ORDER )
        meshes{i}.NLOGW{ UNARY_POS } = meshes{i}.NLOGW{ UNARY_POS } + meshes{i}.NLOGW{ FEATURE_ORDER(f) }';
    end
    meshes{i}.NLOGW{ UNARY_POS } = min( meshes{i}.NLOGW{ UNARY_POS }, -log(EPSILON) );        
    meshes{i}.NLOGW{ UNARY_POS } = scale_cols( meshes{i}.NLOGW{ UNARY_POS }, meshes{i}.Fa / median( meshes{i}.Fa) );
    [tmp meshes{i}.InitialLabels] = min( meshes{i}.NLOGW{ UNARY_POS } );    
    meshes{i}.unaryErr = sum( ( meshes{i}.InitialLabels' ~= meshes{i}.L ) .* meshes{i}.Fa' );     
    unaryErr = [unaryErr; meshes{i}.unaryErr];
end

NLOGW = load( EDGESNLOGW_FILE );
ii = 1;
for i=1:length(meshes)
    meshes{i}.NLOGW{ ADABOOST_EDGE_POS } = single( NLOGW(ii:ii+3*size(meshes{i}.F, 2)-1, 4:5) );
    meshes{i}.NLOGW{ ADABOOST_EDGE_POS } = min( meshes{i}.NLOGW{ ADABOOST_EDGE_POS }, -log(EPSILON) );      
    meshes{i}.adjF = sparse( size(meshes{i}.F,2), size(meshes{i}.F,2) );
    adjI = NLOGW(ii:ii+3*size(meshes{i}.F, 2)-1, 2)+1; 
    adjJ = NLOGW(ii:ii+3*size(meshes{i}.F, 2)-1, 3);
    meshes{i}.ffi = adjI + adjJ*size(meshes{i}.F,2);
    meshes{i}.adjF( meshes{i}.ffi ) = 1;
    ii = ii + size(meshes{i}.F, 2)*3;    
end



if ~isempty( CVmeshes )
    NLOGW = load( CVNLOGW_FILE );
    ii = 1;
    for f=1:length( FEATURE_ORDER )
        for i=1:length(CVmeshes)
            CVmeshes{i}.NLOGW{ FEATURE_ORDER(f) } = single( NLOGW(ii:ii+size(CVmeshes{i}.F, 2)-1, 3:3+numlabels-1) );
            ii = ii + size(CVmeshes{i}.F, 2);
        end
    end
        
    for i=1:length(CVmeshes)
        CVmeshes{i}.NLOGW{ UNARY_POS } = zeros( numlabels, size(CVmeshes{i}.NLOGW{FEATURE_ORDER(1)}, 1) );        
        for f=1:length( FEATURE_ORDER )
            CVmeshes{i}.NLOGW{ UNARY_POS } = CVmeshes{i}.NLOGW{ UNARY_POS } + CVmeshes{i}.NLOGW{ FEATURE_ORDER(f) }';
        end
        CVmeshes{i}.NLOGW{ UNARY_POS } = scale_cols( CVmeshes{i}.NLOGW{ UNARY_POS }, CVmeshes{i}.Fa / median( CVmeshes{i}.Fa) );
        CVmeshes{i}.NLOGW{ UNARY_POS } = min( CVmeshes{i}.NLOGW{ UNARY_POS }, -log(EPSILON) );       
        [tmp CVmeshes{i}.InitialLabels] = min( CVmeshes{i}.NLOGW{ UNARY_POS } );        
        CVmeshes{i}.unaryErr = sum( (CVmeshes{i}.InitialLabels' ~= CVmeshes{i}.L ) .* CVmeshes{i}.Fa' );       
        unaryErr = [unaryErr; CVmeshes{i}.unaryErr];        
    end
    
    NLOGW = load( CVEDGESNLOGW_FILE );
    ii = 1;
    for i=1:length(CVmeshes)
        CVmeshes{i}.NLOGW{ ADABOOST_EDGE_POS } = single( NLOGW(ii:ii+3*size(CVmeshes{i}.F, 2)-1, 4:5) );
        CVmeshes{i}.NLOGW{ ADABOOST_EDGE_POS } = min( CVmeshes{i}.NLOGW{ ADABOOST_EDGE_POS }, -log(EPSILON) );              
        CVmeshes{i}.adjF = sparse( size(CVmeshes{i}.F,2), size(CVmeshes{i}.F,2) );
        adjI = NLOGW(ii:ii+3*size(CVmeshes{i}.F, 2)-1, 2)+1;
        adjJ = NLOGW(ii:ii+3*size(CVmeshes{i}.F, 2)-1, 3);
        CVmeshes{i}.ffi = adjI + adjJ*size(CVmeshes{i}.F,2);
        CVmeshes{i}.adjF( CVmeshes{i}.ffi ) = 1;
        ii = ii + size(CVmeshes{i}.F, 2)*3;
    end
   end
else
% use your own classifier 
end