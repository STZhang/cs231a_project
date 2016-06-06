function p3d_drawbox(cube, color)
%DRAW CUBE as 2D box on x-z plane
%

x0 = cube.cx - cube.xd / 2;
x1 = cube.cx + cube.xd / 2;
z0 = cube.cz - cube.zd / 2;
z1 = cube.cz + cube.zd / 2;

% lines along x
x = [x0 x1, x0 x1, x0 x0, x1 x1];
z = [z0 z0, z1 z1, z0 z1, z0 z1];

ct = cos(-cube.theta);
st = sin(-cube.theta);

xt = x;
zt = z;

% xt = x * ct + z * st;
% zt = -x * st + z * ct;

% insert nan
xt = reshape([reshape(xt, 2, 4); nan(1, 4)], 1, 12);
zt = reshape([reshape(zt, 2, 4); nan(1, 4)], 1, 12);

line(xt, zt, 'Color', color, 'LineWidth', 2);

