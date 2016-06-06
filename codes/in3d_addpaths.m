function in3d_addpaths()
%IN3D_ADDPATHS Add paths for in3d library
%
%   IN3D_ADDPATHS
%
%   Note: this function only adds paths for the current session.
%   To save them permanently, you can do "savepath".
%

rdir = fileparts(mfilename('fullpath'));

paths = { rdir, ...
    fullfile(rdir, 'p3d'), ...
    fullfile(rdir, 'gcrf'), ...
    fullfile(rdir, 'svm'), ...
    fullfile(rdir, 'exp')};

addpath(paths{:});


