function cubes = p3d_fitcubes_s(s, nrmvecs, cmsk, l, op)
%P3D_FITCUBES_S Fits cubes for a labeled region in a scene
%
%   cubes = P3D_FITCUBES_S(s, nrmvecs, cmsk, l)
%   cubes = P3D_FITCUBES_S(s, nrmvecs, cmsk, l, 'plot')
%
%       Fits cubes for a labeled region in a scene.
%
%       Inputs:
%       - s:        the scene struct
%       - nrmvecs:  the array of normal directions
%       - cmsk:     the clean msk
%       - l:        the label of the region
%      

%% parse input

assert(isstruct(s));
assert(islogical(cmsk));
assert(isscalar(l) && l >= 0 && l == fix(l));

to_plot = nargin >= 5 && strcmpi(op, 'plot');

%% main

% decompose the labeled region into connected components
% a cube is fit to each connected components

cc = bwconncomp(s.labels == l);

% prepare data (to more efficien forms)

wcoords = double(s.wcoords);

h = size(s.image, 1);
w = size(s.image, 2);
if ndims(nrmvecs) == 3
    nrmvecs = reshape(nrmvecs, [h * w, 3]);
end

% main loop

nobjs = cc.NumObjects;
cubes = cell(nobjs, 1);

for i = 1 : nobjs
    si = cc.PixelIdxList{i};
    si = si(cmsk(si));
    % fprintf('  i = %d: %d\n', i, length(si));
    
    if to_plot
        cb = p3d_fitcube(wcoords(si,:), nrmvecs(si,:), 'plot');
    else
        cb = p3d_fitcube(wcoords(si,:), nrmvecs(si,:));
    end
    cb.label = l;
    cubes{i} = cb;
end

cubes = vertcat(cubes{:});

