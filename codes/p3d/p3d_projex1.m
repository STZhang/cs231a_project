function p3d_projex1()
%P3D_PROJEX1 Demos the use of p3d_projcube.

datadir = '~/data/NYUv2';

sc = load(fullfile(datadir, 'cali_scenes/sc0001.mat'));
g = load(fullfile(datadir, 'gtobjects/0001.mat'));

imshow(sc.image);
hold on;

for i = 1 : length(g.objects)
    p3d_projcube(sc, g.objects(i).cube, 'r');
end
