function p3d_drawcube(cube, color)
%P3D_DRAWBOX Draws a 3D cube
%
%   P3D_DRAWCUBE(cube, color);
%
%       It draws a 3D cube using specified color on the current axis.
%       

%% main

if isscalar(cube)
    draw_one_cube(cube, color);
else
    for i = 1 : length(cube)
        draw_one_cube(cube(i), color);
    end
end


%% core function

function draw_one_cube(cube, color)

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

% lines

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

% draw

hold on;
plot3(px, py, pz, color, 'LineWidth', 3);

