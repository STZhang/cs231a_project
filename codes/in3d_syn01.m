function pots = in3d_syn01()
%IN3D_SYN01 Tests the Indoor 3D framework using a synthetic set
%
%   IN3D_SYN01();
%

%% configuration

rng(0);

cfg.scene_classes = {'A', 'B'};
cfg.object_classes = {'bed', 'chest', 'chair', 'table'};

cfg.use_scene_score = 1;
cfg.use_detect_score = 1;
cfg.use_segment_score = 0;
cfg.use_scene_object = 1;
cfg.use_object_object = 1;

cfg.scene_object_pots = [];     % will be computed later
cfg.object_object_pots = [];

Ks = numel(cfg.scene_classes);
Ko = numel(cfg.object_classes);

n = 100;    % number of scenes in training


%% synthesize data

% Wk is the object-coocurrence weight table for the k-th kind of scene
%
% The synthetic set generates two objects according to these tables
%

W1 = [4 8 0 0; 
      8 4 0 0; 
      0 0 1 1
      0 0 1 1];
     
W2 = [1 1 0 0;
      1 1 0 0;
      0 0 4 8;
      0 0 8 4];

syn_cfg.P{1} = W1 / sum(W1(:));
syn_cfg.P{2} = W2 / sum(W2(:));

% synthesize "template" features for each scene class
%
% the potential will be computed as correlation with these templates

sdim = 10;
syn_cfg.scene_templs = randn(sdim, Ks);
syn_cfg.sstd = 0.2;     % the standard dev of sample features

% synthesize "template" features for each object class

% the potential will be computed as correlation with these templates
%

odim = 10;
syn_cfg.obj_templs = randn(odim, Ko);
syn_cfg.ostd = 2.;     % the stanard dev of sample features

% synthesize training scenes

scenes = cell(n, 1);
for i = 1 : n
    scenes{i} = synthesize_scene(syn_cfg);
end
scenes = vertcat(scenes{:});

%% baseline testing

base_results = repmat(struct('scene_label', 0, 'object_labels', [0, 0]), n, 1);

for i = 1 : n
    s = scenes(i);
    [~, base_results(i).scene_label] = max(s.scene_pots);
    [~, base_results(i).object_labels(1)] = max(s.objects(1).detect_pots);
    [~, base_results(i).object_labels(2)] = max(s.objects(2).detect_pots);
end

Rbase = in3d_evalresults(cfg, scenes, base_results);

fprintf('Baselines:\n');
fprintf('    scene classification:  %.4f\n', Rbase.scene_accuracy);
fprintf('    object classification: %.4f\n', Rbase.object_accuracy);


%% learning

% compute co-occurence tables

[so, oo] = in3d_cotables(Ks, Ko, scenes);

cfg.scene_object_pots = so / n;
cfg.object_object_pots = oo / n;

% construct feature spec

feas = in3d_feas(cfg);

% construct sample set

[samples, loss] = in3d_scenesamples(cfg, scenes);

% construct potential set

pots = in3d_pots(cfg, feas, scenes, samples);

% training

disp('training ...');

params = gcrf_learnparams('iters', 20, 'C', 1);
emp_mean = loss.empirical_mean(pots);
th_init = ones(feas.num_features, 1);

theta = loss.learn(pots, th_init, emp_mean, params);
display(theta);

% testing

pred = pots.infer(theta);
results = in3d_results(scenes, pred);
R = in3d_evalresults(cfg, scenes, results);

fprintf('Using CRF:\n');
fprintf('    scene classification:  %.4f\n', R.scene_accuracy);
fprintf('    object classification: %.4f\n', R.object_accuracy);

display(R.scene_confusion);
display(R.object_confusion);

function s = synthesize_scene(syn_cfg)

Ks = size(syn_cfg.scene_templs, 2);
Ko = size(syn_cfg.obj_templs, 2);

% pick a scene class

s.scene_label = randi(Ks);

% generate scene potentials

s_mu = syn_cfg.scene_templs(:, s.scene_label);
s_vec = s_mu + randn(size(s_mu)) * syn_cfg.sstd;
s.scene_pots = calc_vpot(syn_cfg.scene_templs, s_vec);

% pick object classes

P = syn_cfg.P{s.scene_label};
ocs = randsample(Ko * Ko, 1, true, P(:));
[oc1, oc2] = ind2sub([Ko, Ko], ocs);

% fprintf('s = %d, oc1 = %d, oc2 = %d\n', s.scene_label, oc1, oc2);

% generate object potentials

o1_mu = syn_cfg.obj_templs(:, oc1);
o1_vec = o1_mu + randn(size(o1_mu)) * syn_cfg.ostd;
o1_pot = calc_vpot(syn_cfg.obj_templs, o1_vec);

o2_mu = syn_cfg.obj_templs(:, oc2);
o2_vec = o2_mu + randn(size(o2_mu)) * syn_cfg.ostd;
o2_pot = calc_vpot(syn_cfg.obj_templs, o2_vec);

s.objects(1).object_label = oc1;
s.objects(1).detect_pots = o1_pot;
s.objects(2).object_label = oc2;
s.objects(2).detect_pots = o2_pot;


function r = calc_vpot(T, v)
% compute potential for a vector. w.r.t. templates
%
%   T: d-by-K matrix
%   v: d-by-1 vector
%

Tnrms = sqrt(sum(T.^2, 1));
vnrm = norm(v);

r = v' * T;
r = r ./ (Tnrms * vnrm);

