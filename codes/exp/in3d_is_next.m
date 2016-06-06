function tf = in3d_is_next(o1, o2)
% test whether two objects are next to each other
%

cb1 = o1.cube;
cb2 = o2.cube;
tf = ~isempty(cb1) && ~isempty(cb2) && ...
    p3d_gnddist(cb1, cb2) < 0.2 && ...
    cb2.centers(2) > cb1.centers(2);
