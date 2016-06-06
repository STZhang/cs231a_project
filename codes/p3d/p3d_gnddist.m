function d = p3d_gnddist(cb1, cb2)
%P3D_GNDDIST Computes ground-distance between two bounding boxes
%
%   P3D_GNDDIST(cb1, cb2)
%       


[x1, z1] = trans(cb1);
[x2, z2] = trans(cb2);

[x2a, z2a] = rev_trans(cb1, x2, z2);
[x1b, z1b] = rev_trans(cb2, x1, z1);

da = pt2rc(cb1, x2a, z2a);
db = pt2rc(cb2, x1b, z1b);
d = min(min(da), min(db));

% fprintf('d = %.4f\n', d);
% figure;
% draw_cubepair(x1, z1, x2, z2);

% [x1a, z1a] = rev_trans(cb1, x1, z1);
% figure;
% draw_cubepair(x1a, z1a, x2a, z2a);
% 
% [x2b, z2b] = rev_trans(cb2, x2, z2);
% figure;
% draw_cubepair(x1b, z1b, x2b, z2b);



function [x, z] = trans(cb)
% transform the coordinates or corners to floor plan coordinates


theta = cb.theta;
ct = cos(theta);
st = sin(theta);

cts = cb.centers;
cx = cts(1);
cz = cts(3);

dims = cb.dims;
xd = dims(1);
zd = dims(3);

bx = [xd/2, xd/2, -xd/2, -xd/2];
bz = [zd/2, -zd/2, -zd/2, zd/2];

x = (bx * ct + bz * st) + cx;
z = (bz * ct - bx * st) + cz;


function [xr, zr] = rev_trans(cb, x, z)

theta = cb.theta;
ct = cos(theta);
st = sin(theta);

cts = cb.centers;
cx = cts(1);
cz = cts(3);

x = x - cx;
z = z - cz;

xr = x * ct - z * st;
zr = z * ct + x * st;


function d = pt2rc(cb, x, z)
% distance of points to a rectangle
%
% x, z are supposed to have been rev_trans w.r.t. cb

dims = cb.dims;
ex = dims(1) / 2;
ez = dims(3) / 2;

dx = max(abs(x) - ex, 0);
dz = max(abs(z) - ez, 0);
d = hypot(dx, dz);


% function draw_cubepair(x1, z1, x2, z2)
% 
% line([x1 x1(1)], [z1 z1(1)], 'Color', 'r');
% line([x2 x2(1)], [z2 z2(1)], 'Color', 'b');
% axis equal;


