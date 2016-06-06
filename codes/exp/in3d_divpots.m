function pots = in3d_divpots(GTs, P)
%IN3D_DIVPOTS Divides a whole potential map into a cell array
%
%   pots = IN3D_DIVPOTS(GTs, P);
%

b = 0;

n = length(GTs);
pots = cell(n, 1);

for i = 1 : n
    gt = GTs{i};
    
    pots{i} = P(b+1:b+gt.nobjs, :);
    b = b+gt.nobjs;    
end

assert(b == size(P, 1));

