function [CCid CCfa CCl mesh CCFaPerLabel] = getConnectedPartComponents(mesh, PL, numlabels)
f = 0;
curCCid = 1;
CCid = zeros( size(mesh.F, 2), 1);
if nargin == 1
    PL = mesh.PL;
    CCFaPerLabel = {};
end
if nargin == 2
    CCFaPerLabel = {};
end

CCl = [];
while true
    f = f + 1;    
    if f > size(mesh.F, 2)    
        break;
    end
    if CCid(f) > 0
        continue;
    end    
    CCid(f) = curCCid;
    curLabel = PL( f );
    CCl = [CCl curLabel];    
    q = [f];
    CCid( CCid < 0 ) = 0;
    
    while ~isempty(q)
        curf = q(1);
        q(1) = [];
        adjF = mesh.adjf(curf, :);
        for k=1:length(adjF)            
            if CCid( adjF(k) ) ~= 0
                continue;
            end
            if PL( adjF(k) ) ~= curLabel
                CCid( adjF(k) ) = -1;  
            else
                CCid( adjF(k) ) = curCCid;   
                q = [q adjF(k)];
            end            
        end                    
    end 
    
    curCCid = curCCid + 1;
end

numparts = max(CCid);
CCfa = zeros( numparts, 1 );
for i=1:numparts
    CCfa(i) = sum( mesh.Fa( CCid == i ) );
end
[tmp sortIndices] = sort( CCfa );
CCfa = CCfa(sortIndices);
CCl = CCl(sortIndices);

CCid_ = CCid;
for i=1:numparts
    CCid( CCid_ == sortIndices(i) ) = i; 
end

mesh.WF = zeros(size(mesh.F, 2), 1);
for i=1:size(mesh.F, 2)
    mesh.WF(i) = mesh.Fa(i) / CCfa( CCid(i) );
end

mesh.WF = mesh.WF / sum( mesh.WF );

if nargin == 3
    CCFaPerLabel{1} = nan(1, numlabels);
    CCFaPerLabel{2} = nan(1, numlabels);    
    for j=1:numlabels
        if ~isempty( CCfa( CCl == j) )
            CCFaPerLabel{1}(j) = min( CCfa( CCl == j) );
            CCFaPerLabel{2}(j) = max( CCfa( CCl == j) );            
        end
    end
end

