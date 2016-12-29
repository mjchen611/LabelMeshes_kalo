%% Function: CRF Training
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f df err] = CRFTotalEnergy(exparms, exparmsALL, meshes, K, scale)
% used from trainLabelMeshes.
getGlobalVariables;
f = 0;

exparmsALL{CRF_MULT} = exp( exparms );
err = zeros(length(meshes), 1);
for i=1:length(meshes)
    YP = createCRFGraph(exparmsALL, meshes{i}, K);
    err(i) = sum( ( (YP+1) ~= meshes{i}.L ) .* meshes{i}.WF );
    f = f + (1 / length(meshes)) * err(i);
end

df = zeros(length(exparms), 1 );

if nargin == 4
    return;
end
    

for k=1:length(exparms)
    ff = 0;
    exparmsALL{CRF_MULT} = exp( exparms );
    exparmsALL{CRF_MULT}(k) = exparmsALL{CRF_MULT}(k) + scale;
    for i=1:length(meshes)
        YP = createCRFGraph(exparmsALL, meshes{i}, K);
        ff = ff + (1 / length(meshes)) * sum( ( (YP+1) ~= meshes{i}.L ) .* meshes{i}.WF );
    end
    df(k) = (ff - f) / scale;
    
    ff = 0;
    exparmsALL{CRF_MULT} = exp( exparms );
    scaleCor = min( exparmsALL{CRF_MULT}(k)-MIN_ALLOWED_EXPARM_VALUE, scale );    
    exparmsALL{CRF_MULT}(k) = exparmsALL{CRF_MULT}(k) - scaleCor;      
    for i=1:length(meshes)
        YP = createCRFGraph(exparmsALL, meshes{i}, K);
        ff = ff + (1 / length(meshes)) * sum( ( (YP+1) ~= meshes{i}.L ) .* meshes{i}.WF );
    end
    df(k) = (df(k) + (f - ff) / scaleCor)/2;    
end
