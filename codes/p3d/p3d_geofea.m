function F = p3d_geofea(Gs, train, val, test)
%P3D_GEOFEA Compute geometric features
%
%   F = P3D_GEOFEA(Gs, train, test);
%
%   Gs is a cell array, each cell is a struct generated from 
%   p3d_geoextract.
%
%   train & test are scene indices in both sets.
%
%   F is a struct with following fields:
%   - feas:         All features vectors [d x N]
%   - olabels:      object labels [1 x N]
%   - iscenes:      scene indices [1 x N]
%   - train_objs:   The object indices of the training set
%   - test_objs:    The object indices of the testing set
%   


%% main

n = length(Gs);
N = sum(cellfun(@numel, Gs));

d = 10;
feas = zeros(d, N);
olabels = zeros(1, N);
iscenes = zeros(1, N); 

is_tr_s = zeros(n, 1);
is_te_s = zeros(n, 1);
is_tr_s(train) = 1;
is_tr_s(val) = 2;
is_te_s(test) = 1;

is_tr = zeros(N, 1);
is_te = zeros(N, 1);

fi = 0;
for i = 1 : n    
    gi = Gs{i};
    for j = 1 : numel(gi)
        fi = fi + 1;
        
        if ~isempty(gi{j})        
            feas(:, fi) = geofeavec(gi{j});
            olabels(fi) = gi{j}.label;
            iscenes(fi) = i;
        
            if olabels(fi) > 0
                is_tr(fi) = is_tr_s(i);
                is_te(fi) = is_te_s(i);
            end
        end
    end    
end

assert(fi == N);

F.feas = bsxfun(@times, feas, 1 ./ std(feas, [], 2));
F.olabels = olabels;
F.iscenes = iscenes;
F.train_objs = find(is_tr==1);
F.val_objs = find(is_tr==2);
F.trainval_objs = find(is_tr);
F.test_objs = find(is_te);


function v = geofeavec(g)

wall_close = exp(-g.walldist / 0.1);
wall_parallel = exp(-g.wallrad / 0.1);
ground_close = exp(-g.grounddist / 0.1);

v = [   g.height g.lwidth g.swidth, ...
        g.haspect, g.vaspect, g.area, g.vol, ...
        wall_parallel, wall_close, ground_close ]; 

