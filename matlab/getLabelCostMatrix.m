function C = getLabelCostMatrix(meshes, numlabels)
% used from trainLabelMeshes. Prepares the initial label-cost matrix and
% also checks if two adjacent labels are impossible in the meshes. 
% e.g. leg and head. 

getGlobalVariables;

C = 1 - eye( numlabels );
C(C==1) = MAX_EXPARM_VALUE*10000;
fprintf(1, '\nSetting up label cost (spatially invariant) matrix\n');

for i=1:length(meshes)
    fprintf(1, '%.2f percent complete\n', 100 * i / length(meshes));
    for j=1:size(meshes{i}.adjF, 1)
        adjfj = find( meshes{i}.adjF(j, :) );
        C( meshes{i}.L( j ), meshes{i}.L(adjfj) ) = 1; %#ok<FNDSB>
        
        %         for k=1:length(adjfj)
        %             if meshes{i}.L( j ) == meshes{i}.L( adjfj(k) )
        %                 continue;
        %             else
        %                 C( meshes{i}.L( j ), meshes{i}.L( adjfj(k) ) ) = 1;
        %             end
        %         end
    end
end

C = C .* (  1 - eye( numlabels ) );

C = single(C);