function p3d_viewobjs(scene, objs, op)
%P3D_VIEWOBJS Views the objects in a 3D framework
%
%   P3D_VIEWOBJS(scene, objs, '3d');
%
%   P3D_VIEWOBJS(scene, objs, '2d');
%

%% main

if strcmpi(op, '3d')
    figure;
    p3d_view(scene, 'rgb-world');
    
    for i = 1 : length(objs)
        if objs(i).has_cube
            p3d_drawcube(objs(i).cube, 'r');
        end
    end
        
elseif strcmpi(op, '2d')
    figure;
    imshow(scene.image);
    
    for i = 1 : length(objs)
        if objs(i).has_cube;
            p3d_projcube(scene, objs(i).cube, 'r');
        else
            bbox = objs(i).bndbox;
            x0 = bbox(1);
            x1 = bbox(2);
            y0 = bbox(3);
            y1 = bbox(4);
            line([x0 x0 x1 x1 x0], [y0 y1 y1 y0 y0], 'Color', 'b');            
        end
    end    
    
else
    error('Invalid option');
end


