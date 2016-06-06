function [C, ap] = in3d_seg_majorvote(objty, inds)
%IN3D_SEG_MAJORVOTE Performs a baseline classification (based on
%segmentation based voting)
%
%   IN3D_SEG_MAJORVOTE
%


%% Load files

datadir = in3d_datadir();
objdir = in3d_getobjdir(objty);
segdir = fullfile(datadir, 'segPredictions');

potdir = fullfile(datadir, [objty, '_segpots']);
if ~exist(potdir, 'dir')
    mkdir(potdir);
end

K = 31;
C = zeros(K, K);

for i = 1 : length(inds)
    idx = inds(i);    
    
    [gt, pred] = seg_majvote(K, objdir, segdir, potdir, idx);
    
    for j = 1 : numel(gt)
        if gt(j) > 0
            C(gt(j), pred(j)) = C(gt(j), pred(j)) + 1;
        end
    end        
    
    if mod(i, 20) == 0
        fprintf('processed %d\n', i);
    end
end

ap = sum(diag(C)) / sum(C(:));


%% core function

function [gt, pred] = seg_majvote(K, objdir, segdir, potdir, idx)

objfp = fullfile(objdir, sprintf('%04d.mat', idx));
s = load(objfp);
objs = s.objects;

segfp = fullfile(segdir, sprintf('%04d.mat', idx));
seg = load(segfp);

n = length(objs);
gt = zeros(n, 1);

for i = 1 : n
    if objs(i).diff || objs(i).
    gt(i) = objs(i).label;
    
end

pots = in3d_segpot(objs, seg);
[~, pred] = max(pots(:, 1:K), [], 2);

potfp = fullfile(potdir, sprintf('%04d.mat', idx));
if ~exist(potfp, 'file')
    save(potfp, 'pots');
end

