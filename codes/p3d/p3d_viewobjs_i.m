function p3d_viewobjs_i(idx, op)
% A convenient wrapper of p3d_viewobjs
%
%   P3D_VIEWOBJS_I(idx, '3d')
%   P3D_VIEWOBJS_I(idx, '2d'):

datadir = '~/data/NYUv2';

scenedir = fullfile(datadir, 'rot_scenes');
objdir = fullfile(datadir, 'gtobjects_a');

sc = load(fullfile(scenedir, sprintf('sc%04d.mat', idx)));
g = load(fullfile(objdir, sprintf('%04d.mat', idx)));

p3d_viewobjs(sc, g.objects, op);

