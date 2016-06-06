function [so, oo] = in3d_cotables(Ks, Ko, scenes)
%IN3D_COTABLES Compute co-occurrence tables for scenes
%
%   [so, oo] = IN3D_COTABLES(Ks, Ko, scenes)
%
%       Ks:     the number of scene classes
%       Ko:     the number of object classes
%       scenes: a collection of scenes represented by a struct array.
%
%       This function generates two tables: 
%
%       The scene-object table so, where so(k, i) is the number of times
%       object of class i appears in a scene of class k.
%
%       The object-object table oo, where oo(i, j) is the number of times
%       object i and object j co-exist in the same scene.
%

%% main

ns = numel(scenes);

so = zeros(Ks, Ko);
oo = zeros(Ko, Ko);

for i = 1 : ns
    s = scenes(i);
    objs = s.objects;
    
    k = s.scene_label;
    ni = numel(objs);
    
    % scene-object
    
    for j = 1 : ni
        o = objs(j).object_label;
        so(k, o) = so(k, o) + 1;
    end
    
    % object-object
   
    M = zeros(Ko, Ko);
    
    for j1 = 1 : ni
        for j2 = 1 : ni
            if j1 ~= j2
                o1 = objs(j1).object_label;
                o2 = objs(j2).object_label;
            
                M(o1, o2) = 1; 
            end
        end
    end    
    oo = oo + M;    
end


