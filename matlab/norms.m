function Norms = norms(V)

Norms = sqrt(sum( V(1:3, :) .* V(1:3,:) , 1) );