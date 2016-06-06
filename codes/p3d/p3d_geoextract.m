function G = p3d_geoextract(scene, objs, walls, yf, op)
%P3D_GEOEXTRACT Extracts geometric information of objects
%
%   G = P3D_GEOEXTRACT(scene, objs, walls, yf);
%
%   G is a struct array with n elements, (n is the number of objects
%   in the scene).
%
%   Each element of G has the following fields:
%   - label:        the object label
%   - height:       in meters
%   - lwidth:       the longer width (along x or z)
%   - swidth:       the shorter width (along x or z)
%   - haspect:      horizontal aspect ratio (lwidth / height)
%   - vaspect:      vertical aspect ratio (lwidth / swidth)
%   - area:         the ground area
%   - vol:          the volume
%
%   - iwall:        the index of the nearest wall
%   - wallrad:      the radian relative to the nearest wall
%   - walldist:     the distance to the nearest wall
%   - grounddist:   the distance to the ground 
%
%   G = P3D_GEOEXTRACT(scene, objs, walls, yf, 'plot');
%
%       Additionally plot the results.
%

%% verify inputs

to_plot = nargin >= 5 && strcmpi(op, 'plot');

%% main

if isempty(objs)
    G = [];    
    to_plot = false;
else          
    fp = p3d_floorplan(scene, objs, walls); 
    
    nobjs = numel(objs);
    G = cell(nobjs, 1); 
    for i = 1 : nobjs
        o = objs(i);
        if ~isempty(o.cube)
            G{i} = geofea(o.label, o.cube, walls, fp.wall_nrms, yf);
        end
    end
end

if to_plot       
    xmin = fp.xmin;
    xmax = fp.xmax;
    zmin = fp.zmin;
    zmax = fp.zmax;
    
    % plot scene boundary
    
    plot([xmin xmin xmax xmax xmin], [zmax zmin zmin zmax zmax], 'g-');    
        
    % plot walls
    
    for i = 1 : length(walls)
        draw_wall(walls{i}, fp.wall_nrms(i,:));
    end
    
    % plot objects
    
    for i = 1 : length(objs)
        if ~isempty(G{i})
            draw_obj(objs(i).cube, G{i});            
        end
    end
    
    mg = 0.1;
    rgn = [ ...
        xmin - (xmax - xmin) * mg, ...
        xmax + (xmax - xmin) * mg, ...
        zmin - (zmax - zmin) * mg, ...
        zmax + (zmax - zmin) * mg ];
    axis(rgn);
    axis equal;
    
    xlabel('x');
    ylabel('z');        
end

%% core

function g = geofea(label, cube, walls, wnrm, yf)

cts = cube.centers;
cy = cts(2);

dims = cube.dims;
xd = dims(1);
yd = dims(2);
zd = dims(3);

g = [];
g.label = label;

% basic geometric features

g.height = yd;
if xd > zd
    g.lwidth = xd;
    g.swidth = zd;
else
    g.lwidth = zd;
    g.swidth = xd;
end
g.haspect = g.lwidth / g.height;
g.vaspect = g.lwidth / g.swidth;
g.area = xd * yd;
g.vol = xd * yd * zd;

% wall-relation

g.iwall = 0;
g.wallrad = 0;
g.walldist = inf;

for i = 1 : length(walls)
    [d, t] = p3d_wallrel(cube, walls{i}, wnrm(i));
    if isfinite(d) && d < g.walldist
        g.iwall = 0;
        g.wallrad = t;
        g.walldist = d;
    end
end

% floor-relation

bottom = cy - yd/2;
g.grounddist = max(bottom - yf, 0);


function draw_obj(cube, g)

theta = cube.theta;
ct = cos(theta);
st = sin(theta);

cts = cube.centers;
cx = cts(1);
cz = cts(3);

dims = cube.dims;
xd = dims(1);
zd = dims(3);

bx = [xd/2, xd/2, -xd/2, -xd/2, xd/2];
bz = [zd/2, -zd/2, -zd/2, zd/2, zd/2];

x = (bx * ct + bz * st) + cx;
z = (bz * ct - bx * st) + cz;
line(x, z, 'Color', 'b', 'LineWidth', 2);

text(cx, cz, sprintf('d=%.3f\nr=%.3f\ng=%.3f', ...
    g.walldist, g.wallrad, g.grounddist)); 



function draw_wall(w, wnrm)

line(w(:,1), w(:,2), 'Color', 'r', 'LineWidth', 2);

dx = cos(wnrm);
dz = sin(wnrm);

cx = mean(w(:,1));
cz = mean(w(:,2));

line([cx cx + dx], [cz, cz + dz], 'Color', 'm', 'LineWidth', 1);

