function p3d_plot_normvecs(x, y, z, t, varargin)
%P3D_PLOT_NORMVECS Plots normal vectors at each point
%
%   P3D_PLOT_NORMVECS(x, y, z, t, ...);
%
%   Here, t is the orientations.
%

x = x(:);
y = y(:);
z = z(:);
t = t(:);

% set scale

cax = gca;
a = [get(cax,'xlim') get(cax,'ylim') get(cax,'zlim')];
Sx = a(2)-a(1);
Sy = a(4)-a(3);
Sz = a(6)-a(5);
scale = 0.1 / max([Sx,Sy,Sz]);
sx = Sx * scale; 
sy = Sy * scale; 
sz = Sz * scale;

% generate plot points using nan trick

dx = sx * sin(t);
dz = -sz * cos(t);

n = length(x);
xp = [x x + dx nan(n,1)];
yp = [y y nan(n,1)];
zp = [z z + dz nan(n,1)];

xp = xp.';
yp = yp.';
zp = zp.';

hold on;
plot3(xp(:), yp(:), zp(:), varargin{:});
