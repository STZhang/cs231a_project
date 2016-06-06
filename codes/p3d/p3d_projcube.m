function p3d_projcube(scene, cube, color)
%P3D_PROJCUBE Plots a projected cube on image plane
%
%   P3D_PROJCUBE(scene, cube);
%

%% main

hold on;

theta = cube.theta;
ct = cos(theta);
st = sin(theta);

cts = cube.centers;
cx = cts(1);
cy = cts(2);
cz = cts(3);

dims = cube.dims;
xd = dims(1);
yd = dims(2);
zd = dims(3);

bx = [xd/2, xd/2, -xd/2, -xd/2];
bz = [zd/2, -zd/2, -zd/2, zd/2];

x = (bx * ct + bz * st) + cx;
z = (bz * ct - bx * st) + cz;
y = [-yd/2, yd/2] + cy;

% 3D lines

hx = [x(1) x(4) nan, x(2) x(3) nan, x(1) x(4) nan, x(2) x(3) nan];
hz = [z(1) z(4) nan, z(2) z(3) nan, z(1) z(4) nan, z(2) z(3) nan];
hy = [y(1) y(1) nan, y(1) y(1) nan, y(2) y(2) nan, y(2) y(2) nan];

dx = [x(1) x(2) nan, x(3) x(4) nan, x(1) x(2) nan, x(3) x(4) nan];
dz = [z(1) z(2) nan, z(3) z(4) nan, z(1) z(2) nan, z(3) z(4) nan];
dy = [y(1) y(1) nan, y(1) y(1) nan, y(2) y(2) nan, y(2) y(2) nan];

vx = [x(1) x(1) nan, x(2) x(2) nan, x(3) x(3) nan, x(4) x(4) nan];
vz = [z(1) z(1) nan, z(2) z(2) nan, z(3) z(3) nan, z(4) z(4) nan];
vy = [y(1) y(2) nan, y(1) y(2) nan, y(1) y(2) nan, y(1) y(2) nan];

% merge

px = [hx vx dx];
py = [hy vy dy];
pz = [hz vz dz];

if isfield(scene, 'cali_theta')
    [ix, iy] = p3d_caliproj(scene.cali_theta, px, py, pz);
elseif isfield(scene, 'rot')
    [ix, iy] = p3d_caliproj(scene.rot, px, py, pz);
else
    error('The scene contains no calibration information');
end

% draw

hold on;
plot(ix, iy, color, 'LineWidth', 2);


