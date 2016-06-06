function p3d_view(s, op)
%P3D_VIEW Creates a window to show a 3D scene
%
%   P3D_VIEW(s, 'depth') 
%       Shows the depth map using default color map.
%
%       s is a struct encapsulating a scene.
%
%   P3D_VIEW(s, 'rgbd')
%       Shows the depth map with RGBD texture
%
%   P3D_VIEW(s, 'labels')
%       Shows the depth map with label map
%
%   P3D_VIEW(s, 'world')
%       Shows the 3D point cloud in world coordinate framework
%
%   P3D_VIEW(s, 'rgb-world')
%       Shows the 3D point cloud with RGB texture.
%
%   P3D_VIEW(s, 'labels-world')
%       Shows the 3D point cloud colored with labels
%

%% parse input

if ~isstruct(s)
    error('The first argument should be a struct.');
end

if ~ischar(op)
    error('The second argument should be a string.');
end

switch lower(op)
    case 'depth'
        use_world = 0;
        use_map = 0;
    case 'rgbd'
        use_world = 0;
        use_map = 1;
    case 'labels'
        use_world = 0;
        use_map = 2;
    case 'world'
        use_world = 1;
        use_map = 0;
    case 'rgb-world'
        use_world = 1;
        use_map = 1;
    case 'labels-world'
        use_world = 1;
        use_map = 2;
    otherwise
        error('Invalid option %s', op)
end

%% main

im = s.image;
h = size(im, 1);
w = size(im, 2);
siz = [h, w];

if use_world
    wc = double(s.wcoords);
    x = reshape(wc(:,1), siz);
    y = reshape(wc(:,2), siz);
    z = reshape(wc(:,3), siz);
    az = -15;
    el = -50;    
else
    [x, y] = meshgrid(1:w, 1:h);
    z = double(s.depths);
    az = 0;
    el = -90;
end

if use_map
    if use_map == 1
        cdata = im;
    else
        cdata = label2rgb(s.labels);
    end
    
    surf(x, y, z, ...
        'FaceColor', 'texturemap', ...
        'EdgeColor', 'none', ...
        'CData', cdata);
    
    if use_world
        axis ij;
    end
    
else
    surf(x, y, z, 'EdgeColor', 'none');
end
    
view(az, el);
grid off;
       
if ~use_world
    set(gca, 'XLim', [0 w], 'YLim', [0 h]);
end

if use_world  % draw encompassing boxes
    xmin = min(x(:));
    xmax = max(x(:));
    ymin = min(y(:));
    ymax = max(y(:));
    zmin = min(z(:));
    zmax = max(z(:));
    draw_wframe([xmin ymin zmin], [xmax, ymax zmax]);
    
    set(gca, ...
        'XLim', [xmin xmax], 'YLim', [ymin ymax], 'ZLim', [zmin zmax]);
    
    if isfield(s, 'walls')
        for i = 1 : length(s.walls)
            draw_wall(s.walls{i}, ymin, ymax);
        end
    end
end


function draw_wframe(pt0, pt1)

x0 = pt0(1);
y0 = pt0(2);
z0 = pt0(3);

x1 = pt1(1);
y1 = pt1(2);
z1 = pt1(3);

% lines along x
hx = [x0 x1, x0 x1, x0 x1, x0 x1];
hy = [y0 y0, y0 y0, y1 y1, y1 y1];
hz = [z0 z0, z1 z1, z0 z0, z1 z1];

% lines along y
vx = [x0 x0, x0 x0, x1 x1, x1 x1];
vy = [y0 y1, y0 y1, y0 y1, y0 y1];
vz = [z0 z0, z1 z1, z0 z0, z1 z1];

% lines along z
dx = [x0 x0, x0 x0, x1 x1, x1 x1];
dy = [y0 y0, y1 y1, y0 y0, y1 y1];
dz = [z0 z1, z0 z1, z0 z1, z0 z1];

% merge
x = [hx vx dx];
y = [hy vy dy];
z = [hz vz dz];

% insert nan
x = reshape([reshape(x, 2, 12); nan(1, 12)], 1, 36);
y = reshape([reshape(y, 2, 12); nan(1, 12)], 1, 36);
z = reshape([reshape(z, 2, 12); nan(1, 12)], 1, 36);

hold on;
plot3(x, y, z, 'g-');


function draw_wall(w, y0, y1)

x0 = w(1);
z0 = w(2);
x1 = w(3);
z1 = w(4);

x = [x0 x0 x1 x1 x0];
z = [z0 z0 z1 z1 z0];
y = [y0 y1 y1 y0 y0];

hold on;
plot3(x, y, z, 'r-');



