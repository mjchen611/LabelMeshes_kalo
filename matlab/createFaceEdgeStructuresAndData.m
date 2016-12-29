function mesh = createFaceEdgeStructuresAndData( mesh )
% used for trainLabelMeshes. Creates mesh.el, mesh.vsi, mesh.dh for using
% them in the CRF optimization

getGlobalVariables;
% output
% adjf:   adjacent face indices  nfx3 (NOT SPARSE)
% nf  :   face normals
% dh  :   transformed dihedral angles according to mesh.ffi order
% el  :   row edge lengths according to mesh.ffi order
% cx  :   row signed dihedral angles according to mesh.ffi order

mesh = faceNormals(mesh);
mesh.adjf = zeros( size(mesh.F, 2), 3 ); 
mesh.el = zeros(3*size(mesh.F, 2),1);
mesh.dh = zeros(3*size(mesh.F, 2),1);
mesh.cx = zeros(3*size(mesh.F, 2),1);
%mesh.vsi = zeros(3*size(mesh.F, 2),1);
%vsiData = dlmread( sprintf('%s_%s.txt', mesh.filename(1:end-4), 'vsi'), ' ', 1, 0);
%vsiData = vsiData(:, 1);

[adjI adjJ] = ind2sub( size(mesh.adjF), mesh.ffi );
j = 0;
for i=1:length(adjI)        
    fi = adjI(i);
    fj = adjJ(i);
    mesh.adjf(fi, mod(j,3)+1) = fj;
    j = j + 1;        

    vi = mesh.F(:, fi);
    vj = mesh.F(:, fj);            
    cv = [];    
    for k=1:3
        for l=1:3
            if vi(k) == vj(l)
                cv = [cv vi(k)];
            end
        end
    end
    if cv(1) == vi(1) && cv(2) == vi(3)
        cv(1) = vi(3);
        cv(2) = vi(1);
    end
    
    cosphi = sum( mesh.nf( :, fi ) .* mesh.nf( :, fj ) );
    sinphi = cross( mesh.nf( :, fi ), mesh.nf( :, fj ) );
    dihedralAngle = atan2( norm(sinphi), cosphi );
    edgeV = mesh.V(1:3, cv(2)) - mesh.V(1:3, cv(1));
    mesh.el(i) = norm(edgeV);    
    edgeV = edgeV / norm(edgeV);
    dihedralAngle = dihedralAngle * sign( sum( sinphi .* edgeV ) );
    mesh.cx(i) = dihedralAngle;
    dihedralAngle = dihedralAngle + pi;    
    mesh.dh(i) = dihedralAngle / pi;
    
%    mesh.vsi(i) = (vsiData(fi) + vsiData(fj))/2;
end

mesh.dh = -log( 1-min(mesh.dh,1) + EPSILON );
mesh.dh = max( mesh.dh, EPSILON );
mesh.el =  max( mesh.el / median( mesh.el ), EPSILON );
% mesh.vsi  = mesh.vsi - min(mesh.vsi) - .1;
% meanvsi = mean(mesh.vsi);
% mesh.vsi = max(mesh.vsi, EPSILON);
% mesh.vsi = min(mesh.vsi, meanvsi);
% mesh.vsi = mesh.vsi / max(mesh.vsi);
% mesh.vsi = 1 - mesh.vsi;
% mesh.vsi = -log(mesh.vsi + EPSILON);
% mesh.vsi = max(mesh.vsi, EPSILON);


end
      
  

function mesh = faceNormals(mesh)
mesh.nf = zeros(3, size(mesh.F,2));
mesh.nf(1:3,:) = cross(mesh.V(1:3,mesh.F(2,:)) - mesh.V(1:3,mesh.F(1,:)), mesh.V(1:3,mesh.F(3,:)) - mesh.V(1:3,mesh.F(1,:)));
for fi=1:size(mesh.F, 2)
    mesh.nf(:, fi) = mesh.nf(:, fi) / norm( mesh.nf(:, fi) );
end

end





% function mesh = createFaceEdgeStructuresAndData( mesh )
% getGlobalVariables;
% % output
% % adjf:   adjacent face indices  nfx3 (NOT SPARSE)
% % nf  :   face normals
% % dh  :   transformed dihedral angles according to mesh.ffi order
% % el  :   row edge lengths according to mesh.ffi order
% % cx  :   row signed dihedral angles according to mesh.ffi order
% 
% mesh = faceNormals(mesh);
% mesh.adjf = zeros( size(mesh.F, 2), 3 ); 
% mesh.el = zeros(3*size(mesh.F, 2),1);
% mesh.dh = zeros(3*size(mesh.F, 2),1);
% mesh.cx = zeros(3*size(mesh.F, 2),1);
% mesh.vsi = zeros(3*size(mesh.F, 2),1);
% 
% vsiData = dlmread( sprintf('%s_%s.txt', mesh.filename(1:end-4), 'vsiFeatures'), ' ', 1, 0);
% vsiData = vsiData(:, 6);    % median vsi
% edgeData = dlmread( sprintf('%s_%s.txt', mesh.filename(1:end-4), 'edgeFeatures'), ' ', 1, 0);
% edgeData = edgeData(:, 11); % median dihedral angle
% 
% 
% [adjI adjJ] = ind2sub( size(mesh.adjF), mesh.ffi );
% j = 0;
% for i=1:length(adjI)        
%     fi = adjI(i);
%     fj = adjJ(i);
%     mesh.adjf(fi, mod(j,3)+1) = fj;
%     j = j + 1;        
% 
%     vi = mesh.F(:, fi);
%     vj = mesh.F(:, fj);            
%     cv = [];    
%     for k=1:3
%         for l=1:3
%             if vi(k) == vj(l)
%                 cv = [cv vi(k)];
%             end
%         end
%     end
%     if cv(1) == vi(1) && cv(2) == vi(3)
%         cv(1) = vi(3);
%         cv(2) = vi(1);
%     end
%     
%     cosphi = sum( mesh.nf( :, fi ) .* mesh.nf( :, fj ) );
%     sinphi = cross( mesh.nf( :, fi ), mesh.nf( :, fj ) );
%     dihedralAngle = atan2( norm(sinphi), cosphi );
%     edgeV = mesh.V(1:3, cv(2)) - mesh.V(1:3, cv(1));
%     mesh.el(i) = norm(edgeV);    
% %     edgeV = edgeV / norm(edgeV);
% %     dihedralAngle = dihedralAngle * sign( sum( sinphi .* edgeV ) );
% %     mesh.cx(i) = dihedralAngle;
% %     dihedralAngle = dihedralAngle + pi;    
% %     mesh.dh(i) = dihedralAngle / pi;
%     
%     mesh.cx(i) = edgeData(i);    
%     mesh.vsi(i) = (vsiData(fi) + vsiData(fj))/2;
% end
% 
% mesh.dh = -log( 1-min(mesh.cx,1-EPSILON) );
% mesh.el =  mesh.el / median(  mesh.el );
% 
% end
%       
  

% function mesh = faceNormals(mesh)
% mesh.nf = zeros(3, size(mesh.F,2));
% mesh.nf(1:3,:) = cross(mesh.V(1:3,mesh.F(2,:)) - mesh.V(1:3,mesh.F(1,:)), mesh.V(1:3,mesh.F(3,:)) - mesh.V(1:3,mesh.F(1,:)));
% for fi=1:size(mesh.F, 2)
%     mesh.nf(:, fi) = mesh.nf(:, fi) / norm( mesh.nf(:, fi) );
% end
% 
% end



