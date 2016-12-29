function YP = createCRFGraph(exparmsALL, mesh, K)
% heart of the project, used from trainLabelMeshes and testLabelMeshes.
% createsCRFGraph creates the CRF graph of the mesh and runs the graph-cut 
% alpha expansion from the GCMex package.

getGlobalVariables;

exparmsALL{CRF_MULT} = min( exparmsALL{CRF_MULT}, MAX_ALLOWED_EXPARM_VALUE );

% DataCost = exparmsALL{CRF_MULT}( ADABOOST_UNARY_MULT ) * mesh.NLOGW{ UNARY_POS };
DataCost = mesh.NLOGW{ UNARY_POS };
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Spatially invariant matrix
SmoothnessCost = exparmsALL{CRF_SPINV};
% SmoothnessCost = single( 1 - eye( size(exparmsALL{CRF_SPINV},1) ) );
% SmoothnessCost = single( [0 0.1 1; 0.1 0 1; 1 1 0] );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Spatially variant term
SparseSmoothness = mesh.adjF;
SparseSmoothness(mesh.ffi) = exparmsALL{CRF_MULT}( ADABOOST_EDGE_SPV_MULT ) * mesh.NLOGW{ADABOOST_EDGE_POS}(:, 2) +  (.25 + exparmsALL{CRF_MULT}( CONVEXITY_SPV_MULT )) * mesh.dh +  (1 + exparmsALL{CRF_MULT}( EDGELENGTH_SPV_MULT ));
SparseSmoothness(mesh.ffi) = mesh.el .* SparseSmoothness(mesh.ffi);

%SparseSmoothness(mesh.ffi) = exparmsALL{CRF_MULT}( ADABOOST_EDGE_SPV_MULT ) * mesh.NLOGW{ADABOOST_EDGE_POS}(:, 2) +  (.25 + exparmsALL{CRF_MULT}( CONVEXITY_SPV_MULT )) * mesh.dh +  (.5 + exparmsALL{CRF_MULT}( EDGELENGTH_SPV_MULT )) + (.65 + exparmsALL{CRF_MULT}( ADABOOST_VSI_MULT )) * mesh.vsi;
%    SparseSmoothness(mesh.ffi) = exparmsALL{CRF_MULT}( ADABOOST_EDGE_SPV_MULT ) * mesh.NLOGW{ADABOOST_EDGE_POS}(:, 2);

%SparseSmoothness(mesh.ffi) = exparmsALL{CRF_MULT}( ADABOOST_EDGE_SPV_MULT ) * mesh.NLOGW{ADABOOST_EDGE_POS}(:, 2) +  (.2 + exparmsALL{CRF_MULT}( CONVEXITY_SPV_MULT )) * mesh.dh +  (.4 + exparmsALL{CRF_MULT}( CONVEXITY_SPV_MULT )) + (.4 + exparmsALL{CRF_MULT}( EDGELENGTH_SPV_MULT )) * mesh.vsi;
%(.5 + exparmsALL{CRF_MULT}( EDGELENGTH_SPV_MULT )) * mesh.el + (.25 + exparmsALL{CRF_MULT}( CONVEXITY_SPV_MULT )) * mesh.el .* mesh.dh +
%
% SparseSmoothness(mesh.ffi) = exparmsALL{CRF_MULT}( ADABOOST_EDGE_SPV_MULT ) * mesh.NLOGW{ADABOOST_EDGE_POS}(:, 2) + exparmsALL{CRF_MULT}( EDGELENGTH_SPV_MULT ) * mesh.el + exparmsALL{CRF_MULT}( CONVEXITY_SPV_MULT ) * mesh.el .* mesh.dh;
% SparseSmoothness(mesh.ffi) = exparmsALL{CRF_MULT}( ADABOOST_EDGE_SPV_MULT ) * mesh.NLOGW{ADABOOST_EDGE_POS}(:, 2) + exparmsALL{CRF_MULT}( EDGELENGTH_SPV_MULT ) * mesh.el + exparmsALL{CRF_MULT}( CONVEXITY_SPV_MULT ) * mesh.dh;

% dh = min( (mesh.cx + pi) / pi, 1);
% SparseSmoothness(mesh.ffi) = exparmsALL{CRF_MULT}( ADABOOST_EDGE_SPV_MULT ) * mesh.NLOGW{ADABOOST_EDGE_POS}(:, 2) + exparmsALL{CRF_MULT}( EDGELENGTH_SPV_MULT ) * mesh.el .* dh.^exparmsALL{CRF_MULT}( CONVEXITY_SPV_MULT );


%% create graph
YP = GCMex( 0*mesh.InitialLabels, DataCost, SparseSmoothness, SmoothnessCost, 1);


% YP = GCMex( 0*mesh.InitialLabels, DataCost, SparseSmoothness, SmoothnessCost, 0);
% YP = GCMex( YP, DataCost, SparseSmoothness, SmoothnessCost, 1);


%YP = GCMex( mesh.InitialLabels-1, DataCost, SparseSmoothness, SmoothnessCost, 0);
% [YP1 ENERGY1 ENERGYAFTER1] = GCMex( 0*mesh.InitialLabels, DataCost, SparseSmoothness, SmoothnessCost, 0);
% [YP1 ENERGY1 ENERGYAFTER1] = GCMex( YP1, DataCost, SparseSmoothness, SmoothnessCost, 1);
% if ENERGYAFTER1 < ENERGYAFTER2
%     YP = YP1;
% else
%     YP = YP2;
% end
%[YP ENERGY ENERGYAFTER] = GCMex( mesh.InitialLabels-1, DataCost, SparseSmoothness, SmoothnessCost, 1);
    
%YP = GCMex( YP, DataCost, SparseSmoothness, SmoothnessCost, 0);
% YP = GCMex( YP, DataCost, SparseSmoothness, SmoothnessCost, 1);



