function in3d_gtobjects(idx, op)
%IN3D_GTOBJECTS Generates ground-truth objects by min-bound cubes
%   
%   IN3D_GTOBJECTS(idx, op);
%
%   object labels use the latest 31-class label

to_plot = nargin >= 2 && strcmpi(op, 'plot');

datadir = '~/data/NYUv2';
srcdir = fullfile(datadir, 'rot_scenes');
outdir = fullfile(datadir, 'gtobjects_r');

if ~exist(outdir, 'dir')
    mkdir(outdir);
end

crmap = load(fullfile(datadir, 'class_reduce_map.mat'));
crmap = crmap.class_reduce_map;

if to_plot
    for i = 1 : length(idx)
        fprintf('Processing %d ...\n', idx(i));
        core_fun(outdir, srcdir, crmap, idx(i), to_plot);
        fprintf('\n');
    end
else        
    parfor i = 1 : length(idx)
        fprintf('Processing %d ...\n', idx(i));
        core_fun(outdir, srcdir, crmap, idx(i), to_plot);
        fprintf('\n');
    end
end


function core_fun(outdir, srcdir, crmap, idx, to_plot)

sc = load(fullfile(srcdir, sprintf('sc%04d.mat', idx)));
outfp = fullfile(outdir, sprintf('%04d.mat', idx));

% if exist(outfp, 'file')
%     return;
% end

if to_plot
    objects = p3d_fitcubes(sc, 'plot');    
else
    objects = p3d_fitcubes(sc);
end

n = length(objects);

is_valid = true(n, 1);
for i = 1 : n
    objects(i).label = crmap(objects(i).label);
    is_valid(i) = objects(i).label > 0;
end

objects = objects(is_valid);

save(outfp, 'objects');
