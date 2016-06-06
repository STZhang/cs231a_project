function feas = in3d_feas(cfg)
%IN3D_FEAS Constructs a 3D indoor scene featureset
%
%   feas = IN3D_FEAS(cfg);
%


%% main

% create feature set

feas = gcrf_feaset();

nc_s = numel(cfg.scene_classes);
nc_o = numel(cfg.object_classes);

if cfg.use_bias
    nc_o = nc_o + 1;
    feas.add_feature('bias', nc_o);
end

if cfg.use_scene_score
    feas.add_feature('scene_score', nc_s);
end

if cfg.use_detect_score
    feas.add_feature('detect_score', nc_o);
end

if cfg.use_segment_score
    feas.add_feature('segment_score', nc_o);
end

if cfg.use_geometry_score
    feas.add_feature('geometry_score', nc_o);
end

if cfg.use_cpmc_score
    feas.add_feature('cpmc_score', nc_o);
end

if cfg.use_scene_object
    feas.add_feature('scene_object', [nc_s, nc_o]);
end

if cfg.use_object_object
    feas.add_feature('object_object', [nc_o, nc_o]);
end

if cfg.use_object_next
    feas.add_feature('object_next', [nc_o, nc_o]);
    if cfg.use_bias
       %feas.add_feature('object_next_fb', [nc_o, nc_o]); 
       %feas.add_feature('object_next_bb', [nc_o, nc_o]);
    end;
end

if cfg.use_object_top
    feas.add_feature('object_top', [nc_o, nc_o]);
end


