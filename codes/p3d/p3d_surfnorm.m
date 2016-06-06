function nrmvecs = p3d_surfnorm(s, op)

to_plot = nargin >= 2 && strcmpi(op, 'plot');

h = size(s.image, 1);
w = size(s.image, 2);
wc = double(s.wcoords);

x = wc(:,1);
y = wc(:,2);
z = wc(:,3);

x = reshape(x, [h w]);
y = reshape(y, [h w]);
z = reshape(z, [h w]);

di = [-1 0 1 -1 1 -1 0 1];
dj = [-1 -1 -1 0 0 1 1 1];

ci = 2 : h-1;
cj = 2 : w-1;

xc = x(ci, cj); xc = xc(:);
yc = y(ci, cj); yc = yc(:);
zc = z(ci, cj); zc = zc(:);

m = length(di);
nc = length(xc);

dX = zeros(nc, m);
dY = zeros(nc, m);
dZ = zeros(nc, m);

for k = 1 : m
    ik = ci + di(k);
    jk = cj + dj(k);
    
    xk = reshape(x(ik, jk), nc, 1);
    yk = reshape(y(ik, jk), nc, 1);
    zk = reshape(z(ik, jk), nc, 1);
    
    dX(:,k) = xk - xc;
    dY(:,k) = yk - yc;
    dZ(:,k) = zk - zc;
end

dX = dX.';
dY = dY.';
dZ = dZ.';

nvecs = zeros(3, nc);

for i = 1 : nc
    nvecs(:,i) = solve_normvec(dX(:,i), dY(:,i), dZ(:,i));
end

nx_c = nvecs(1,:).';
ny_c = nvecs(2,:).';
nz_c = nvecs(3,:).';

nx = zeros(h, w);
ny = zeros(h, w);
nz = zeros(h, w);
nx(ci, cj) = reshape(nx_c, h-2, w-2);
ny(ci, cj) = reshape(ny_c, h-2, w-2);
nz(ci, cj) = reshape(nz_c, h-2, w-2);

nrmvecs = cat(3, nx, ny, nz);

%% plot

if to_plot
    surf(x, y, z, 'EdgeColor', 'none');

    cax = gca;
    a = [get(cax,'xlim') get(cax,'ylim') get(cax,'zlim')];
    Sx = a(2)-a(1);
    Sy = a(4)-a(3);
    Sz = a(6)-a(5);
    scale = max([Sx,Sy,Sz]);
    Sx = 0.2 * Sx/scale; 
    Sy = 0.2 * Sy/scale; 
    Sz = 0.2 * Sz/scale;

    % plot a randomly sampled part

    if length(wc) > 5000
        si = randsample(length(xc), 000);
        nsi = length(si);
    else
        si = 1 : length(wc);
    end   

    xp = [xc(si) Sx*nx_c(si)+xc(si) nan(nsi, 1)]';
    yp = [yc(si) Sy*ny_c(si)+yc(si) nan(nsi, 1)]';
    zp = [zc(si) Sz*nz_c(si)+zc(si) nan(nsi, 1)]';

    hold on;
    plot3(xp(:),yp(:),zp(:),'k-');
    view(0, -90);
end

function nv = solve_normvec(dx, dy, dz)
% solve optimal normal vector

n = length(dx);
dv = [dx dy dz];
C = (dv' * dv) / n;

[V, D] = eig(C);
ev = diag(D);
[~, i] = min(ev);
nv = V(:,i);

