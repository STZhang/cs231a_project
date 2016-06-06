function Gs = in3d_gen_geos(objty)
%Generat all geometric analysis
%

datadir = in3d_datadir();
yfs = load(fullfile(datadir, 'yfloors.mat'));
yfs = yfs.yfloors;

fcls = load(fullfile(datadir, 'classes_final.mat'));

dstfp = fullfile(datadir, objty, 'geoinfo.mat');

n = 1449;
Gs = cell(1, n);

is_final = 1;
if strcmpi(objty, 'gt') 
    is_final = 0;
end

for i = 1 : n
    if mod(i, 50) == 0
        fprintf('Working on %d ...\n', i);
    end
    Gs{i} = gf_on(datadir, objty, i, yfs(i));
    
    for j = 1 : length(Gs{i})
        if ~isempty(Gs{i}{j})
            l = Gs{i}{j}.label;
            if ~is_final && l > 0
                Gs{i}{j}.label = fcls.reduced_to_final(l);
            end
        end
    end
end

save(dstfp, 'Gs');


function G = gf_on(datadir, objty, idx, yf)

scenedir = fullfile(datadir, 'rot_scenes');
objdir = in3d_getobjdir(datadir, objty);
walldir = fullfile(datadir, 'rf');

sc = load(fullfile(scenedir, sprintf('sc%04d.mat', idx)));
g = load(fullfile(objdir, sprintf('%04d.mat', idx)));

wfile = fullfile(walldir, sprintf('rf%04d.mat', idx));
if exist(wfile, 'file')
    walls = load(wfile);
    walls = walls.rf;
else
    walls = {};
end

G = p3d_geoextract(sc, g.objects, walls, yf);
