function cube = p3d_fitcube(wcoords, nrmvecs, op)
%P3D_FITCUBE Fits a cube to a subset of 3D points
%
%   cube = P3D_FITCUBE(wcoords, nrmvecs);
%
%       Finds a 3D cube (parallel to the floor) that encompasses
%       a 3D point set.
%
%       Inputs
%       -------
%       - wcoords:  the coordinates of the points (w.r.t. world frame)
%       - nrmvecs:  the normal vectors associated with these points.
%
%       If there are n points, then wcoords should be both n-by-3 matrices.
%
%   cube = P3D_FITCUBE(wcoords, nrmvecs, 'plot');
%       
%       additionally plots the fitting results.
%

%% parse input

if ~(isfloat(wcoords) && ismatrix(wcoords) && size(wcoords,2) == 3)
    error('wcoords must be an n-by-3 numeric matrix.');
end

if ~(isfloat(nrmvecs) && ismatrix(nrmvecs) && size(nrmvecs,2) == 3)
    error('nrmvecs must be an n-by-3 numeric matrix.');
end

if ~isa(wcoords, 'double')
    wcoords = double(wcoords);
end

if ~isa(nrmvecs, 'double')
    nrmvecs = double(nrmvecs);
end

to_plot = nargin >= 3 && strcmpi(op, 'plot');


%% main

% extract inputs

x = wcoords(:, 1);
y = wcoords(:, 2);
z = wcoords(:, 3);

nx = nrmvecs(:, 1);
ny = nrmvecs(:, 2);
nz = nrmvecs(:, 3);

% compute normal direction at each point

j = find(nz < 0);
nx(j) = -nx(j);
ny(j) = -ny(j);
nz(j) = -nz(j);

thetas = -atan2(nx, -nz);

weights_h = nx.^2 + nz.^2;
weights = weights_h ./ (weights_h + ny.^2);

% compute the major orientation

t = linspace(-pi, pi, 180);
f = ksdensity(thetas, t, 'weights', weights);
[~, fi] = max(f);
theta = t(fi);

% compute cube boundaries

ct = cos(theta);
st = sin(theta);
xt = x * ct - z * st;
yt = y;
zt = x * st + z * ct;

q = [0.05 0.95];
xq = quantile(xt, q);
yq = quantile(yt, q);
zq = quantile(zt, q);

% create cube struct

cube.cx = mean(xq);
cube.cy = mean(yq);
cube.cz = mean(zq);
cube.xd = xq(2) - xq(1);
cube.yd = yq(2) - yq(1);
cube.zd = zq(2) - zq(1);
cube.theta = theta;

% plot the results (upon request)

if to_plot
    figure;
    plot3(x, y, z, 'b.', 'MarkerSize', 10);
    hold on;
    p3d_drawcube(cube, 'g');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    view(0, 0);
end    
    

