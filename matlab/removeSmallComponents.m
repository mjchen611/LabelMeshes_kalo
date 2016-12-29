function [mesh CCid] = removeSmallComponents(mesh, threshold)

[CCid CCfa CCl] = getConnectedPartComponents(mesh);

for curCCid=1:max( CCid )
    if CCfa( curCCid ) / sum(CCfa) >= threshold( CCl(curCCid) )
        continue;
    end
    votesLabels = zeros( max(CCid), 1 );
    I = find( CCid == curCCid );
    
    for i=1:length(I)
        adjF = mesh.adjf(I(i), :);
        votesLabels( CCid( adjF ) ) = votesLabels( CCid( adjF ) ) + sum( mesh.Fa( adjF ) );
    end
    votesLabels( curCCid ) = 0;
    [tmp mergeCCid] = max( votesLabels );
    J = find( CCid == mergeCCid );
    mergeLabel = mesh.PL( J(1) );
    
    CCid( CCid == curCCid ) = mergeCCid;
    CCfa( mergeCCid ) = CCfa( mergeCCid ) + CCfa( curCCid );
    CCfa( curCCid ) = 0;
    mesh.PL( I ) = mergeLabel;    
end