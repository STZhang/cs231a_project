function F = toy02()
%TOY02 a toy example to test learning of libHCRF
%
%  The dataset is generated at such a way that node1 and node2 tend 
%  to be the same.
%

%% settings

rng(0);
n = 100;    % number of samples
K = 2;      % number of classes

%% construct training features

mu = [0; 0];
cov = [1 0.8; 0.8 1];  

% Observation potentials
%
%   pot(i, 1):  the tendency of local{1} being in class 1
%   pot(i, 2):  the tendency of local{2} being in class 2
%
pots = mvnrnd(mu, cov, n);

[features, y1, y2] = generate_features(pots);


%% construct loss

z2 = zeros(K, K);

for i = 1 : n
    s = [];
    s.local{1}.NumStates = K;
    s.local{2}.NumStates = K;
    
    if y1(i) == 1
        s.local{1}.pot = [1 0];
    else
        s.local{1}.pot = [0 1];
    end
    
    if y2(i) == 1
        s.local{2}.pot = [1 0];
    else
        s.local{2}.pot = [0 1];
    end
    
    s.factor = {};
    
    s.local{1}.connTo = 1;
    s.local{2}.connTo = 1;
    s.factor{1}.size = K;
    s.factor{1}.pot = z2;
    
    loss.sample{i} = s;
end


%% calculating empirical means
%
% empirical means are defined as sum of potentials ob ground-truths
%

d = zeros(2);

for i = 1 : n
    s1 = features{1}.sample{i};
    s2 = features{2}.sample{i};
    
    % feature 1
    d(1) = d(1) + s1.local{1}.pot(y1(i)) + s1.local{2}.pot(y2(i));
    
    % feature 2
    d(2) = d(2) + s2.factor{1}.pot(y1(i), y2(i));    
end

fprintf('empirical mean = [%g, %g]\n', d(1), d(2));

%% perform learning

fprintf('Learning ...\n');

p = 2;  % L-p norm
C = 1;  % regularization coefficient
epsilon = 1; % epsilon = 1 for CRF, and 0 for SVM
rGap = 1e-4;
it = 10;  % the number of iterations
th_init = ones(2, 1);   % initial theta

fprintf('training\n');
theta = libCRFmatlab(features, loss, th_init, epsilon, 1, d, p, C, rGap, it); 

fprintf('solution = [%g, %g]\n', theta(1), theta(2));


%% testing

fprintf('\ntesting\n');
test_pots = mvnrnd(mu, cov, n);
[test_features, ty1, ty2] = generate_features(test_pots);

preds = libCRFmatlab(test_features, [], theta, 0, 0);
F = test_features;

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


function [features, y1, y2] = generate_features(pots)

n = size(pots, 1);
K = size(pots, 2);
assert(K == 2);

z = zeros(1, K);
pot2 = eye(2);

for i = 1 : n
    % observation potentials
    
    s = [];
    s.local{1}.NumStates = K;
    s.local{2}.NumStates = K;
    s.local{1}.pot = [pots(i, 1), 0];
    s.local{2}.pot = [pots(i, 2), 0]; 
    s.factor = {};
    
    features{1}.sample{i} = s;
    
    % interaction potentials
    
    s = [];
    s.local{1}.NumStates = K;
    s.local{2}.NumStates = K;
    s.local{1}.pot = z;
    s.local{2}.pot = z;
    s.local{1}.connTo = 1;
    s.local{2}.connTo = 1;
    s.factor{1}.size = [K, K];
    s.factor{1}.pot = pot2;
    s.factor{1}.nodes = [1 2];
    
    features{2}.sample{i} = s;           
end

% ground-truth labels

pot1 = pots(:,1);
pot2 = pots(:,2);

y1 = ones(1, n); y1(pot1 < 0) = 2;
y2 = ones(1, n); y2(pot2 < 0) = 2;

