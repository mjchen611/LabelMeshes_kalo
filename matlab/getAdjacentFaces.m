function mesh = getAdjacentFaces(mesh)
fprintf('\nComputing face adjacency...\n');

vertexToFace = cell( size(mesh.V, 2), 1 );
for i=1:size(mesh.F, 2)
    f = mesh.F(:, i);
    vertexToFace{ f(1) } = [vertexToFace{ f(1) } i];
    vertexToFace{ f(2) } = [vertexToFace{ f(2) } i];
    vertexToFace{ f(3) } = [vertexToFace{ f(3) } i];    
end

s = size(mesh.F, 2);
mesh.adjF = zeros(s, 3);
perms3 = perms([ 1 2 3]);

for i = 1:s % for all faces
    if (mod(i, 5000) == 0)
        fprintf('%.2f%% complete\n', 100 * i / s);
    end    
    f = mesh.F(:, i); % get current face
    fcv = unique( [ vertexToFace{ f(1) } vertexToFace{ f(2) } vertexToFace{ f(3)  } ] );  % get all faces sharing at least one vertex with it
    f = f(perms3)'; % get all combinations of vertices order
    
    adjf = [];
    for j=1:size(f, 2)
        fj = f(:, j);
        fj = fj(:, ones(length(fcv), 1));        
        adjF = sum( fj == mesh.F(:, fcv), 1) == 2; % if they have two common vertices at least
        adjf = [adjf fcv(adjF) ];
    end
    
    mesh.adjf(i, 1:3) = unique(  adjf );
end

mesh.adjf = uint32(  mesh.adjf );
