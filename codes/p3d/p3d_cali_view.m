function p3d_cali_view(sr)
%P3D_CALI_VIEW Views a 3D calibrated scene
%
%   P3D_CALI_VIEW(sr);
%
%   sr is the calibrated scene struct
%

p3d_view(sr, 'rgb-world');
view(-15, -45);

y = sr.wcoords(:, 2);
y0 = min(y);
y1 = max(y);

for i = 1 : length(sr.walls)
    draw_wall(sr.walls{i}, y0, y1, 'r');
end

function draw_wall(w, y0, y1, color)

x0 = w(1);
z0 = w(2);
x1 = w(3);
z1 = w(4);

x = [x0 x1 x1 x0 x0];
y = [y0 y0 y1 y1 y0];
z = [z0 z1 z1 z0 z0];

hold on;
plot3(x, y, z, 'Color', color, 'LineWidth', 2);