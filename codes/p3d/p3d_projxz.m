function [H, cx, cz] = p3d_projxz(s)
%P3D_PROJXZ projects the point clouds onto the x-z plane accumulators
%

x = s.wcoords(:, 1);
z = s.wcoords(:, 3);

a = s.origin_labels(:);
a(a == 0) = 1;

wr = 0.05 * ones(1000, 1);
wr([21 87 123 800 28 59]) = 1; 

w = wr(a);

[H, cx, cz] = p3d_hist2d([512 512], x, z, w);

% DEBUG plot

% image(H * 5, 'CDataMapping', 'direct', 'XData', cx, 'YData', cz);
% colorbar;
% axis xy
% axis equal


