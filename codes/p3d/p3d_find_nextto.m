function pairs = p3d_find_nextto(objs)
%P3D_FIND_NEXTTO Determines pairs of objects that are next to each other
%
%   P3D_FIND_NEXTTO(objs);
%

n = numel(objs);
pairs = [];

if n < 2
    return;
end

for i = 1 : n-1
    for j = i+1 : n
        cb_i = objs(i).cube;
        cb_j = objs(j).cube;
        
        if ~isempty(cb_i) && ~isempty(cb_j)
            d = p3d_gnddist(cb_i, cb_j);
            if d < 0
                pairs = [pairs; [i j]]; %#ok<AGROW>
            end
        end
    end
end
