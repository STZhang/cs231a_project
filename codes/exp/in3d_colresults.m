function in3d_colresults(objty)
% Collect results

%% config

resdir = '~/data/NYUv2_results';

is_gt = false;

if strcmp(objty, 'gt')
    cfgs = {'e01', 'e02', 'e03', ...
        'e11', 'e12', 'e13', 'e14', 'e15', 'e16', ...
        'e21', 'e22', 'e23', 'e24'};
    Cs = [0.001 0.003 0.1 0.3 1 3 10 30 100];
    is_gt = true;
    
elseif strcmp(objty(1:2), 'nn')    
    cfgs = {'f01', 'f02', 'f03', 'f04', 'f05'};
    Cs = [0.1, 0.5, 1, 5];
else
    error('Unsupported objty %s\n', objty);
end

%% main

for k = 1 : length(cfgs)
    cfg = cfgs{k};
    
    if is_gt
        sa = 0;
        oa = 0;
    else
        recall = 0;
        prec = 0;
        F1 = 0;
    end
    
    for i = 1 : length(Cs);
        C = Cs(i);
        
        rpath = fullfile(resdir, ...
            sprintf('%s.%s', objty, cfg), ...
            sprintf('C%.1e', C), ...
            'best.mat');
        
        r = load(rpath);
        
        if is_gt
            sa = max(sa, r.scene_accuracy);
            oa = max(oa, r.object_accuracy);        
        else
            if r.F1 > F1
                recall = r.recall;
                prec = r.precision;
                F1 = r.F1;
            end
        end
    end    
    
    if is_gt
        fprintf('On %s:   object = %.4f   scene = %.4f\n', cfg, sa, oa);
    else
        fprintf('On %s:   recall = %.4f   prec = %.4f   F1 = %.4f\n', ...
            cfg, recall, prec, F1);
    end
end
