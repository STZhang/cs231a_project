function r = p3d_overlapr(b1, b2)
%P3D_OVERLAPR Compute overlap ratio of two boxes
%
%   r = P3D_OVERLAPR(b1, b2);
%
%       b1 and b2 are boxes in the form of [xmin, xmax, ymin, ymax];
%
%       r = intersection / union
%

%% main

% computer intersected area

ix = overlap_len(b1(1), b1(2), b2(1), b2(2));
iy = overlap_len(b1(3), b1(4), b2(3), b2(4));

ia = ix * iy;

if ia > 0;
    a1 = box_area(b1);
    a2 = box_area(b2);
    assert(a1 >= ia && a2 >= ia);
    
    r = ia / (a1 + a2 - ia);
else
    r = 0;
end


function r = overlap_len(a0, a1, b0, b1)
% Compute intersection length of two segments [a0 a1] & [b0 b1]

x0 = max(a0, b0);
x1 = min(a1, b1);
r = max(x1 - x0, 0);

function r = box_area(b)

dx = b(2) - b(1);
dy = b(4) - b(3);
r = dx * dy;

