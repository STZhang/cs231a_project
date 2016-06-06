function bb = p3d_box2bb(cube)
% Return 2D bounding boxes (w.r.t. image plane)
%
%   bb = p3d_box2bb(cube);
%

P = cube.proj;
bb = zeros(cube.n, 4);
for i = 1 : cube.n
    bb(i, :) = proc(cube.bnds(i,:), cube.rot(:,:,i), P);
end

function rc = proc(bnds, rot, P)

x0 = bnds(1);
y0 = bnds(2);
z0 = bnds(3);
x1 = bnds(4);
y1 = bnds(5);
z1 = bnds(6);

pts = [ x0 y0 z0;
        x0 y0 z1;
        x0 y1 z0;
        x0 y1 z1;
        x1 y0 z0;
        x1 y0 z1;
        x1 y1 z0;
        x1 y1 z1 ].';
    
pc = P(:,1:3) * rot * pts;
u = pc(1,:) ./ pc(3,:);
v = pc(2,:) ./ pc(3,:);

umin = min(u);
umax = max(u);
vmin = min(v);
vmax = max(v);

rc = [umin umax vmin vmax];
    
