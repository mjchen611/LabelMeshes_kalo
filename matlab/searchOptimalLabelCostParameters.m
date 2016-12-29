function [bestExparmsSPINV minf] = searchOptimalLabelCostParameters(exparms, meshes, K)
% used from trainLabelMeshes. Optimizes the label-dependent parameters. 
% not that great implementation. Using fminunc would be much better and slower...

getGlobalVariables;

tryValues = logspace(-2, 0.5, INITIAL_SEARCH_SPACE_VALUES*5);
validated = false(K, K);
bestExparmsSPINV = exparms{CRF_SPINV};

fprintf(1, '\nOptimizing label cost (spatially invariant) matrix\n');

minf = CRFTotalEnergy(exparms{CRF_MULT}, exparms, meshes, K);

tryCostMatrix = exparms{CRF_SPINV};
        
for i=1:K*K
    [m n] = ind2sub( [K K], i );
    if validated(m, n)
        continue;
    end
    if exparms{CRF_SPINV}(m, n) > 10 || m == n
        bestExparmsSPINV(n, m) = exparms{CRF_SPINV}(n, m);
        bestExparmsSPINV(m, n) = exparms{CRF_SPINV}(m, n);
        validated(m, n) = true;
        validated(n, m) = true;        
        continue;
    end
    validated(m, n) = true;
    
    try_exparms = cell(2,1);
    for v=tryValues
        tryCostMatrix(m, n) = v;
        tryCostMatrix(n, m) = v;
        try_exparms{CRF_MULT} = exparms{CRF_MULT};
        try_exparms{CRF_SPINV} = tryCostMatrix;
        f = CRFTotalEnergy(try_exparms{CRF_MULT}, try_exparms, meshes, K);
        if f <= minf
            minf = f;
            bestExparmsSPINV(m, n) = v;
            bestExparmsSPINV(n, m) = v;
        end
    end
    
    fprintf(1, '%.2f percent complete\n', 100*i / (K*K) );    
end
