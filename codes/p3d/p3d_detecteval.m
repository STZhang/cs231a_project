function r = p3d_detecteval(scene, gt, de)
%P3D_DETECTEVAL Evaluate cube detection performance on a scene
%
%   r = P3D_DETECTEVAL(scene, gt, de);
%
%   Inputs
%       scene:  a calibrated scene struct
%       gt:     the ground-truth objects
%       de:     the detected objects
%
%   Outputs
%       r:      the best overlap ratios.
%               r(i) is the overlap ratio of the best matching cube 
%               to the i-th ground-truth object.
%

%% main

% generate projected boxes

n_gt = length(gt.objects);
n_de = length(de.objects);

gt_boxes = cell(n_gt, 1);
de_boxes = cell(n_de, 1);

for i = 1 : n_gt
    gt_boxes{i} = p3d_projbox(scene, gt.objects(i).cube);
end

for i = 1 : n_de
    de_boxes{i} = p3d_projbox(scene, de.objects(i).cube);
end

% compute overlaps

V = zeros(n_gt, n_de);

for i = 1 : n_gt
    for j = 1 : n_de
        V(i, j) = p3d_overlapr(gt_boxes{i}, de_boxes{j});
    end
end

% select the best matching

r = max(V, [], 2);

