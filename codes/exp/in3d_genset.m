function S = in3d_genset(objty)
%IN3D_GENSET Generates a scene struct dataset
%
%   R = IN3D_GENSET(obj_ty);
%

datadir = in3d_datadir();

outfile = fullfile(datadir, objty, 'dataset.mat');

fcls = load(fullfile(datadir, 'classes_final.mat'));
sc_classes = load(fullfile(datadir, 'scene_classes.mat'));

scene_classes = sc_classes.classes; %#ok<NASGU>
object_classes = fcls.classes; %#ok<NASGU>

gts_file = fullfile(datadir, objty, 'ground_truths.mat');
GTs = load(gts_file);
GTs = GTs.GTs;

scenepot_file = fullfile(datadir, 'scene_pots.mat');

objdir = in3d_getobjdir(datadir, objty);
segpot_file = fullfile(datadir, objty, 'segpots.mat');
geopot_file = fullfile(datadir, objty, 'geopots.mat');
costat_file = fullfile(datadir, objty, 'co_stats.mat');

co_stats = load(costat_file);

is_final = 1;

if strcmpi(objty, 'gt') 
    is_final = 0;
end


info = in3d_baserecall(objty);


n = 1449;
ss = cell(n, 1);

scene_labels = sc_classes.class_labels;

scene_pots = load(scenepot_file);
scene_pots = scene_pots.scene_pots;

all_seg_pots = load(segpot_file);
all_seg_pots = all_seg_pots.pots;

all_geo_pots = load(geopot_file);
all_geo_pots = all_geo_pots.pots;

for i = 1 : n      
    objs = load(fullfile(objdir, sprintf('%04d.mat', i)));
    objs = objs.objects;
    
    segpots = all_seg_pots{i};
    geopots = all_geo_pots{i};
        
    s = [];
    s.scene_label = scene_labels(i);
    s.scene_pots = scene_pots(i, :);    
    
    nobjs = length(objs);
    assert(size(segpots, 1) == nobjs);
    
    os = cell(nobjs, 1);
    use_inds = [];
    
    gt = GTs{i};
    
    if is_final
        assert(gt.nobjs == nobjs);
    end
    
    for j = 1 : nobjs
        o = [];
        oj = objs(j);
        
        if oj.label <= 0
            o.label = 0;
        else
            if is_final
                o.label = oj.label;
            else
                o.label = fcls.reduced_to_final(oj.label);
            end
        end
        
        
        if is_final || o.label > 0
            % usable
            
            if is_final
                assert(oj.has_cube && ~oj.diff && ~oj.badannot);
            else
                if oj.diff || oj.badannot || ~oj.has_cube
                    continue;
                end
            end
            
            o.bndbox = oj.bndbox;
            o.cube = oj.cube;
            
            o.seg_pots = segpots(j, :);
            o.geo_pots = geopots(j, :);
            if isfield(oj, 'cpmc_score')
                o.cpmc_pots = oj.cpmc_score;
            end
            os{j} = o;  
            
            use_inds = [use_inds, j]; %#ok<AGROW>
            
            if is_final
                assert(gt.final_label(j) == o.label);
            end
        end
    end
    
    s.use_inds = use_inds;
    s.objects = vertcat(os{:});
    
    assert(length(s.use_inds) == length(s.objects));
    
    ss{i} = s;
    
    if mod(i, 20) == 0
        fprintf('processed %d ...\n', i);
    end
end

S = vertcat(ss{:});
save(outfile, 'objty', 'info', ...
    'scene_classes', 'object_classes', 'GTs', 'co_stats', 'S');

