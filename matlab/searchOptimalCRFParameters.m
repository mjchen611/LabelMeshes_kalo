function [bestExparms minf] = searchOptimalCRFParameters(exparmsALL, meshes, K, minf1)
% used from trainLabelMeshes. Optimizes CRF parameters \lambda,\mu,\kappa
% of the paper i.e. all the CRF paramters except to those learned by boosting
% (the label-dependent parameters are found from searchOptimalLabelCostParameters)

%% Function: get optimal CRF parameters

getGlobalVariables;
exparms = exparmsALL{CRF_MULT};

if nargin == 3
    combinationsWithRep = combn( 1:size(exparms, 1), size(exparms, 2) );
    bestCombination = 1;
    minf = Inf;
    for i=1:size(combinationsWithRep, 1)
        if ( mod(i, 20) == 0 )
            fprintf(1, '%.2f percent complete\n', 100 * i / length(combinationsWithRep));
        end
        try_exparms = exparms( combinationsWithRep(i, :) );
        f = CRFTotalEnergy(try_exparms, exparmsALL, meshes, K);
        if f < minf
            minf = f;
            bestCombination = i;
            disp(minf);
        end
    end
    bestExparms = exparms( combinationsWithRep(bestCombination, :) );   
    fprintf(1, '%.2f percent complete\n', 100 );    
else
    exparms_ = exparms;        
    minf = minf1;
    
    for i=1:5
        options = optimset('LargeScale','on', 'GradObj','on', 'MaxIter', TRAINING_ITERATIONS, 'TolFun',1e-4, 'TolX', 1e-4, 'Display', 'iter');
        [try_exparms try_minf] = fminunc(@(exparms) CRFTotalEnergy(exparms, exparmsALL, meshes, K, NUMERICAL_DERIV_DIFF_MAX /  (2^(i-1)) ), exparms, options);
        
        if (try_minf < minf)
            exparms = try_exparms;
            minf = try_minf;
        end        
    end
    
    if (minf >= minf1)                            
        exparms = exparms_;
    end
    
    bestExparms = exparms;
end
end
