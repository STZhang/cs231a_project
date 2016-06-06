function [H, xc, yc] = p3d_hist2d(siz, x, y, w)
%P3D_HIST2D Computes a 2D histogram for a set of data points
%
%   [H, xc, yc] = P3D_HIST2D(siz, x, y)
%
%   Inputs:
%       siz:    The size of the histogram (e.g. [m n])
%       x:      The list of x coordinates
%       y:      The list of y coordinates
%
%   Outputs:
%       H:      The created histogram 
%       xc:     The x coordinates of bin centers (1-by-n)
%       yc:     The y coordinates of bin centers (m-by-1)
%

%% check arguments

if ~(isvector(siz) && numel(siz) == 2 && all(siz == fix(siz)))
    error('siz should be a pair of integers.');
end

if ~isequal(size(x), size(y))
    error('x and y should have the same size.');
end

%% main

m = siz(1);
n = siz(2);

x0 = min(x);
x1 = max(x);
y0 = min(y);
y1 = max(y);

x0 = x0 - (x1 - x0) * 0.05;
x1 = x1 + (x1 - x0) * 0.05;
y0 = y0 - (y1 - y0) * 0.05;
y1 = y1 + (y1 - y0) * 0.05;

kx = n / (x1 - x0);
ky = m / (y1 - y0);

J = double(ceil((x - x0) .* kx));
I = double(ceil((y - y0) .* ky));

H = full(sparse(I, J, w, m, n));

if nargout >= 2    
    xc = x0 + ((1:n) - 0.5) * ((x1 - x0) / n);
    yc = y0 + ((1:m).' - 0.5) * ((y1 - y0) / m);
end


