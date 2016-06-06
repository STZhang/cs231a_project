function [ix, iy] = p3d_caliproj(rot, x, y, z)
%P3D_CALIPROJ projects calibrated 3D points to 2D image coordinates
%
%   [ix, iy] = P3D_CALIPROJ(rot, x, y, z);
%
%       rot:        The calibrated rotation
%       x, y, z:    Calibrated 3D coordinates
%       ix, iy:     Coordinates on image plane
%

% Old ones
%
% rotate 

% if isscalar(theta)
%     if theta ~= 0
%         ct = cos(theta);
%         st = sin(theta);
%         [x, z] = deal(x * ct + z * st, z * ct - x * st);
%     end
% elseif isequal(size(theta), [3 3])
%     rot = theta;
%     xyz = rot * [x; y; z];
%     x = xyz(1, :);
%     y = xyz(2, :);
%     z = xyz(3, :);        
% end
% 
% % project 3D lines to 2D lines
% 
% % NYU camera params
% fx_d = 5.8262448167737955e+02;
% fy_d = 5.8269103270988637e+02;
% cx_d = 3.1304475870804731e+02;
% cy_d = 2.3844389626620386e+02;
% 
% % generate image-plane coordinates
% ix = (x ./ z) * fx_d + cx_d;
% iy = (y ./ z) * fy_d + cy_d;


% Latest one

xyz = rot' * [x; y; z];
x = xyz(1, :);
y = -xyz(2, :);
z = xyz(3, :); 

% project 3D lines to 2D lines

% NYU camera params
fx_rgb = 5.1885790117450188e+02;
fy_rgb = 5.1946961112127485e+02;
cx_rgb = 3.2558244941119034e+02;
cy_rgb = 2.5373616633400465e+02;

% generate image-plane coordinates
ix = (x ./ z) * fx_rgb + cx_rgb;
iy = (y ./ z) * fy_rgb + cy_rgb;

