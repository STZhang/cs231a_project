function [d, t] = p3d_wallrel(cube, wall, wnrm, op)
%P3D_WALLREL Computes the geometric relation between a cube and a wall
%
%   [d, t] = P3D_WALLREL(cube, wall, wnrm);
%   [d, t] = P3D_WALLREL(cube, wall, wnrm, 'plot');
%
%   Inputs:
%   - cube:     The cube structure
%   - wall:     The wall
%   - wnrm:     The normal direction of the wall
%
%   Outputs:
%   - d:        The distance from cube to wall
%   - t:        The relative orientation
%

%% verify input

to_plot = nargin >= 4 && strcmpi(op, 'plot');

%% get vertex coordinates

theta = cube.theta;
ct = cos(theta);
st = sin(theta);

cts = cube.centers;
cx = cts(1);
cz = cts(3);

dims = cube.dims;
xd = dims(1);
zd = dims(3);

bx = [xd/2, xd/2, -xd/2, -xd/2];
bz = [zd/2, -zd/2, -zd/2, zd/2];

px = (bx * ct + bz * st) + cx;   % 4-vec
pz = (bz * ct - bx * st) + cz;   % 4-vec

wx = wall(:,1).';
wz = wall(:,2).';
wcx = mean(wx);
wcz = mean(wz);

if to_plot
    figure;
    subplot(211);
    plot(wx, wz, 'r-');
    line([wcx wcx + cos(wnrm)], [wcz wcz + sin(wnrm)], 'Color', 'm'); 
    hold on;
    plot([px px(1)], [pz pz(1)], 'b-');
    axis equal;
end

% transfer to wall-centric coordinate systems

tparam = [wcx, wcz, wnrm];
[wx, wz] = trans(wx, wz, tparam);
wcx = mean(wx);
wcz = mean(wz);
[px, pz] = trans(px, pz, tparam);

% compute distance

whl = hypot(wx(2) - wx(1), wz(2) - wz(1)) / 2; % half length of wall
    
% ol is the overlap ratio of the projection on wall plane with wall
ol = line_overlap(-whl, whl, min(pz), max(pz));
if ol < 0.5
    d = inf;
else
    px_min = min(px);
    px_max = max(px);
    if px_min > 0
        d = px_min;
    elseif px_max < 0
        d = abs(px_max);
    else  % wall across the box
        d = 0;
    end
end 

% compute relative orientation

% test p(1) -- p(2) & p(2) -- p(3)

if abs(pz(2) - pz(1)) > abs(pz(3) - pz(2))
    zdiff = pz(2) - pz(1);
    xdiff = px(2) - px(1);
else
    zdiff = pz(3) - pz(2);
    xdiff = px(3) - px(2);
end
t = atan2(abs(xdiff), abs(zdiff));


if to_plot
    subplot(212);
    plot(wx, wz, 'r-');
    line([wcx wcx + 1], [wcz wcz], 'Color', 'm'); 
    hold on;
    plot([px px(1)], [pz pz(1)], 'b-');
    axis equal;
end


function [x, z] = trans(x, z, tparam)

cx = tparam(1);
cz = tparam(2);
t = tparam(3);

x = x - cx;
z = z - cz;

[x, z] = deal(x * cos(t) + z * sin(t), z * cos(t) - x * sin(t));


function u = line_overlap(a0, a1, b0, b1)

x0 = max(a0, b0);
x1 = min(a1, b1);
u = max(x1 - x0, 0) / (b1 - b0);





