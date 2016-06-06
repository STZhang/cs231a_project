function p3d_geoex_i(idx)
% lightweight wrapper pf p3d_geoextract
%

datadir = '~/data/NYUv2';
yfs = load(fullfile(datadir, 'yfloors.mat'));
yfs = yfs.yfloors;

gf_on(datadir, idx, yfs(idx));


function gf_on(datadir, idx, yf)

scenedir = fullfile(datadir, 'rot_scenes');
objdir = fullfile(datadir, 'gtobjects_a');
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

p3d_geoextract(sc, g.objects, walls, yf, 'plot');
