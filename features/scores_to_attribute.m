%% load config
cfg = 'e25';

disp('Loading configurations ...');    
objty = 'gt';
cfg = in3d_config(objty, cfg);

%% load data
disp('Loading data ...');
S = cfg.data.S;

% split
split = cfg.split;
if isfield(split, 'val')
    idx_tr = [split.train; split.val];
    scenes_tr = S(idx_tr);
else
    idx_tr = split.train;
    scenes_tr = S(idx_tr);
end
idx_te = split.test;
scenes_te = S(idx_te);

fprintf('Normal mode: %d scenes (split into %d training and %d testing)\n', ...
    numel(S), numel(scenes_tr), numel(scenes_te));

load('object_scores_train.mat');
scores_train = scores;
load('object_scores_test.mat');
scores_test = scores;

%% add an attribute to data
types = {'train','test'};

for t = 1:size(types,2)
    type = types(t);
    
    if strcmp(type,'train')
        scores = scores_train;
        idx_set = idx_tr;
    elseif strcmp(type,'test')
        scores = scores_test;
        idx_set = idx_te;
    else
        break;
    end
    
    n = numel(idx_set);
    counter = 1;
    
    for i = 1:n
        idx = idx_set(i);
        nobjs = numel(S(idx).objects);
        for j = 1:nobjs
            S(idx).objects(j).app_pot = scores(counter,:);
            counter = counter + 1;
        end
    end
end

file_path = fullfile(cfg.data_dir, cfg.data_file);
save(file_path,'S','-append');
