function yf = p3d_yfloor(scene)
%P3D_YFLOOR Computes the y-coordinates of floor
%
%   yf = P3D_YFLOOR(scene);
%
%       scene is a calibrated scene struct, where y-axis is calibrated
%       to gravity.
%
%       It also assumes that label 1 indicates floor.
%

%% main

y = scene.wcoords(scene.labels(:) == 1, 2);

if ~isempty(y)    
    yi = linspace(min(y), max(y), 2000);
    f = ksdensity(y, yi, 'width', 0.01);
    
    ym = p3d_nms1d(f, 100, 0);
    i = find(ym, 1);
    yf = yi(i);
    
    figure;
    plot(yi, f);
    hold on;
    plot([yf yf], [0, f(i)], 'r-', 'LineWidth', 2);
else
    yf = min(scene.wcoords(:,2));
end

figure;
p3d_view(scene, 'rgb-world');
x = scene.wcoords(:,1);
z = scene.wcoords(:,3);
xmin = min(x);
xmax = max(x);
zmin = min(z);
zmax = max(z);
hold on;
plot3([xmin xmin xmax xmax xmin], yf * ones(1, 5), ...
    [zmin zmax zmax zmin zmin], 'r-', 'LineWidth', 2);

