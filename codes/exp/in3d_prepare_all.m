function in3d_prepare_all(objty)
% Prepare everything needed for a experiment on a specific cube set
%
%   IN3D_PREPARE_ALL(objty);
%

datadir = in3d_datadir();
spl = load(fullfile(datadir, 'split.mat'));
tr = spl.train;
vl = spl.val;
try
tr = [tr; vl(1:end-150)];
vl = vl(end-150+1:end);
end;
tv = [spl.train; spl.val]; te = spl.test;

dstdir = fullfile(datadir, objty);
if ~exist(dstdir, 'dir')
    mkdir(dstdir);
end

display('Compiling ground-truths ...');
in3d_compilegts(objty);

display('Generating co-stats ...');
in3d_costats(objty);

display('Generating segmentation potentials ...');
in3d_segpots(objty);

display('Generating geometry features ...');
Gs = in3d_gen_geos(objty);
F = p3d_geofea(Gs, tr, vl, te);

cs = [0.05 0.1 0.2 0.5 1 10];
gs = [0.005 0.01 0.02 0.05 0.1 0.2 0.5 1];
[best, Pall] = in3d_geosvm(F, cs, gs);
geomodel_fp = fullfile(datadir, objty, 'geomodel.mat');
save(geomodel_fp, 'best', 'Pall');

load(fullfile(datadir, objty, 'ground_truths'));
pots = in3d_divpots(GTs, Pall);
geopot_fp = fullfile(datadir, objty, 'geopots.mat');
save(geopot_fp, 'pots');

display('Generating experiment dataset ...');
in3d_genset(objty);

