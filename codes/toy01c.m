function pred = toy01c()
%TOY01C Reimplements toy01 using gcrf_* classes
%

%% feature specification

K1 = 2;
K2 = 3;

feas = gcrf_feaset();
feas.add_feature('obs1', K1);    % observation potentials
feas.add_feature('obs2', K2);
feas.add_feature('inter', [K1 K2]);  % interaction between x1 and x2

%% samples

s = gcrf_sample();
ix1 = s.add_local('x1', K1);
ix2 = s.add_local('x2', K2);

%% potentials

pots = gcrf_potset(feas, {s});
pots.set_pot('obs1', 1, ix1, [1.0, 0.0]);
pots.set_pot('obs2', 1, ix2, [0.0, 2.0, 1.0]);
pots.set_pot('inter', 1, [ix1 ix2], [1 0 0; 0 1 0]);

%% perform inference

theta = [1 1 1];
pred = pots.infer(theta);

%% show results

nd1 = pred.node{1};
nd2 = pred.node{2};

fprintf('node{1}: [%g, %g]\n', nd1(1), nd1(2));
fprintf('node{2}: [%g, %g, %g]\n', nd2(1), nd2(2), nd2(3));


