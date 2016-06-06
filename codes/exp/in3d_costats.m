function R = in3d_costats(objty)
%IN3D_COSTATS Evaluates co-occurrence statistics 
%
%   R = IN3D_COSTATS(inds)
%

datadir = in3d_datadir();
objdir = in3d_getobjdir(datadir, objty);

if strcmp(objty, 'gt')
    fcls = load(fullfile(datadir, 'classes_final.mat'));
    dstfp = fullfile(datadir, 'co_stats.mat');
else
    fcls = [];
    dstfp = fullfile(datadir, objty, 'co_stats.mat');
end
gtruths = load(fullfile(datadir, 'ground_truths.mat')); % only for scene-label


Ks = 13;
Ko = 21;

so = zeros(Ks, Ko);

oo = zeros(Ko, Ko);
oo_next = zeros(Ko, Ko);
oo_top = zeros(Ko, Ko);
if ~strcmp(objty, 'gt')
    so = zeros(Ks, Ko+1);
    %oo = zeros(Ko+1, Ko+1);
    %oo_next = zeros(Ko+1, Ko+1);
    %oo_top = zeros(Ko+1, Ko+1);
end;

inds = 1:1449;
for i = inds
    
    idx = inds(i);    
    objs = load(fullfile(objdir, sprintf('%04d.mat', idx)));
    objs = objs.objects;    
    
    ni = numel(objs);
    
    % add to scene-object
    
    sl = gtruths.scene_labels(i);
    
    for j = 1 : ni       
        ol = ulabel(fcls, objs(j));
        if ol > 0 
            so(sl, ol) = so(sl, ol) + 1;
        elseif ~strcmp(objty, 'gt')
            so(sl, Ko+1) = so(sl, Ko+1) + 1;
        end;
    end 
    
    % add to object-object
    
    M = false(size(oo));
    M_next = false(size(oo_next));
    M_top = false(size(oo_next));
    
    for j1 = 1 : ni-1
        for j2 = j1+1 : ni
            ol1 = ulabel(fcls, objs(j1));
            ol2 = ulabel(fcls, objs(j2));
            if ~strcmp(objty, 'gt')
               % if ol1==0, ol1 = Ko+1; end;
               % if ol2==0, ol2 = Ko+1; end;
            end;
            
            if ol1 > 0 && ol2 > 0                
                M(ol1, ol2) = 1;
                M(ol2, ol1) = 1;   
                
                % determine whether they are next to each other
                if in3d_is_next(objs(j1), objs(j2))
                    M_next(ol1, ol2) = 1;
                    M_next(ol2, ol1) = 1;
                end
                
                % determine whether j2 is on top of j1
                
                if p3d_supports(objs(j1), objs(j2))
                    M_top(ol1, ol2) = 1;
                elseif p3d_supports(objs(j2), objs(j1))
                    M_top(ol2, ol1) = 1;
                end
                
            end
        end
    end
    
    oo = oo + M;
    oo_next = oo_next + M_next;
    oo_top = oo_top + M_top;    
    
    if mod(i, 20) == 0
        fprintf('processed %d\n', i);
    end    
end

fprintf('processed %d\n', i);

R.so = so;
R.oo = oo;
R.oo_next = oo_next;
R.oo_top = oo_top;
save(dstfp, '-struct', 'R');


function ol = ulabel(fcls, o)

if o.label > 0 && ~o.badannot && ~o.diff && ~isempty(o.cube)
    if isempty(fcls)
        ol = o.label;
        assert(ol <= 21);
    else
        % assert(o.label <= 21)
        ol = fcls.reduced_to_final(o.label);
    end
else
    ol = 0;
end




