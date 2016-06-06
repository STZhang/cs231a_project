function R = p3d_floorplan(scene, objs, walls, op)
%P3D_FLOORPLAN Analyzes the floor plan of a scene
%
%   R = P3D_FLOORPLAN(scene, objs);
%   R = P3D_FLOORPLAN(scene, objs, walls);
%
%   (R.mass_cx, R.mass_cz) is the object mass center of the room
%   R.wall_nrms:    The towards-interior normal direction of walls
%
%   R.xmin, xmax, zmin, zmax;
%

%% verify input

if nargin < 3
    walls = {};
end

to_plot = nargin >= 4 && strcmpi(op, 'plot');


%% main

wc = scene.wcoords;
x = wc(:,1);
z = wc(:,3);

R.xmin = min(x);
R.xmax = max(x);
R.zmin = min(z);
R.zmax = max(z);

% compute mass center

if isempty(objs)
    R.mass_cx = median(x);    
    R.mass_cz = median(z);
else
    tw = 0;
    mx = 0;
    mz = 0;
    for i = 1 : numel(objs)
        cb = objs(i).cube;
        if ~isempty(cb)
            a = sqrt(cb.dims(1) * cb.dims(3));
            tw = tw + a;
            mx = mx + a * cb.centers(1);
            mz = mz + a * cb.centers(3);
        end
    end
    R.mass_cx = mx / tw;
    R.mass_cz = mz / tw;
end

R.wall_nrms = [];

if ~isempty(walls)
    R.wall_nrms = zeros(numel(walls), 1);
    
    for i = 1 : numel(walls)
        wa = walls{i};
        dx = wa(2,1) - wa(1,1);
        dz = wa(2,2) - wa(1,2);
        nx = dz;
        nz = -dx;
        
        if abs(dx) > 3 * abs(dz) % nearly parallel to x
            if nz > 0
                nz = -nz;
                nx = -nx;
            end
        else            
            cx = mean(wa(:,1));
            cz = mean(wa(:,2));            
            if dot([R.mass_cx - cx, R.mass_cz - cz], [nx, nz]) < 0
                nx = -nx;
                nz = -nz;
            end                        
        end
        R.wall_nrms(i) = atan2(nz, nx);
    end        
end


if to_plot
    xmin = min(x);
    xmax = max(x);
    zmin = min(z);
    zmax = max(z);
    
    % plot scene boundary
    
    plot([xmin xmin xmax xmax xmin], [zmax zmin zmin zmax zmax], 'g-');
    
    % plot mass center
    
    plot(R.mass_cx, R.mass_cz, 'r+', 'LineWidth', 2, 'MarkerSize', 20);
        
    % plot walls
    
    for i = 1 : length(walls)
        draw_wall(walls{i}, R.wall_nrms(i,:));
    end
    
    % plot objects
    
    for i = 1 : length(objs)
        draw_obj(objs(i).cube);
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


function draw_obj(cube)

if isempty(cube)
    return;
end

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

hold on;
plot(cx, cz, 'b+');


function draw_wall(w, wnrm)

line(w(:,1), w(:,2), 'Color', 'r', 'LineWidth', 2);

dx = cos(wnrm);
dz = sin(wnrm);

cx = mean(w(:,1));
cz = mean(w(:,2));

line([cx cx + dx], [cz, cz + dz], 'Color', 'm', 'LineWidth', 1);


