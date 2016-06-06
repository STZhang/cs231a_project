function in3d_ns(k)

objty = sprintf('nn%02d', k);

% Run GT with varying Cs

%Cs = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5];
Cs = [0.01];
cfgs = {'f01', 'f02', 'f03', 'f04', 'f05', 'f06'};

for k = 1 : length(cfgs)
    for i = 1 : length(Cs)
        C = Cs(i);
        cfg = cfgs{k};
        in3d_main(objty, cfg, C);
    end
end
