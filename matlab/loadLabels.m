function [labels faceLabels] = loadLabels(filestr, mesh)
% mesh = loadObj('data\set1_toyCAD\train\rocker-arm.obj');
% [labels faceLabels] = loadLabels('data\set1_toyCAD\train\rocker-arm_labels.txt', mesh);

fprintf(1, '\nReading %s...', filestr);
file = fopen(filestr, 'rt');
labels = {};
faceLabels = [];

if file == -1
    fprintf(1, 'No such file exists. Skipping...\n');    
    return;
end

if ~isstruct(mesh)
    mesh = loadMesh(mesh);
end

i = 1;
while ~feof(file)
    labels(i).name = strtrim( fgets(file) );
    if feof(file)
        labels(i).name = [];
    end
    facesLine = fgets(file);
    facesLine = strtrim( facesLine );
    labels(i).faces = strsplit(facesLine, ' ');
    if isempty( labels(i).faces )
        labels(i).faces = [];
    end    
    i = i + 1;
end

faceLabels = zeros(size(mesh.F, 2), 1 );
for i=1:length(labels)
    faceLabels( labels(i).faces ) = i;
end

if ~isempty( find(faceLabels == 0) )
    labels(end+1).faces = find( faceLabels == 0 );
    labels(end).name = 'void';
end

fclose(file);
fprintf(1, 'Done.\n');
