function [P, acc] = mc_svmpredict(models, clabels, X, L)
%MC_SVMPREDICT Generates probabilistic predictions 
%
%   P = MC_SVMPREDICT(models, clabels, X, L);
%
%   Input:
%   - models:   A cell array of models
%   - X:        feature set [d x n matrix]
%   - L:        the label vector of length n.
%
%   Output:
%   - P:        output matrix [n x k]
%     

K = numel(models);
n = size(X, 2);

P = zeros(n, K);

X = X.';
L = L(:);

for k = 1 : K
    Lk = 2 * (L == clabels(k)) - 1;    
    [~, ~, dec] = svmpredict(Lk, X, models{k}, '-q');
    P(:,k) = dec;
end

[~, pred] = max(P, [], 2);
pred = clabels(pred);
if size(pred, 2) > 1
    pred = pred.';
end
acc = nnz(L == pred) / numel(L);

