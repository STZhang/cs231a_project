function p3d_floorplan_i(idx)
% a lightweight wrapper of p3d_floorplan

if isscalar(idx)
    fp_on(idx);
else
    for i = 1 : length(idx)
        fprintf('On scene %04d\n', idx(i));
        fp_on(idx(i));
        hg = gcf;
        set(hg, 'Name', sprintf('%04d', idx(i)));
        pause;
        close(hg);
    end
end


function fp_on(idx)


datadir = '~/data/NYUv2';

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

p3d_floorplan(sc, g.objects, walls, 'plot');
