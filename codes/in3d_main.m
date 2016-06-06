function in3d_main(objty, cfg, C, varargin)
%IN3D_MAIN The main program to run Training and Testing on Indoor3d mdoel
%
%   IN3D_MAIN(objty, cfg, C)
%
%       Runs the trainig and testing of an indoor 3D model based on
%       the input config. 
%
%       Here, cfg can be either a config struct (loaded by in3d_config)
%       or a config filename.
%
%       Learned models and testing results will be written to the
%       directory, specified by cfg.output_dir.
%
%
%   IN3D_MAIN(objty, cfg, C, 'check', inds);
%
%       This is a special mode, specifically designed for debugging or
%       sanity checking.
%
%       This ignores the split file, and simply uses the samples given
%       by inds (a vector of indices) to train, and then tests the model
%       on the same set of samples.
%
%       This mode does not write models to disk. It simply displays the
%       results on the console.
%


%% configuration

disp('Loading configurations ...');    
cfg = in3d_config(objty, cfg);


% parse extra options

check_inds = [];

if ~isempty(varargin)
    onames = varargin(1:2:end);
    ovals = varargin(2:2:end);
    
    if ~(length(onames) == length(ovals) && iscellstr(onames))
        error('Invalid option list');
    end
    
    for i = 1 : length(onames)
        switch onames{i}
            case 'check'
                check_inds = ovals{i};
            otherwise
                error('Invalid option name: %s\', onames{i});
        end
    end
end

%% load data

disp('Loading data ...');
S = cfg.data.S;

% load data
load('scene_scores.mat');
for i = 1:1449
    S(i).scene_pots = scores(i, :);
end

% split

if isempty(check_inds)

    split = cfg.split;
    if isfield(split, 'val')
        scenes_tr = S([split.train; split.val]);
    else
        scenes_tr = S(split.train);
    end
    scenes_te = S(split.test);
    
    fprintf('Normal mode: %d scenes (split into %d training and %d testing)\n', ...
        numel(S), numel(scenes_tr), numel(scenes_te));

else
    
    scenes_tr = S(check_inds);
    scenes_te = scenes_tr;
    
    fprintf('Check mode: using %d scenes\n', numel(scenes_tr));
end


%% create output directories

if isempty(check_inds) && isfield(cfg, 'output_dir')
    if ~exist(cfg.output_dir, 'dir')
        mkdir(cfg.output_dir);        
    end
    outdir = fullfile(cfg.output_dir, sprintf('C%.1e', C));
    if ~exist(outdir, 'dir')
        mkdir(outdir);
    end
    
    to_output = true;
    fprintf('Outputs will be written to %s\n', outdir);
else
    outdir = [];
    to_output = false;
end
    

%% learning

tstart = tic;

disp('Constructing training features & potentials ...');

% construct feature spec
feas = in3d_feas(cfg);

% construct sample set
[samples_tr, loss] = in3d_scenesamples(cfg, scenes_tr);

% construct potential set
pots_tr = in3d_pots(cfg, feas, scenes_tr, samples_tr);

fprintf('features & potentials constructed, elapsed = %g sec\n', toc(tstart));

% training

disp('Training ...');

params = gcrf_learnparams( ...
    'iters', cfg.learning_iters, ...
    'C', C, ...
    'rgap', cfg.learning_rgap);

% load or compute empirical mean

if ~isempty(outdir)
    emp_mean_fp = fullfile(outdir, 'emp_mean.mat');
else
    emp_mean_fp = [];
end

if ~isempty(emp_mean_fp) && exist(emp_mean_fp, 'file')
    fprintf('loading empirical means from %s\n', emp_mean_fp);
    emp_mean = load(emp_mean_fp);
    emp_mean = emp_mean.emp_mean;
else
    fprintf('computing empirical means\n');
    emp_mean = loss.empirical_mean(pots_tr);
    
    if to_output
        save(emp_mean_fp, 'emp_mean');
    end
end

fprintf('empirical-mean ready, elapsed = %g sec\n', toc(tstart));
%emp_mean

% learn theta

if ~isempty(outdir)
    theta_fp = fullfile(outdir, 'theta.mat');
else
    theta_fp = [];
end

if ~isempty(theta_fp) && exist(theta_fp, 'file')
    fprintf('loading theta (model coeffs) from %s\n', theta_fp);
    theta = load(theta_fp);
    theta = theta.theta;
else
    fprintf('learning theta ...\n');
    
    tlearn = tic;
    
    th_init = ones(feas.num_features, 1);
    theta = loss.learn(pots_tr, th_init, emp_mean, params);      
    
    learning_time = toc(tlearn); %#ok<NASGU>
    
    if to_output
        save(theta_fp, 'theta', 'learning_time');
    end
end
    
fprintf('model ready, elapsed = %g sec\n', toc(tstart));
disp(' ');
theta

%% testing

info = cfg.data.info;

% test on train

% disp('Testing on traing set ...');
%     
% if ~isempty(preds_tr_fp) && exist(preds_tr_fp, 'file')
%     fprintf('loading preds from %s\n', preds_tr_fp);
%     preds_tr = load(preds_tr_fp);
%     preds_tr = preds_tr.preds;
% else
%     fprintf('solving predictions\n');
%     preds_tr = pots_tr.infer(theta);
%     
%     if to_output
%         preds = preds_tr; %#ok<NASGU>
%         save(preds_tr_fp, 'preds');
%     end
% end
% 
% 
% 
% base_recall_tr = info.tr_r / info.tr_t; 
% Rtr = get_results(cfg, scenes_tr, preds_tr, base_recall_tr); %#ok<NASGU>
% if to_output
%     save(res_tr_fp, '-struct', 'Rtr');
% end
% 
% fprintf('testing on train-set ready, elapsed = %g sec\n', toc(tstart));
% disp(' ');
    
% test on test

if cfg.use_bias
    bias_as = 0;%1 : 0.5 : 12;
    best.F1 = 0;
else
    bias_as = 0;
end

tinfer = tic;

for i = 1 : length(bias_as)
    
    bias_a = bias_as(i);
    if ~isempty(outdir)
        preds_te_fp = fullfile(outdir, sprintf('predictions_test.a%g.mat', bias_a));
        res_te_fp = fullfile(outdir, sprintf('results_test.a%g.mat', bias_a));
    else
        preds_te_fp = [];
        res_te_fp = [];
    end
    
    fprintf('Testing on testing set with bias = %g\n', bias_a);
    
    if ~isempty(preds_te_fp) && exist(preds_te_fp, 'file')
        fprintf('loading preds from %s\n', preds_te_fp);
        preds_te = load(preds_te_fp);
        preds_te = preds_te.preds;
    else
        fprintf('solving predictions\n');
        samples_te = in3d_scenesamples(cfg, scenes_te);
        pots_te = in3d_pots(cfg, feas, scenes_te, samples_te);
        
        theta_a = theta;
        theta_a(1) = theta_a(1) + bias_a;
        
        preds_te = pots_te.infer(theta_a);
        
        if to_output
            preds = preds_te; %#ok<NASGU>
            save(preds_te_fp, 'preds');
        end
    end
    
    base_recall_te = info.te_r / info.te_t;
    c_base_recalls_te = info.c_te_r ./ info.c_te_t;
    
    Rte = get_results(cfg, scenes_te, preds_te, base_recall_te, c_base_recalls_te);
    if to_output
        save(res_te_fp, '-struct', 'Rte');
    end
    
    fprintf('testing on test-set ready, elapsed = %g sec\n', toc(tstart));
    disp(' ');
    
    if cfg.use_bias
        if Rte.F1 > best.F1
            best = Rte;
        end
    else
        best = Rte;
    end
end
    
best.infer_time = toc(tinfer) / length(bias_as);


f1_fp = fullfile(outdir, 'best.mat');
save(f1_fp, '-struct', 'best');

if cfg.use_bias & 0
    fprintf('best:\n');
    fprintf('  recall = %.4f\n', best.recall);
    fprintf('  precision = %.4f\n', best.precision);
    fprintf('  F1 = %.4f\n', best.F1);
    fprintf('\n');
end


function R = get_results(cfg, scenes, preds, base_recall, base_recalls)

results = in3d_results(scenes, preds);
R = in3d_evalresults(cfg, scenes, results, base_recall, base_recalls);

fprintf('Result:\n');
fprintf('    scene classification:  %.4f\n', R.scene_accuracy);
if cfg.use_bias
    %fprintf('    recall:     %.4f\n', R.recall);
    %fprintf('    precision:  %.4f\n', R.precision);
    %fprintf('    F1:         %.4f\n', R.F1);
    fprintf('    recall:     %.4f\n', mean(R.c_recall));
    fprintf('    precision:  %.4f\n', mean(R.c_precision));
    fprintf('    F1:         %.4f\n', mean(R.c_F1));
else
    fprintf('    object classification: %.4f\n', R.object_accuracy);
end