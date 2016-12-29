function mesh = faceAreas(mesh, normalizeAreas)

C = single( 0.5*(cross(mesh.V(1:3,mesh.F(2,:)) - mesh.V(1:3,mesh.F(1,:)), mesh.V(1:3,mesh.F(3,:)) - mesh.V(1:3,mesh.F(1,:)))) );
mesh.Fa = sqrt( sum( C(1:3, :) .* C(1:3,:) , 1) );

if exist('normalizeAreas', 'var') && normalizeAreas == true
    mesh.Fa = mesh.Fa / sum(mesh.Fa);
end

end
