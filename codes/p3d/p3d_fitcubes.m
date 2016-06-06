function objects = p3d_fitcubes(s, op)
%P3D_FITCUBES Fit cubes for a labeled scene
%
%   objects = P3D_FITBOXES(s);
%       
%       Fits all cubes to a labeled scene (given by the struct s).
%
%   objects = P3D_FITBOXES(s, 'plot');
%
%       Draws fitted cubes
%


%% parse input

assert(isstruct(s) && isscalar(s));

to_plot = nargin >= 2 && strcmpi(op, 'plot');

%% main

assert(max(s.instance(:)) < 100);

L = double(s.origin_labels) * 100 + double(s.instance);

u = unique(L);
nobjs = length(u);
objects = cell(nobjs, 1);

h = size(s.image, 1);
w = size(s.image, 2);

cmsk = p3d_cleanmask(s);

wcoords = double(s.wcoords);

for i = 1 : nobjs    
                
    % reset roi
    si = find(cmsk & (L == u(i)));        
    if numel(si) < 1000
        continue;
    end
    
    ll = s.labels(si);
    assert(all(ll == ll(1)));  
    
    label = ll(1);
    if label <= 3  % preclude floor, ceil, and wall
        continue;
    end
    
    % fprintf('processing region with L = %d (label = %d) ...\n', u(i), label);
    
    x = wcoords(si, 1);
    y = wcoords(si, 2);
    z = wcoords(si, 3);
    
    cb = p3d_minbndcube(x, y, z);
    
    % make objects
    
    o = [];
    o.label = label;
    o.pixels = find(L == u(i));
    o.cube = cb;

    objects{i} = o;
end

objects = vertcat(objects{:});

% draw

if to_plot
    % cdata = s.image;
        
    figure;
    p3d_view(s, 'rgb-world');
    
    colors = {'b', 'g', 'r', 'c', 'm'};
    
    for i = 1 : length(objects)
        o = objects(i);
        color = colors{mod(o.label, length(colors)) + 1};
        p3d_drawcube(o.cube, color);
    end
end


