function r = in3d_getobjdir(datadir, objty)
%INT3D_GETOBJDIR Get object directory according to type
%
%   IN3D_GETOBJDIR(datadir, objty);
%
%   Here, objty can be either 'gt' or 'ex'
%

switch lower(objty)
    case 'gt'
        subdir = 'gtobjects_a';
    case 'hj'
        subdir = 'hjobjects';
    case 'ft08'
        subdir = 'ft08_objects';
    case 'ft15'
        subdir = 'ft15_objects';
    case 'ft30'
        subdir = 'ft30_objects';
    case 'ft50'
        subdir = 'ft50_objects';             
    case 's08'
        subdir = 's08_objects';
    case 's15'
        subdir = 's15_objects';
    case 's30'
        subdir = 's30_objects';                  
    case 's50'
        subdir = 's50_objects'; 
    case 'n08'
        subdir = 'n08_objects';
    case 'n15'
        subdir = 'n15_objects';
    case 'n20'
        subdir = 'n20_objects';
    case 'n30'
        subdir = 'n30_objects';
    case 'n40'
        subdir = 'n40_objects';
    case 'n50'
        subdir = 'n50_objects'; 
    case 'nn08'
        subdir = 'nn08_objects';
    case 'nn15'
        subdir = 'nn15_objects';
    case 'nn20'
        subdir = 'nn20_objects';
    case 'nn30'
        subdir = 'nn30_objects';
    case 'nn40'
        subdir = 'nn40_objects';
    case 'nn50'
        subdir = 'nn50_objects';        
    otherwise
        error('Unknown object type %s', objty);
end

r = fullfile(datadir, subdir);