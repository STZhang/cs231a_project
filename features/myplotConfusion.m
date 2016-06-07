function [] = myplotConfusion(matrix)
% generate a rotatable 3-dimensional confusion matrix; the z entry of the
% (i,j) cell is the percent of labels i that were labelled j
% also return the computed confusion matrix C (as a 2D matrix); 

% input variables:
% trueLabels: an integer array of the ground truth labels
% estLabels: an integer array of the estimated labels
% names: (opt) a cell of label names; if this is emitted, the labels will
%        be assigned numerical names (in the plot, along the axes)
% color: (opt) a matlab colormap; default: 'hot'
% ordering: (opt) an array of integers that specifies the order in which to
% arrange the labels; default: confusion matrix is ordered in terms of
% decreasing diagonal entry (presumed to be maximal visibility)

% Zoya Gavrilov, Jan. 7, 2013

if nargin < 3 % generate numerical labels
   l = size(matrix, 1);
   names = cell(1,l);
   for i = 1:l
      names{i} = num2str(i); 
   end

l = size(matrix, 1);
matrix = matrix / norm(matrix, 2);

imagesc(matrix);            %# Create a colored plot of the matrix values
colormap(flipud(bone));  %# Change the colormap to gray (so higher values are
                         %#   black and lower values are white)
colorbar

textStrings = num2str(matrix(:),'%0.2f');  %# Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
[x,y] = meshgrid(1:l);   %# Create x and y coordinates for the strings
hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
                'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim'));  
textColors = repmat(matrix(:) > midValue,1,3);  
set(hStrings,{'Color'},num2cell(textColors,2)); 
set(gca,'XTick',1:l,...                        
        'XTickLabel',names,... 
        'YTick',1:l,...
        'YTickLabel',names,...
        'TickLength',[0 0]);
    
title('Scene Classfication Confusion Matrix(Best)');
xlabel('Intended Label')
ylabel('Chosen Label')
end