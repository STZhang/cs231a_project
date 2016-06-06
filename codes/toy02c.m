function F = toy02c()
%TOY02C Reimplements toy02 using classes
%

%% feature specification

rng(0);

K = 2;
feas = gcrf_feaset();
feas.add_feature('obs', K);
feas.add_feature('inter', [K, K]);

%% samples

n = 100;

s = gcrf_sample();
s.add_locals('x', 2, K);

samples = cell(n, 1);
for i = 1 : n
    samples{i} = s;
end

%% construct feature set

mu = [0; 0];
cov = [1 0.8; 0.8 1]; 

potvs_tr = mvnrnd(mu, cov, n);
[pots_tr, y1, y2] = generate_pots(feas, samples, potvs_tr);


%% construct loss

loss = gcrf_loss(samples);
for i = 1 : n
    loss.set_gt(i, 1, y1(i));
    loss.set_gt(i, 2, y2(i));
end


%% perform learning

d = loss.empirical_mean(pots_tr);
fprintf('empirical mean = [%g, %g]\n', d(1), d(2));

fprintf('training\n');
params = gcrf_learnparams('rgap', 1.0e-4);
th_init = ones(2, 1);
theta = loss.learn(pots_tr, th_init, d, params);

fprintf('solution = [%g, %g]\n', theta(1), theta(2));


%% testing

fprintf('\ntesting\n');
potvs_te = mvnrnd(mu, cov, n);
[pots_te, ty1, ty2] = generate_pots(feas, samples, potvs_te);

preds = pots_te.infer(theta);
F = pots_te.potentials;

% extract results

ry1 = zeros(1, n);
ry2 = zeros(1, n);

for i = 1 : n
    pr1 = preds(i).node{1};
    pr2 = preds(i).node{2};
    
    [~, ry1(i)] = max(pr1);
    [~, ry2(i)] = max(pr2);
end

fprintf('y1-avg.precision: %g\n', nnz(ry1 == ty1) / n);
fprintf('y2-avg.precision: %g\n', nnz(ry2 == ty2) / n);



%% The core function to generate a feature set

function [pots, y1, y2] = generate_pots(feas, samples, potvs)

n = size(potvs, 1);
K = size(potvs, 2);
assert(numel(samples) == n);
assert(K == 2);

p1 = potvs(:,1);
p2 = potvs(:,2);
pot12 = eye(2);

pots = gcrf_potset(feas, samples);
for i = 1 : n
    pots.set_pot('obs', i, 1, [p1(i), 0]);
    pots.set_pot('obs', i, 2, [p2(i), 0]);
    pots.set_pot('inter', i, [1 2], pot12);
end

% ground-truth labels

y1 = ones(1, n); y1(p1 < 0) = 2;
y2 = ones(1, n); y2(p2 < 0) = 2;

