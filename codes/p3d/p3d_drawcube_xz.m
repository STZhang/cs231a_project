function p3d_drawcube_xz(cube, color)

%% main

hold on;

cx = cube.cx;
cz = cube.cz;

xd = cube.xd;
zd = cube.zd;

x0 = cx - xd / 2;
x1 = cx + xd / 2;
z0 = cz - zd / 2;
z1 = cz + zd / 2;

% lines along x
hx = [x0 x1, x0 x1, x0 x1, x0 x1];
hz = [z0 z0, z1 z1, z0 z0, z1 z1];

% lines along z
dx = [x0 x0, x0 x0, x1 x1, x1 x1];
dz = [z0 z1, z0 z1, z0 z1, z0 z1];

% merge
x0 = [hx dx];
z0 = [hz dz];

ct = cos(cube.theta);
st = sin(cube.theta);

x = x0 * ct + z0 * st;
z = - x0 * st + z0 * ct;

% insert nan
x = reshape([reshape(x, 2, 8); nan(1, 8)], 1, 24);
z = reshape([reshape(z, 2, 8); nan(1, 8)], 1, 24);

% draw

hold on;
plot(x, z, color, 'LineWidth', 2);

