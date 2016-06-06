function R = in3d_recalls(deobj)
%IN3D_RECALLS Analysizes the detection recalls
%
%   R = IN3D_RECALLS(deobj_dir);
%
%   deobj_dir is the sub-directory name that stores the detection 
%   results (e.g. 'hsobjects')
%

%% directories

datadir = in3d_datadir();
rawfp = fullfile(datadir, [deobj, '_recalls.raw.mat']);
outfp = fullfile(datadir, [deobj, '_recalls.mat']);

scenes_dir = fullfile(datadir, 'cali_scenes');
gtobj_dir = fullfile(datadir, 'gtobjects');
deobj_dir = fullfile(datadir, deobj);

scene_classes = load(fullfile(datadir, 'scene_classes.mat'));
scene_classes = scene_classes.classes;

object_classes = load(fullfile(datadir, 'classes_reduced.mat'));
object_classes = object_classes.classes;

%% main

if ~exist(rawfp, 'file')

    snames = arrayfun(@(i) sprintf('%04d', i), 1:1449, 'UniformOutput', false);
    n = length(snames);
    
    disp('Collecting ...');
    
    raw = cell(n, 1);
    
    for i = 1 : n
        sname = snames{i};                                               
        gt = load(fullfile(gtobj_dir, sprintf('%s.mat', sname)));
        nobjs = numel(gt.objects);
        
        if nobjs > 0            
            sc = load(fullfile(scenes_dir, sprintf('sc%s.mat', sname)));            
            [~, slabel] = ismember(sc.scene_type, scene_classes);
            
            de = load(fullfile(deobj_dir, sprintf('%s.mat', sname)));
            
            if ~isempty(de.objects)
                r = p3d_detecteval(sc, gt, de); 
            else
                r = zeros(nobjs, 1);
            end                                   
            olabels = [gt.objects.label]';
            slabels = slabel(ones(nobjs, 1));
        else
            r = [];
            olabels = [];
            slabels = [];
        end
        
        raw{i} = struct('nobjs', nobjs, ...
            'overlap', r, 'object_label', olabels, 'scene_label', slabels);
        
        if mod(i, 20) == 0
            fprintf('\t%d scenes examined\n', i);
        end
    end
    
    fprintf('\t%d scenes examined\n', n);
    
    data = vertcat(raw{:});
    save(rawfp, 'data');

else
    data = load(rawfp);
    data = data.data;    
end

%% analysis

for i = 1 : length(data)
    di = data(i);
    assert(isequal(size(di.scene_label), size(di.object_label), size(di.overlap)));
end

slabels = vertcat(data.scene_label);
olabels = vertcat(data.object_label);
overlaps = vertcat(data.overlap);

assert(isequal(size(slabels), size(olabels), size(overlaps)));

% overall recall

thres = 0.2;
is_recalled = overlaps > thres;
we_care = olabels > 5;

fprintf('With overlap threshold = %g\n', thres);
fprintf('\n');
fprintf('Overall recall = %.4f\n', ...
    nnz(is_recalled & we_care) / nnz(we_care));
fprintf('\n');

% scene-specific recall

fprintf('Scene-specific:\n');
fprintf('=================================\n');
slabels(slabels == 0) = length(scene_classes);  % others

for k = 1 : length(scene_classes)
    si = find(slabels == k & we_care);
    nk = numel(si);
    rk = nnz(is_recalled(si));
    
    fprintf('Scene class %-15s:  %6d / %6d ~= %4f\n', scene_classes{k}, rk, nk, rk / nk);
end
fprintf('\n');

% object-specific recall

fprintf('Object-specific:\n');
fprintf('=================================\n');

for k = 6 : length(object_classes)-1
    si = find(olabels == k);
    nk = numel(si);
    rk = nnz(is_recalled(si));
    
    fprintf('Object class %-15s:  %6d / %6d ~= %4f\n', object_classes{k}, rk, nk, rk / nk);    
end






