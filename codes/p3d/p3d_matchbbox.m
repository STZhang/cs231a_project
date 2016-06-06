function [o, r, ao, al] = p3d_matchbbox(gt, bbox, thr)
%P3D_MATCHBBOX Finds a matching object by bounding box
%
%   [o, r, ao] = P3D_MATCHBBOX(gt, bbox, thr);
%
%       Find the matched object or empty.
%
%       r is the overlap ratio.
%

%% main

o = 0;
r = 0;
ao = [];
al = [];

for i = 1 : gt.nobjs    
    ri = p3d_overlapr(gt.bndbox(i,:), bbox);
    
    if ri > thr
        ao = [ao i];
        al = [al gt.final_label(i)];
    end
    
    if ri > thr && ri > r        
        o = gt.final_label(i);
        r = ri;
    end
end


