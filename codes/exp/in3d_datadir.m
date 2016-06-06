function r = in3d_datadir()
%IN3D_DATADIR Gets the root directory of data
%
%   This function reads the info from ../data.cfg

% get the code directory
tbdir = fileparts(fileparts(mfilename('fullpath')));
cfgfile = fullfile(tbdir, 'data.cfg');

if ~exist(cfgfile, 'file')
    error('The file %s is not found.\n', cfgfile);
end

cfg = in3d_readcfg(cfgfile);
r = cfg.datadir;
