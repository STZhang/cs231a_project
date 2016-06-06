function in3d_potclassify_a(pots)
% A light-weight wrapper of in3d_potclassify
%

datadir = '~/data/NYUv2';

load(fullfile(datadir, 'ground_truths.mat')); % GTs
fcls = load(fullfile(datadir, 'classes_final.mat'));
spl = load(fullfile(datadir, 'split.mat'));

tv = [spl.train; spl.val];
te = spl.test;

K = length(fcls.classes);

Rtr = in3d_potclassify(K, GTs, pots, tv);
Rte = in3d_potclassify(K, GTs, pots, te);

fprintf('Accuracy: train %.4f; test %.4f\n', ...
    Rtr.accuracy, Rte.accuracy);



