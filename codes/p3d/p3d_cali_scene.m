function sr = p3d_cali_scene(idx, op)
%P3D_CALI_SCENE Performs Scene calibration and generates new scene structs
%
%   P3D_CALI_SCENE(idx);
%   P3D_CALI_SCENE(idx, 'plot');
%

to_plot = nargin >= 2 && strcmpi(op, 'plot');

%% Load files

datadir = '~/data/NYUv2';

% scene data
s = load(fullfile(datadir, 'scenes', sprintf('s%04d.mat', idx)));

% reference frame
rf = load(fullfile(datadir, 'rf', sprintf('rf%04d.mat', idx)));

% normal vectors
% nrmvecs = load(fullfile(datadir, 'nrmvecs', sprintf('nv%04d.mat', idx)));
% nrmvecs = nrmvecs.nrmvecs;

cmsk = p3d_cleanmask(s);

% curated labelmap

cls = load(fullfile(datadir, 'classes.mat')); 
Lmap = zeros(1000, 1);
Lmap(1:length(cls.labelmap)) = cls.labelmap;

%% main

theta = find_prin_orient(rf.ps);

x = s.wcoords(:,1);
y = s.wcoords(:,2);
z = s.wcoords(:,3);

% transform coordinate

ct = cos(theta);
st = sin(theta);

xr = x * ct - z * st;
yr = y;
zr = z * ct + x * st;

sr = s;
sr.wcoords = [xr yr zr];
sr.cali_theta = theta;

% re-map labels

sr.origin_labels = s.labels;

poslabels = find(s.labels);
sr.labels(poslabels) = Lmap(s.labels(poslabels));

% transform walls

nwalls = length(rf.ps);
walls = cell(1, nwalls);
for i = 1 : nwalls
    walls{i} = make_wall(rf.ps{i}, theta);
end
sr.walls = walls;

% write file

dstfile = fullfile(datadir, 'cali_scenes', sprintf('sc%04d.mat', idx));
save(dstfile, '-struct', 'sr');

%% plot

if to_plot
    clear sr;
    sr = load(dstfile);
    p3d_cali_view(sr);
end


%% sub functions

function theta = find_prin_orient(ps)

p = ps{1};
len = hypot(p(2,1) - p(1,1), p(2,2) - p(1,2));

if length(ps) >= 2
    for i = 1 : length(ps)
        pi = ps{i};
        len_i = hypot(pi(2,1) - pi(1,1), pi(2,2) - pi(1,2));
        if len_i > len
            p = pi;
            len = len_i;
        end
    end
end

dx = p(2,1) - p(1,1);
dz = p(2,2) - p(1,2);
theta = atan2(-dz, dx);

function w = make_wall(p, theta)

ct = cos(theta);
st = sin(theta);

px0 = p(1,1); pz0 = p(1,2);
px1 = p(2,1); pz1 = p(2,2);

rx0 = px0 * ct - pz0 * st;
rz0 = pz0 * ct + px0 * st;

rx1 = px1 * ct - pz1 * st;
rz1 = pz1 * ct + px1 * st;

w = [rx0 rz0 rx1 rz1];

