function box = p3d_projbox(scene, cube, op)
%P3D_PROJBOX Computes the bounding box of the projected cube
%
%   box = P3D_PROJBOX(scene, cube);
%       computes the bounding box of the projected cube
%
%       box is [xmin, xmax, ymin, ymax].
%   
%   box = P3D_PROJBOX(scene, cube, 'plot');
%

%% verify inputs

to_plot = nargin >= 3 && strcmpi(op, 'plot');

%% main

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

% all eight 3D vertices

xx = [x(1) x(4) x(2) x(3) x(1) x(4) x(2) x(3)];
zz = [z(1) z(4) z(2) z(3) z(1) z(4) z(2) z(3)];
yy = [y(1) y(1) y(1) y(1) y(2) y(2) y(2) y(2)];

% project

[ix, iy] = p3d_caliproj(scene.cali_theta, xx, yy, zz);
box = [min(ix), max(ix), min(iy), max(iy)];

if to_plot    
    imshow(scene.image);
    
    x0 = box(1);
    x1 = box(2);
    y0 = box(3);
    y1 = box(4);
    
    line([x0 x0 x1 x1 x0], [y0 y1 y1 y0 y0], 'Color', 'r', 'LineWidth', 2);
end


