function tf = p3d_supports(o1, o2)

cb1 = o1.cube;
cb2 = o2.cube;

[x2, z2] = trans(cb2);
[x2a, z2a] = rev_trans(cb1, x2, z2);

cx2a = mean(x2a);
cz2a = mean(z2a);

tf = pt_in_rc(cb1, cx2a, cz2a) && cb1.centers(2) < cb2.centers(2);


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


function tf = pt_in_rc(cb, x, z)
% distance of points to a rectangle
%
% x, z are supposed to have been rev_trans w.r.t. cb

dims = cb.dims;
ex = dims(1) / 2;
ez = dims(3) / 2;

dx = abs(x) - ex;
dz = abs(z) - ez;
tf = dx < 0 && dz < 0;
