function cube = p3d_minbndcube(x, y, z, p)
%P3D_MINBNDCUBE Finds minimum bounding box for a set of points
%
%   cube = P3D_MINBNDBOX(x, y, z, p);
%
%   x, y, z:    3D coordinates
%   p:          the ratio of points that is allowed to be outside
%

if nargin < 4
    p = 0.1;
end

fun = @(t) objv_func(t, x, z, p);

opts = psoptimset('Display', 'none');
theta = patternsearch(fun, 0, [], [], [], [], -pi/2, pi/2, opts);

[~, xq, zq] = objv_func(theta, x, z, p);

yq = quantile(y, [0.02, 0.98]);

ct = cos(theta);
st = sin(theta);

rx = xq * ct + zq * st;
rz = zq * ct - xq * st;
ry = yq;

cube.dims = [xq(2) - xq(1), yq(2) - yq(1), zq(2) - zq(1)];
cube.centers = [mean(rx), mean(ry), mean(rz)];
cube.theta = theta;


function [v, xq, zq] = objv_func(theta, x, z, p)
    
ct = cos(theta);
st = sin(theta);

xt = x * ct - z * st;
zt = x * st + z * ct;

xq = quantile(xt, [p/2, 1-p/2]);
zq = quantile(zt, [p/2, 1-p/2]);

v = (xq(2) - xq(1)) * (zq(2) - zq(1));
        