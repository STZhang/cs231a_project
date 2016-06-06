function in3d_gtsummary()
%IN3D_GTSUMMARY Generates a summary of the GT objects
%

datadir = '~/data/NYUv2';
objdir = fullfile(datadir, 'gtobjects_a');
n = 1449;

fcls = load('~/data/NYUv2/classes_final.mat');

tn_insts = 0;
tn_use = 0;
tn_cubes = 0;
tn_diff = 0;
tn_badannot = 0;

for i = 1 : n
    objs = load(fullfile(objdir, sprintf('%04d.mat', i)));
    objs = objs.objects;
    
    ni = numel(objs);
    tn_insts = tn_insts + ni;
    
    tn_use_i = 0;
    
    for j = 1 : ni
        o = objs(j);
        tn_cubes = tn_cubes + o.has_cube;
        tn_diff = tn_diff + o.diff;
        tn_badannot = tn_badannot + o.badannot;
        
        if o.has_cube && ~o.diff && ~o.badannot
            if o.label > 0 && fcls.reduced_to_final(o.label) > 0
                tn_use_i = tn_use_i + 1;
            end
        end        
    end
    
    tn_use = tn_use + tn_use_i;
            
    if i <= 10
        fprintf('scene %d: use %d\n', i, tn_use_i);
    end
end

fprintf('Summary\n');
fprintf('======================\n');
fprintf('total %d instances\n', tn_insts);
fprintf('total %d cubes\n', tn_cubes);
fprintf('total %d difficult\n', tn_diff);
fprintf('total %d bad annotations\n', tn_badannot);
fprintf('total %d usable cubes\n', tn_use);

disp(' ');
