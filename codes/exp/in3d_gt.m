% Run GT with varying Cs

%Cs = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5];
Cs = [0.01];
cfgs = {'e01', 'e03', 'e14', 'e22', 'e24', 'e25'};

for k = 1 : length(cfgs)
    for i = 1 : length(Cs)
        C = Cs(i);
        cfg = cfgs{k};
        in3d_main('gt', cfg, C);
    end
end
    
