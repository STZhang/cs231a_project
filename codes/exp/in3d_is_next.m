function tf = in3d_is_next(o1, o2)
% test whether two objects are next to each other


cb1 = o1.cube;
cb2 = o2.cube;

[x2, z2] = trans(cb2);
[x2a, x2z] = rev_trans(cb1, x2, z2);
cx2a = mean(x2a);
cz2a = mean(x2z);

[x1, z1] = trans(cb1);
[x1a, x1z] = rev_trans(cb2, x1, z1);
cx1a = mean(x1a);

height_dis = abs(cb1.centers(2) - cb2.centers(2));
height_range_1 = cb1.dims(2)/2;
height_range_2 = cb2.dims(2)/2;
height_range = max([height_range_1 height_range_2]);

% result_1 
% tf = ~isempty(cb1) && ~isempty(cb2) && ...
%     p3d_gnddist(cb1, cb2) < 0.2 && ...
%     cb2.centers(2) > cb1.centers(2);

% result_2
% tf = ~isempty(cb1) && ~isempty(cb2) && ...
%     pt_in_rc_x(cb1, cx2a) && ...
%     height_dis < height_range;

% result_3
% if cb1.dims(1)>cb1.dims(3)
%     tf = pt_in_rc_x(cb1, cx2a);
% else
%     tf = pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_4
% tf = 180*abs(cb1.theta-cb2.theta)/pi<15;
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_5
% tf = p3d_gnddist(cb1, cb2) < 0.2;
% tf = tf && 180*abs(cb1.theta-cb2.theta)/pi<15;
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_6
% tf = p3d_gnddist(cb1, cb2) < 0.5;
% tf = tf && 180*abs(cb1.theta-cb2.theta)/pi<15;
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_7
% tf = p3d_gnddist(cb1, cb2) < 1;
% tf = tf && 180*abs(cb1.theta-cb2.theta)/pi<15;
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_8
% tf = p3d_gnddist(cb1, cb2) < 1.5;
% tf = tf && 180*abs(cb1.theta-cb2.theta)/pi<15;
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_9
% tf = p3d_gnddist(cb1, cb2) < 2;
% tf = tf && 180*abs(cb1.theta-cb2.theta)/pi<15;
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_10
% distance = p3d_gnddist(cb1, cb2);
% tf = distance < 2 && distance>0.2;
% tf = tf && 180*abs(cb1.theta-cb2.theta)/pi<15;
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_11
% distance = p3d_gnddist(cb1, cb2);
% tf = distance < 2 && distance>0.5;
% tf = tf && 180*abs(cb1.theta-cb2.theta)/pi<15;
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_12
% distance = p3d_gnddist(cb1, cb2);
% tf = distance < 2 && distance>0.8;
% tf = tf && 180*abs(cb1.theta-cb2.theta)/pi<15;
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_13
% distance = p3d_gnddist(cb1, cb2);
% tf = distance < 2.5 && distance>0.8;
% tf = tf && 180*abs(cb1.theta-cb2.theta)/pi<15;
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_14
% distance = p3d_gnddist(cb1, cb2);
% tf = distance < 2.5 && distance>0.5;
% tf = tf && 180*abs(cb1.theta-cb2.theta)/pi<15;
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_15
% distance = p3d_gnddist(cb1, cb2);
% tf = distance < 2 && distance>0.5;
% tf = tf && 180*abs(cb1.theta-cb2.theta)/pi<10;
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_16
% distance = p3d_gnddist(cb1, cb2);
% tf = distance < 2 && distance>0.5;
% tf = tf && 180*abs(cb1.theta-cb2.theta)/pi<20;
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_17
% distance = p3d_gnddist(cb1, cb2);
% tf = distance < 2 && distance>0.5;
% tf = tf && 180*abs(cb1.theta-cb2.theta)/pi<5;
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% % result_18
% distance = p3d_gnddist(cb1, cb2);
% tf = distance < 2 && distance>0.5;
% tf = tf && 180*abs(cb1.theta-cb2.theta)/pi<25;
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_19
% distance = p3d_gnddist(cb1, cb2);
% tf = distance < 2 && distance>0.5;
% 
% angle = 180*abs(cb1.theta-cb2.theta)/pi;
% tf = tf && (angle<13 || abs(angle-90)<13);
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_20
% distance = p3d_gnddist(cb1, cb2);
% tf = distance < 2 && distance>0.5;
% 
% angle = 180*abs(cb1.theta-cb2.theta)/pi;
% tf = tf && (angle<17 || abs(angle-90)<17);
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_21
distance = p3d_gnddist(cb1, cb2);
tf = distance < 2 && distance>0.5;

angle = 180*abs(cb1.theta-cb2.theta)/pi;
tf = tf && (angle<15 || abs(angle-90)<15);
if cb1.dims(1)>cb1.dims(3)
    tf = tf && pt_in_rc_x(cb1, cx2a);
else
    tf = tf && pt_in_rc_z(cb1, cz2a);
end
tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
    height_dis < height_range;

% result_22
% distance = p3d_gnddist(cb1, cb2);
% tf = distance < 2 && distance>0.5;
% 
% angle = 180*abs(cb1.theta-cb2.theta)/pi;
% tf = tf && (angle<15 || abs(angle-90)<15);
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < 2*height_range;

% result_23
% distance = p3d_gnddist(cb1, cb2);
% tf = distance < 2 && distance>0.5;
% 
% angle = 180*abs(cb1.theta-cb2.theta)/pi;
% tf = tf && (angle<15 || abs(angle-90)<15);
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a/2.0);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a/2.0);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;

% result_24
% distance = p3d_gnddist(cb1, cb2);
% tf = distance < 2 && distance>0.5;
% 
% angle = 180*abs(cb1.theta-cb2.theta)/pi;
% tf = tf && (angle<15 || abs(angle-90)<15);
% if cb1.dims(1)>cb1.dims(3)
%     tf = tf && pt_in_rc_x(cb1, cx2a*2.0);
% else
%     tf = tf && pt_in_rc_z(cb1, cz2a*2.0);
% end
% tf = tf && ~isempty(cb1) && ~isempty(cb2) && ...
%     height_dis < height_range;


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

function tf = pt_in_rc_x(cb, x)
% distance of points to a rectangle
%
% x, z are supposed to have been rev_trans w.r.t. cb

dims = cb.dims;
ex = dims(1) / 2;

dx = abs(x) - ex;
tf = dx < 0 ;

function tf = pt_in_rc_z(cb, z)
% distance of points to a rectangle
%
% z is supposed to have been rev_trans w.r.t. cb

dims = cb.dims;
ez = dims(3) / 2;

dz = abs(z) - ez;
tf = dz < 0 ;
