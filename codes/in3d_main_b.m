function in3d_main_b(objty)
%batch version of in3d_main_b

if strcmp(objty, 'gt')
    Cs = [0.001 0.003 0.1 0.3 1 3 10 30 100];
    cfgs = {'e01', 'e02', 'e03', ...
        'e11', 'e12', 'e13', 'e14', 'e15', 'e16', ...
        'e21', 'e22', 'e23', 'e24' };
else
    Cs = [0.1, 0.5, 1, 5];
    cfgs = {'f01', 'f02', 'f03', 'f04', 'f05'};
end

for i = 1 : length(cfgs)
    for j = 1 : length(Cs)
        
        cfg = cfgs{i};
        C = Cs(j);
        
        fprintf('On cfg = %s, C = %g\n', cfg, C);
        fprintf('=================================\n');
        
        in3d_main(objty, cfg, C);
        
        fprintf('\n');
    end
end
