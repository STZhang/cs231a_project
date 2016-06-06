function pots = in3d_pots(cfg, feas, scenes, samples)
%IN3D_POTS Create a potential set over input scenes
%
%   pots = IN3D_POTS(cfg, feas, scenes, samples);
%
%       Creates a potential set on the input scenes, based on the given
%       feature setting.
%
%       Inputs:
%       - cfg:      The model configuration (see config.txt)
%       - feas:     The feature set (an instance of gcrf_feaset)
%       - scenes:   The array of scenes (see scene_structs.txt)
%       - samples:  A sample set constructed on the scenes
%                   (use in3d_scenesamples)
%
%       Outputs:
%       - pots:     The created potential set (instance of gcrf_potset).
%

%% check model setting

use_bias = cfg.use_bias;

use_scene_score = cfg.use_scene_score;
use_detect_score = cfg.use_detect_score;
use_segment_score = cfg.use_segment_score;
use_geometry_score = cfg.use_geometry_score;
use_cpmc_score = cfg.use_cpmc_score;

use_scene_object = cfg.use_scene_object;
use_object_object = cfg.use_object_object;
use_object_next = cfg.use_object_next;
use_object_top = cfg.use_object_top;

so_pot = cfg.scene_object_pots;
oo_pot = cfg.object_object_pots;
oo_next_pot = cfg.object_next_pots;

if isfield(cfg, 'object_top_pots')
    oo_top_pot = cfg.object_top_pots;
end

Ks = length(cfg.scene_classes);
Ko = length(cfg.object_classes);
% Ksp = length(cfg.spixel_classes);
% Ka = cfg.num_a_states;

if use_bias
    if size(so_pot, 2) < Ko+1
       so_pot = [so_pot zeros(Ks, 1)];
    end;
    
    if size(oo_pot, 2) < Ko+1
       oo_pot = [oo_pot zeros(Ko, 1); zeros(1, Ko) 0];
    end;
    if size(oo_next_pot) < Ko+1
       oo_next_pot = [oo_next_pot zeros(Ko, 1); zeros(1, Ko) 0];
    end;
    if isfield(cfg, 'object_top_pots') & (size(oo_top_pot) < Ko+1)
       oo_top_pot = [oo_top_pot zeros(Ko, 1); zeros(1, Ko) 0];
    end;

    
    bias_pot = [zeros(1, Ko), -1];
end



%% potential set construction

pots = gcrf_potset(feas, samples);
n = numel(samples);

for i = 1 : n
    s = scenes(i);

    if use_scene_score
        pots.set_pot('scene_score', i, 1, s.scene_pots);
        %pots.set_pot('scene_score', i, 1,10*1./(1+exp(-1*s.scene_pots)));
    end
    
    
    nobjs = numel(s.objects);
    
    if use_bias        
        for j = 1 : nobjs
            pots.set_pot('bias', i, 1+j, bias_pot);
        end
    end
    
    if use_detect_score
        for j = 1 : nobjs
            p = make_upot(s.objects(j).detect_pots(1:Ko), use_bias);
            pots.set_pot('detect_score', i, 1+j, p);                    
        end
    end
    
    if use_segment_score
        for j = 1 : nobjs
            if use_bias
                p = s.objects(j).seg_pots(1:Ko+1);
                %p = [s.objects(j).seg_pots(1:Ko), -1];
            else
                p = s.objects(j).seg_pots(1:Ko);
            end
            %pots.set_pot('segment_score', i, 1+j, p); 
            pots.set_pot('segment_score', i, 1+j, 10*1./(1+exp(-1*p)));
        end
    end
    
    if use_geometry_score
        for j = 1 : nobjs
            p = make_upot(s.objects(j).geo_pots(1:Ko), use_bias);
               
            pots.set_pot('geometry_score', i, 1+j, p);
        end
    end
        
    if use_cpmc_score
        for j = 1 : nobjs
            if use_bias
                p = 2*1./(1+exp(-1*s.objects(j).cpmc_pots(1:Ko+1)));
            else
                p = s.objects(j).cpmc_pots(1:Ko);
            end
            pots.set_pot('cpmc_score', i, 1+j, p); 
        end
    end

    
    if use_scene_object
        if use_bias
           temp = so_pot(:, Ko+1);
        end;
        so_pot(so_pot==0) = -1;
        if use_bias
            so_pot(:, Ko+1) = temp;
        end;
        for j = 1 : nobjs
            pots.set_pot('scene_object', i, [1, 1+j], so_pot);
        end
    end
    
    if use_object_object
        for j1 = 1 : nobjs
            for j2 = j1+1 : nobjs
                pots.set_pot('object_object', i, [1+j1 1+j2], oo_pot);                
            end
        end
    end
    
    
    if use_object_next
        if use_bias
           temp = oo_next_pot;
           %oo_next_pot(oo_next_pot==0)=-1; 
        else
           oo_next_pot(oo_next_pot==0)=-10;
        end;
        for j1 = 1 : nobjs
            for j2 = j1+1 : nobjs                
                if in3d_is_next(s.objects(j1), s.objects(j2))
                    pots.set_pot('object_next', i, [1+j1 1+j2], 10*oo_next_pot);
                end
            end
        end
    end    
    
    if use_object_top
        for j1 = 1 : nobjs
            for j2 = j1+1 : nobjs
                if p3d_supports(s.objects(j1), s.objects(j2))
                    pots.set_pot('object_top', i, [1+j1 1+j2], oo_top_pot);
                elseif p3d_supports(s.objects(j2), s.objects(j1))
                    pots.set_pot('object_top', i, [1+j2 1+j1], oo_top_pot);
                end
            end
        end
    end
    
end
fprintf('\n');



function p = make_upot(p, use_bias)

if use_bias
    p = [p 0];
end
    


