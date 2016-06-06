function R = in3d_potclassify(K, GTs, pots, si)
%IN3D_POTCLASSIFY Classification based on unary potential
%
%   R = IN3D_POTCLASSIFY(K, GTs, pots);
%   R = IN3D_POTCLASSIFY(K, GTs, pots, si);
%
%   R has three fields:
%   - preds:        Predictions
%   - confus:       confusion matrix [K x K]
%   - accuracy
%

%% check input

assert(numel(GTs) == numel(pots));

if nargin >= 4 && ~isempty(si)
    GTs = GTs(si);
    pots = pots(si);
end

n = numel(pots);

if size(pots{1}, 2) == K + 1
    use_bias = 1;
else
    use_bias = 0;
end


%% main

% prediction

preds = cell(n, 1);

for i = 1 : n
    [~, preds{i}] = max(pots{i}, [], 2);                    
end

% performance evaluation

if use_bias
    C = zeros(K+1, K+1);
else
    C = zeros(K, K);
end

for i = 1 : n
    gt = GTs{i};
    p = preds{i};        
    
    assert(length(gt.use) == gt.nobjs);
    
    for j = 1 : gt.nobjs
        if gt.use(j)
            tl = gt.final_label(j);  
            pj = p(j);            
            
            if use_bias
                if tl == 0
                    tl = K + 1;
                end                
                if pj == 0
                    pj = K + 1;
                end
                C(tl, pj) = C(tl, pj) + 1;
            else
                C(tl, pj) = C(tl, pj) + 1;
            end
        end
    end    
end

R.preds = preds;
R.confus = C;
R.accuracy = sum(diag(C)) / sum(C(:));

