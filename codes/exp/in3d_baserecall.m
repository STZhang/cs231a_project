function info = in3d_baserecall(objty)

datadir = in3d_datadir();

GTs = load(fullfile(datadir, 'ground_truths.mat'));
GTs = GTs.GTs;
objdir = in3d_getobjdir(datadir, objty);

spl = load(fullfile(datadir, 'split.mat'));
tv = [spl.train; spl.val]; te = spl.test;

K = 21;
c_tr_t = zeros(1, K);
c_tr_r = zeros(1, K);
c_te_t = zeros(1, K);
c_te_r = zeros(1, K);

% is_gt = strcmpi(objty, 'gt');

for i = tv(:)'
    gt = GTs{i};
    objs = load(fullfile(objdir, sprintf('%04d.mat', i)));
    objs = objs.objects;
    
    [nu, nr] = calc_recall(K, gt, objs);   
    
    c_tr_t = c_tr_t + nu;
    c_tr_r = c_tr_r + nr;
end

tr_t = sum(c_tr_t);
tr_r = sum(c_tr_r);

for i = te(:)'
    gt = GTs{i};
    objs = load(fullfile(objdir, sprintf('%04d.mat', i)));
    objs = objs.objects;
            
    [nu, nr] = calc_recall(K, gt, objs);
    c_te_t = c_te_t + nu;
    c_te_r = c_te_r + nr;
end

te_t = sum(c_te_t);
te_r = sum(c_te_r);


fprintf('On %s:\n', objty);
fprintf('train recall: %d / %d = %.4f\n', tr_r, tr_t, tr_r / tr_t);
fprintf('test  recall: %d / %d = %.4f\n', te_r, te_t, te_r / te_t);

info = struct(...
    'tr_r', tr_r, 'tr_t', tr_t, 'te_r', te_r, 'te_t', te_t, ...
    'c_tr_r', c_tr_r, 'c_tr_t', c_tr_t, 'c_te_r', c_te_r, 'c_te_t', c_te_t);

function [nu, nr] = calc_recall(K, gt, objs)

nu = zeros(1, K);
nr = zeros(1, K);

% if isfield(objs, 'accept_inds')

if isfield(objs, 'accept_inds')
    recall = false(1, gt.nobjs);
    for j = 1 : length(objs)
        recall(objs(j).accept_inds) = 1;
    end
else
    recall = true(1, gt.nobjs);
end

for j = 1 : gt.nobjs
    if gt.use(j)
        c = gt.final_label(j);
        nu(c) = nu(c) + 1;
        if recall(j)
            nr(c) = nr(c) + 1;
        end
    end
end
    
%    assert(sum(nu) == nnz(gt.use));
%    assert(sum(nr) == nnz(gt.use & recall));
% else
%    nu = nnz(gt.use);
%    nr = nu;
% end

