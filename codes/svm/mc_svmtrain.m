function [models, clabels] = mc_svmtrain(X, labels, C, gamma)
%MC_SVMTRAIN Trains a multi-class support vector machine
%
%   Note: this function relies on LIBSVM, and trains
%   K one-as-all models
%
%   [models, clabels] = MC_SVMTRAIN(X, labels, C, gamma);
%
%   Inputs: (suppose there are n samples of dimension d)
%
%   - X:        feature matrix of size [d x n]
%   - labels:   label vector of length n
%   - C:        the C coefficient
%   - gamma:    the gamma coefficient
%
%   Outputs:
%
%   - models:   a cell array of K models
%   - clabels:  a vector of length K.
%               clabels(k) is the class label for the model
%               at models{k}.
%

%% verify input

if ~(ismatrix(X) && isa(X, 'double'))
    error('X should be a double matrix.');
end
[d, n] = size(X);

if n ~= length(labels)
    error('Inconsistent number of samples.');
end

if ~(isscalar(C) && C > 0)
    error('C must be a positive real value.');
end

if ~(isscalar(gamma) && gamma > 0)
    error('gamma must be a positive real value.');
end

clabels = unique(labels);
K = length(clabels);

%% main

% printing basic info

params = sprintf('-c %g -g %g -q', C, gamma);

fprintf('MC-SVM training ...\n');
fprintf('-------------------------------\n');
fprintf('num classes = %d\n', K);
fprintf('num samples = %d\n', n);
fprintf('sample dim  = %d\n', d);
fprintf('params: %s', params);
fprintf('\n');

% train on each class

X = X.';    % libsvm use row-based samples


models = cell(K, 1);

for k = 1 : K
    clabel = clabels(k);   
        
    L = - ones(n, 1);
    L(labels == clabel) = 1;
    npos = nnz(L > 0);
    nneg = n - npos;
    
    fprintf('On class %d/%d (label = %d): #pos = %d, #neg = %d ...\n', ...
        k, K, clabel, npos, nneg);
    
    tk = tic;
    
    models{k} = svmtrain(L, X, params);
    
    et = toc(tk);
    
    fprintf('Class %d/%d finished (elapsed = %.4f sec)\n', k, K, et);
    
    fprintf('\n');
end

