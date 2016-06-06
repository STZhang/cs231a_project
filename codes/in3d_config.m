function cfg = in3d_config(objty, cfgname)
%IN3D_CONFIG Reads a config file 
%
%   cfg = IN3D_CONFIG(objty, cfgname)
%
%   objty: the type of candidate objects to use
%   cfgname: the config name, e.g. e01
%

%% main

% load config

datacfg = read_datacfg();

cfgdir = fullfile(fileparts(mfilename('fullpath')), 'configs');
cfgfilename = fullfile(cfgdir, [cfgname, '.cfg']);

text = textread(cfgfilename, '%s', 'delimiter', '\n');

cfg = [];

% options with default 

cfg.data_dir = datacfg.datadir;
cfg.output_dir = datacfg.outputdir;
cfg.split_file = datacfg.split_file;

cfg.use_bias = 0;
cfg.use_segment_score = 0;
cfg.use_detect_score = 0;
cfg.use_geometry_score = 0;
cfg.use_cpmc_score = 0;

cfg.use_scene_object = 0;
cfg.use_object_object = 0;
cfg.use_object_next = 0;
cfg.use_object_top = 0;


for i = 1 : length(text)
    stmt = strtrim(text{i});
    if isempty(stmt) || stmt(1) == '#'
        continue;
    end
    
    [name, val] = parse_stmt(stmt);
        
    switch lower(name)
        case { 'data_dir', ...
               'output_dir', ...
               'split_file' }
           
           cfg.(name) = val;
           
           
        case { 'use_bias', ...
               'use_scene_score', ...
               'use_detect_score', ...
               'use_segment_score', ...
               'use_geometry_score', ...
               'use_cpmc_score', ...
               'use_scene_object', ...
               'use_object_object', ...
               'use_object_next', ...
               'use_object_top', ...
               'learning_iters' }
           
           cfg.(name) = str2double(val);
           
        otherwise
            error('Unknown option %s at line %d\n', name, i);
    end   
end

% check directory 

cfg.data_file = fullfile(objty, 'dataset.mat');
cfg.output_dir = fullfile(cfg.output_dir, [objty '.' cfgname]);

verify_exist(cfg, 'dir', []);
verify_exist(cfg, 'file', 'data_file');
verify_exist(cfg, 'file', 'split_file');

% set default values

if ~isfield(cfg, 'learning_iters')
    cfg.learning_iters = 50;
end

if ~isfield(cfg, 'learning_rgap')
    cfg.learning_rgap = 1.0e-4;
end

% load classes and stats

cfg.split = load(fullfile(cfg.data_dir, cfg.split_file));

cfg.data = load(fullfile(cfg.data_dir, cfg.data_file));
cfg.scene_classes = cfg.data.scene_classes;
cfg.object_classes = cfg.data.object_classes;

Ks = length(cfg.scene_classes);
Ko = length(cfg.object_classes);

co_stats = cfg.data.co_stats;

if strcmp(objty, 'gt') || cfg.use_bias==0
   assert(isequal(size(co_stats.so), [Ks Ko]));
   assert(isequal(size(co_stats.oo), [Ko Ko]));
else
   assert(isequal(size(co_stats.so), [Ks Ko+1])); 
 %  assert(isequal(size(co_stats.oo), [Ko+1 Ko+1]));
end;


% hacky
cfg.scene_object_pots = co_stats.so ./ repmat(sum(co_stats.so, 2), [1, size(co_stats.so, 2)]);

cfg.object_object_pots = 2 * (co_stats.oo > 0) - 1;
%cfg.object_object_pots = co_stats.oo ./ repmat(sum(co_stats.oo, 2), [1, size(co_stats.oo, 2)]);

cfg.object_next_pots = co_stats.oo_next ./ repmat(sum(co_stats.oo_next, 2), [1, size(co_stats.oo_next, 2)]);

if cfg.use_object_top
    %cfg.object_top_pots = co_stats.oo_top ./ repmat(sum(co_stats.oo_top, 2)+eps, [1, size(co_stats.oo_top, 2)]);
    cfg.object_top_pots = (2 * (co_stats.oo_top>0) -1) / 10;
end


function [name, val] = parse_stmt(s)

ieq = strfind(s, '=');
assert(isscalar(ieq));

name = strtrim(s(1:ieq-1));
val = strtrim(s(ieq+1:end));


function verify_exist(cfg, ty, sub)

if isempty(sub)
    p = cfg.data_dir;
else
    p = fullfile(cfg.data_dir, cfg.(sub));
end

if ~exist(p, ty)
    error('The %s %s is missing.', ty, p);
end


function dcfg = read_datacfg()

% get the code directory
tbdir = fileparts(mfilename('fullpath'));
cfgfile = fullfile(tbdir, 'data.cfg');

if ~exist(cfgfile, 'file')
    error('The file %s is not found.\n', cfgfile);
end

dcfg = in3d_readcfg(cfgfile);

