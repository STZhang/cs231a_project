function hj_plot(im, hj)
%HJ_PLOT Plots the HJ boxes in 2D
%
%   HJ_PLOT(im, hj);
%
%   im:     scene image [480 x 640]
%   hj:     HJ cubes
%

imshow(im);

for i = 1 : size(hj.bnds, 1)
    hold on;
    plot_box(hj.bnds(i,:), hj.rot(:,:,i), hj.proj);    
end


function plot_box(b, TR, P)

minx = b(1);
miny = b(2);
minz = b(3);

maxx = b(4);
maxy = b(5);
maxz = b(6);

faces = cell(6, 1);

faces{1} = [minx minx minx minx minx
            miny miny maxy maxy miny
            minz maxz maxz minz minz];

faces{2} = [maxx maxx maxx maxx maxx
            miny miny maxy maxy miny
            minz maxz maxz minz minz];

faces{3} = [minx minx maxx maxx minx
            miny maxy maxy miny miny
            minz minz minz minz minz];

faces{4} = [minx minx maxx maxx minx
            miny maxy maxy miny miny
            maxz maxz maxz maxz maxz];

faces{5} = [minx minx maxx maxx minx
            miny miny miny miny miny
            minz maxz maxz minz minz];

faces{6} = [minx minx maxx maxx minx
            maxy maxy maxy maxy maxy
            minz maxz maxz minz minz];
     
cc = 'r';     

for i = 1 : 6
    T = P * [TR * faces{i}; ones(1, 5)];
    hold on;
    plot( T(1,:)./T(3,:), T(2,:)./T(3,:), 'color', cc, 'linewidth', 2);
end
     
