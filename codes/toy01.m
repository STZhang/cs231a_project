function pred = toy01()
%TOY01 a simple toy example to test inference of libHCRF
%
%  Formulation:
%
%     Each sample contains two variables: x1 and x2
%
%     The model is formulated as:
%
%       w1 * psi1(x1) + w2 * psi2(x2) + w3 * phi(x1, x2)
%
%
%     Here, x1 can take values in {1, ..., K1}
%           x2 can take values in {1, ..., K2}
%

%% settings

K1 = 2;
K2 = 3;

%% model construction

% first local potential: psi1(x1)
features{1}.sample{1}.local{1}.NumStates = K1;
features{1}.sample{1}.local{1}.pot = [1.0, 0.0];
features{1}.sample{1}.factor = {};

% second local potential: psi2(x2)
features{2}.sample{1}.local{2}.NumStates = K2;
features{2}.sample{1}.local{2}.pot = [0.0, 2.0, 1.0];
features{2}.sample{1}.factor = {};

% the interaction potential: phi(x1, x2)
features{3}.sample{1}.local{1}.NumStates = K1;
features{3}.sample{1}.local{2}.NumStates = K2;
% features{3}.sample{1}.local{1}.pot = zeros(1, K1);
% features{3}.sample{1}.local{2}.pot = zeros(1, K2);
features{3}.sample{1}.local{1}.connTo = 1;
features{3}.sample{1}.local{2}.connTo = 1;
features{3}.sample{1}.factor{1}.size = [2, 3];
features{3}.sample{1}.factor{1}.pot = [1 0 0; 0 1 0];

%% inference

theta = [1 1 1];
pred = libCRFmatlab(features, [], theta, 0, 0);

%% show results

nd1 = pred.node{1};
nd2 = pred.node{2};

fprintf('node{1}: [%g, %g]\n', nd1(1), nd1(2));
fprintf('node{2}: [%g, %g, %g]\n', nd2(1), nd2(2), nd2(3));

