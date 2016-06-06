function cnts = in3d_objcounts()

s = load('~/data/NYUv2/ground_truths.mat');
GTs = s.GTs;

K = 21;

spl = load('~/data/NYUv2/split');
te = spl.test';

cnts = zeros(K, 1);

for i = te
    gt = GTs{i};
           
    for j = 1 : gt.nobjs
        if gt.use(j)
            c = gt.final_label(j);
            cnts(c) = cnts(c) + 1;
        end
    end        
end



