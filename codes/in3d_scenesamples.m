function [samples, loss] = in3d_scenesamples(cfg, scenes)
%IN3D_SCENESAMPLES Construct a GCRF sample set from a set of scenes
%
%   samples = IN3D_SCENESAMPLES(cfg, scenes);
%
%       creates a sample set, a cell array of gcrf_sample object. 
%
%   [samples, loss] = IN3D_SCENESAMPLES(cfg, scenes);
%
%       additionally creates and returns a loss object (of class
%       gcrf_loss).
%

%% main

Ks = numel(cfg.scene_classes);
Ko = numel(cfg.object_classes);

n = numel(scenes);

use_bias = cfg.use_bias;

% create sample set

samples = cell(1, n);
for i = 1 : n
    sc = scenes(i);
    nobjs = numel(sc.objects);
    
    spl = gcrf_sample();
    spl.add_local('scene', Ks);
    if nobjs > 0
        if use_bias
            spl.add_locals('object', nobjs, Ko+1);
        else
            spl.add_locals('object', nobjs, Ko);
        end
    end
    
    samples{i} = spl;
end

% create loss

if nargout >= 2    
    loss = gcrf_loss(samples);
    for i = 1 : n
        sc = scenes(i);        
        loss.set_gt(i, 1, sc.scene_label, 1);
        
        nobjs = numel(sc.objects);
        for j = 1 : nobjs
            o = sc.objects(j);
            assert(o.label <= Ko);
            if o.label > 0            
                if use_bias
                    o_loss = ones(1, Ko + 1);
                    o_loss(o.label) = 0;
                    o_loss(end) = 60;  % how to set this automatically??
                    loss.set_gt(i, 1+j, o_loss, 15);
                else
                    loss.set_gt(i, 1+j, o.label, 10);    
                end;
            elseif use_bias && o.label == 0
                loss.set_gt(i, 1+j, Ko+1, 1);
            end
        end
    end        
end


