function sr = p3d_rot_scene(R, idx, op)
%P3D_ROT_SCENE Rotates the scenes using provided rotation mat
%
%   P3D_ROT_SCENE(R, idx);
%   P3D_ROT_SCENE(R, idx, 'plot');
%

to_plot = nargin >= 3 && strcmpi(op, 'plot');

%% Load files

datadir = '~/data/NYUv2';
outdir = fullfile(datadir, 'rot_scenes');
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

% scene data
s = load(fullfile(datadir, 'scenes', sprintf('s%04d.mat', idx)));

% curated labelmap

cls = load(fullfile(datadir, 'classes.mat')); 
Lmap = zeros(1000, 1);
Lmap(1:length(cls.labelmap)) = cls.labelmap;

%% main

% transform coordinate

sr = s;

% old one: broken
% sr.wcoords = s.wcoords * R{idx}';

rot = R{idx};
sr.wcoords = rgb_plane2rgb_world(s.depths) * rot';
sr.rot = rot;

% re-map labels

sr.origin_labels = s.labels;

poslabels = find(s.labels);
sr.labels(poslabels) = Lmap(s.labels(poslabels));

% write file

dstfile = fullfile(outdir, sprintf('sc%04d.mat', idx));
save(dstfile, '-struct', 'sr');

%% plot

if to_plot
    clear sr;
    sr = load(dstfile);
    p3d_view(sr, 'rgb-world');
    view(160, -45);
end

