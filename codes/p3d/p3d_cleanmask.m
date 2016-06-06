function msk = p3d_cleanmask(s)
%P3D_CLEANMASK Generate a mask of clean points
%
%   msk = P3D_CLEANMASK(s);
%
%       This function tests each point on the observed plane and 
%       determines whether it is clean enough for geometric estimation
%       (e.g. whether the normal vector estimated at the point is 
%       reliable). 
%       
%       It returns a logical mask, where clean parts are set to true.
%
%       s is a scene struct.
%

%% main

wc = double(s.wcoords);
x = wc(:,1);
y = wc(:,2);
z = wc(:,3);

h = size(s.image, 1);
w = size(s.image, 2);

x = reshape(x, [h w]);
y = reshape(y, [h w]);
z = reshape(z, [h w]);

xm = medfilt2(x, [5,5]);
ym = medfilt2(y, [5,5]);
zm = medfilt2(z, [5,5]);

s = abs(x - xm) + abs(y - ym) + abs(z - zm);

% thres = quantile(s(:), 0.8);
msk = s < 0.005;

