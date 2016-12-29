function mesh = loadMesh(filestr)

fprintf(1, '\nReading %s..\n', filestr);
file = fopen(filestr, 'rt');
if file == -1
    error('Could not open mesh file');
end
mesh.filename = filestr;

if strcmp( filestr(end-3:end), '.off')
    % check, not sure if correct
    fgetl(file);
    line = strtrim(fgetl(file));
    [token,line] = strtok(line);
    numverts = eval(token);
    [token,line] = strtok(line);
    numfaces = eval(token);
    curvert = 0;
    curface = 0;
    mesh.V = zeros( 4, numverts, 'single' );
    mesh.F = zeros( 3, numfaces, 'single' );
    
    DATA = dlmread(filestr, ' ', 2, 0);
    DATA = DATA(1:numverts+numfaces, :);
    mesh.V(1:3, 1:numverts) = DATA(1:numverts, 1:3)';
    mesh.F(1:3, 1:numfaces) = DATA(numverts+1:numverts+numfaces, 2:4)' + 1;
elseif strcmp( filestr(end-3:end), '.obj')
    lines = cell(10^7, 1);
    i = 0;
    fprintf(1, '%.2f%% complete\n', 0.0);
    while ~feof(file)
        i = i + 1;
        lines{i} = fgets(file);
    end
    lines = lines(1:i);

    mesh.V = ones(4, length(lines), 'single');
    mesh.Nv = zeros(3, length(lines), 'single');
    mesh.F = zeros(3, length(lines), 'uint32');
    v = 0;
    f = 0;
    vn = 0;
    
    for i=1:length(lines)
        if mod(i, 3000) == 0
            fprintf(1, '%.2f%% complete\n', 100 * (i/length(lines)));
        end
        line = lines{i};
        if line(1) == 'v' && line(2) == 'n' 
            line = line(3:end);
            vn = vn + 1;
            [mesh.Nv(1, vn), line] = fnumtok(line);            
            [mesh.Nv(2, vn), line] = fnumtok(line);            
            mesh.Nv(3, vn) = fnumtokNR(line);  
        elseif line(1) == 'v'
            line = line(3:end);            
            v = v + 1;
            [mesh.V(1, v), line] = fnumtok(line);            
            [mesh.V(2, v), line] = fnumtok(line);            
            mesh.V(3, v) = fnumtokNR(line);            
        elseif line(1) == 'f' 
            line = line(3:end);
            f = f + 1;
            [token line] = strtok(line);
            mesh.F(1, f) = numtokNR(token);
            [token line] = strtok(line);
            mesh.F(2, f) = numtokNR(token);
            token = strtokNR(line);
            mesh.F(3, f) = numtokNR(token); 
        end
    end
    
    mesh.V = mesh.V(:, 1:v);
    mesh.F = mesh.F(:, 1:f);
    mesh.Nv = mesh.Nv(:, 1:v);
    fprintf(1, '%.2f%% complete\n', 100.0);        
end

fclose(file);

if size(mesh.F, 2) > 65535
    warning('It is strongly suggested not to use this mesh due to its size!');
end




function [token line] = strtok(line)
[token pos] = textscan(line, '%s', 1);
token = token{1}{1};
line = line(pos+1:end);

function [token line] = fnumtok(line)
[token pos] = textscan(line, '%f', 1);
token = token{1};
line = line(pos+1:end);

function [token line] = numtok(line)
[token pos] = textscan(line, '%d', 1);
token = token{1};
line = line(pos+1:end);


function token = strtokNR(line)
token = textscan(line, '%s', 1);
token = token{1}{1};

function token = fnumtokNR(line)
token = textscan(line, '%f', 1);
token = token{1};

function token = numtokNR(line)
token = textscan(line, '%d', 1);
token = token{1};
