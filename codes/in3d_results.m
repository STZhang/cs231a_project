function r = in3d_results(scenes, preds)
%IN3D_RESULTS Translates CRF predictions into scene parsing results
%
%   r = IN3D_RESULTS(samples, preds);
%

ns = length(preds);
r = cell(ns, 1);

for i = 1 : ns
    p = preds(i);
    s = scenes(i);
    
    nobjs = numel(s.objects);
    assert(numel(p.node) == nobjs + 1);
    
    ri = [];
    [~, ri.scene_label] = max(p.node{1});
    ri.object_labels = zeros(1, nobjs);
    
    for j = 1 : nobjs
        [~, ri.object_labels(j)] = max(p.node{j+1});
    end
    
    r{i} = ri;
end

r = vertcat(r{:});
