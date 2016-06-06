function R = in3d_evalresults(cfg, scenes, results, base_recall, c_base_recalls)
%IN3D_EVALRESULTS Evaluate performances on a set of results
%
%   R = IN3D_EVALRESULTS(cfg, scenes, results);
%
%   Inputs:
%   - cfg:      The framework configuration
%   - scenes:   The set of scene structs
%   - results:  The prediction results (made by in3d_results)
%
%   Outputs:
%   - R:        A struct with following fields:
%               - scene_accuracy:   scene classification accuracy
%               - object_accuracy:  object classification accuracy
%               - scene_confusion:  scene classification confusion mat
%               - object_confusion: object classification confusion mat
%

%% main

if nargin < 4
    base_recall = 1;
end

assert(numel(scenes) == numel(results));
ns = numel(scenes);

Ks = numel(cfg.scene_classes);
Ko = numel(cfg.object_classes);

% build confusion matrices

use_bias = cfg.use_bias;

Cs = zeros(Ks, Ks);     % scene confusion

if use_bias
    Co = zeros(Ko+1, Ko+1);
else    
    Co = zeros(Ko, Ko);     % object confusion
end

for i = 1 : ns
    
    s = scenes(i);
    r = results(i);
    
    sl0 = s.scene_label;
    slr = r.scene_label;
    
    Cs(sl0, slr) = Cs(sl0, slr) + 1;
        
    nobjs = numel(s.objects);
    assert(numel(r.object_labels) == nobjs);
    
    for j = 1 : nobjs
        ol0 = s.objects(j).label;
        olr = r.object_labels(j);
        
        if use_bias
            if ol0 == 0
                ol0 = Ko + 1;
            end
            if olr == 0
                olr = Ko + 1;
            end
        end
        
        Co(ol0, olr) = Co(ol0, olr) + 1;
    end    
end

% compute accuracy

scene_a = sum(diag(Cs)) / sum(Cs(:));
object_a = sum(diag(Co)) / sum(Co(:));

% create output

R.results = results;
R.scene_accuracy = scene_a;

if ~use_bias
    R.object_accuracy = object_a;
else
    tp = sum(diag(Co(1:Ko, 1:Ko)));
    fn = sum(sum(Co(1:Ko, :))) - tp;
    fp = sum(Co(Ko+1, 1:Ko));
    
    R.precision = tp / (tp + fp);
    R.recall = tp / (tp + fn) * base_recall;
    R.F1 = 2 * (R.precision * R.recall) / (R.precision + R.recall);
end

R.scene_confusion = Cs;
R.object_confusion = Co;

if use_bias
    % class-specific performance
    
    c_tp = zeros(1, Ko);
    c_fn = zeros(1, Ko);
    c_fp = zeros(1, Ko);
    
    for k = 1 : Ko
        c_tp(k) = Co(k, k);
        c_fn(k) = sum(Co(k, :)) - c_tp(k);
        c_fp(k) = Co(Ko+1, k);
    end
    
    R.c_tp = c_tp;
    R.c_fn = c_fn;
    R.c_fp = c_fp;
    
    R.c_precision = c_tp ./ (c_tp + c_fp);        
    R.c_recall = c_tp ./ (c_tp + c_fn);% .* c_base_recalls;
    R.c_F1 = 2 * (R.c_precision .* R.c_recall) ./ (R.c_precision + R.c_recall);
    
    R.c_precision(isnan(R.c_precision)) = 0;
    R.c_F1(isnan(R.c_F1)) = 0;
end







