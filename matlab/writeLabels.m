function writeLabels(testmeshes, labels)
% writes labels + segment output files for testmeshes
% example: writeLabels(mytestmeshes, mytrainlabels)

slashPos = strfind( testmeshes{1}.filename, '\' );
slashPos = [slashPos strfind( testmeshes{1}.filename, '/' )];
baseDir = '';
if ~isempty(slashPos)
    baseDir = testmeshes{1}.filename(1:slashPos(1));
end


%% write labels for each file
fprintf(1, '\n\n\n*** Saving Labels per test mesh ***\n\n');
for i=1:length(testmeshes)
    slashPos = strfind( testmeshes{i}.filename, '\' );
    slashPos = [slashPos strfind( testmeshes{i}.filename, '/' )];
    baseFilename = testmeshes{i}.filename(slashPos(end)+1:end-4);
    slashPos = strfind( baseFilename, '_' );
    if ~isempty(slashPos)
        baseFilename = baseFilename(1:slashPos(1)-1);
    end    
    labelsFilename = sprintf('%s%s.lab', baseDir, baseFilename)
    file = fopen(labelsFilename, 'wt');
    for j=1:length(labels)
        fprintf(file, '%s\n', labels{j});
        fprintf(file, '%d ', find( testmeshes{i}.PL == j ) );   
        fprintf(file, '\n');
    end
    fclose(file);    
end

%% write seg for each file
fprintf(1, '\n\n\n*** Saving Labels per test mesh ***\n\n');
slashPos = strfind( testmeshes{1}.filename, '\' );
slashPos = [slashPos strfind( testmeshes{1}.filename, '/' )];
baseDir = '';
if ~isempty(slashPos)
    baseDir = testmeshes{1}.filename(1:slashPos(1));
end

for i=1:length(testmeshes)
    slashPos = strfind( testmeshes{i}.filename, '\' );
    slashPos = [slashPos strfind( testmeshes{i}.filename, '/' )];
    baseFilename = testmeshes{i}.filename(slashPos(end)+1:end-4);
    slashPos = strfind( baseFilename, '_' );
    if ~isempty(slashPos)
        baseFilename = baseFilename(1:slashPos(1)-1);
    end    
    segmentsFilename = sprintf('%s%s.seg', baseDir, baseFilename)
    file = fopen(segmentsFilename, 'wt');
    CCid = getConnectedPartComponents(  testmeshes{i} );
    fprintf(file, '%d\n', CCid-1 );
    fclose(file);    
end


%for i=1:length(testmeshes)
%    slashPos = strfind( testmeshes{i}.filename, '\' );
%    slashPos = [slashPos strfind( testmeshes{i}.filename, '/' )];    
%   baseFilename = testmeshes{i}.filename(slashPos(end)+1:end-4);
%   exportMesh( testmeshes{i}, sprintf('%s%s.off', baseDir, baseFilename));
%end
