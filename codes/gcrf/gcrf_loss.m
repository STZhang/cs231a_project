classdef gcrf_loss < handle
    % The class to represent the loss function in generic CRF learning
    %
    
    properties(GetAccess='public', SetAccess='private')
        num_samples;    % the number of samples        
        samples;        % the cell array of samples
        gtruths;        % the ground-truths
        loss;           % the libCRF-format cell array of loss
    end
    
    
    methods
        
        function obj = gcrf_loss(samples)
            % Construct a loss object over a set of samples
            %
            %   obj = gcrf_loss(samples);
            %
                       
            if ~iscell(samples)
                error('samples must be a cell array.');
            end
            
            ns = numel(samples);
            for i = 1 : ns
                if ~isa(samples{i}, 'gcrf_sample')
                    error('Each sample must be of class gcrf_sample.');
                end
            end                        
            
            % initialize the loss 
            
            G.sample = cell(1, ns);
            L.sample = cell(1, ns);
            for i = 1 : ns
                nv = samples{i}.num_locals;
                G.sample{i} = zeros(1, nv);
                
                ps = struct('local', {{}}, 'factor', {{}});
                L.sample{i} = ps;
            end            
            
            obj.num_samples = ns;
            obj.samples = samples;
            obj.loss = L;            
        end
                       
        function set_gt(obj, isample, ilocal, label, v) 
            % set the ground-truth of a sample
            %
            %   obj.set_gt(isample, ilocal, label);
            %   obj.set_gt(isample, ilocal, label, v);
            %
            %   Note: one can set label = 0 to indicate that
            %         it does not care about the label of 
            %         this variable.
            %
            
            if nargin < 5
                v = 1;
            end
            
            s = obj.samples{isample};
            K = s.Ks(ilocal);
            if numel(label) == 1;
                if label < 0 || label > K
                    error('The label value is out of range.');
                end

                pot = ones(1, K) * v;
                if label > 0
                    pot(label) = 0;
                end
            else
                %pot = ones(1, size(label, 2)) - label / sum(label);
                pot = label * v;
                [~, label] = min(label);
            end
            
            obj.gtruths.sample{isample}(ilocal) = label;
            obj.loss.sample{isample}.local{ilocal} = ...
                struct('NumStates', K, 'pot', pot);
        end
        
        
        function d = empirical_mean(obj, pots)
            % Compute empirical mean from a potential set
            %
            %   d = obj.empirical_mean(pots);
            %
                                    
            feanames = fieldnames(pots.feaspecs);
            ns = pots.num_samples;
            nf = length(feanames);
            gts = obj.gtruths;
            
            d = zeros(nf, 1);
            for k = 1 : nf
                fs = pots.feaspecs.(feanames{k});
                assert(fs.index == k);                
                fd = length(fs.potsize);
                pots_ = pots.potentials{k};
                
                if fd == 1
                    for i = 1 : ns
                        si = pots_.sample{i};
                        gt = gts.sample{i};
                        
                        for j = 1 : length(si.local)
                            lo = si.local{j};
                            if ~isempty(lo) && isfield(lo, 'pot')
                                if gt(j) > 0
                                    d(k) = d(k) + lo.pot(gt(j));
                                end
                            end
                        end                        
                    end
                    
                elseif fd == 2
                    for i = 1 : ns
                        si = pots_.sample{i};
                        gt = gts.sample{i};
                        
                        for j = 1 : length(si.factor)
                            fac = si.factor{j};
                            if ~isempty(fac)
                                nd1 = fac.nodes(1);
                                nd2 = fac.nodes(2);
                                
                                u1 = gt(nd1);
                                u2 = gt(nd2);
                                if u1 > 0 && u2 > 0
                                    d(k) = d(k) + fac.pot(u1, u2);
                                end
                            end                            
                        end                        
                    end
                    
                else
                    error(...
                        'Only unary and binary features are supported');
                end
            end
            
        end
        
                
        function theta = learn(obj, pots, th_init, d, params)
            % Learn model coefficient vector
            %
            %   theta = obj.learn(pots, th_init, d, params);
            %
            %   Inputs:
            %   - pots:     the potentials for training
            %   - th_init:  initial guess of theta
            %   - d:        empirical mean
            %   - params:   training parameters
            %
            
            % argument checking
            
            if ~isa(pots, 'gcrf_potset')
                error('pots must be an instance of gcrf_potset.');
            end
            
            nf = pots.num_features;
            if ~(isvector(th_init) && isfloat(th_init) && ~issparse(th_init))
                error('th_init must be a non-sparse numeric vector.');
            end
            
            if length(th_init) ~= nf
                error('the dimension of th_init is incorrect.');
            end
                        
            if ~(isvector(d) && isfloat(d) && ~issparse(d))
                error('d must be a non-sparse numeric vector.');
            end
            
            if length(d) ~= nf
                error('the dimension of th_init is incorrect.');
            end
            
            if ~isstruct(params)
                error('params must be a struct.');
            end
            
            % learn
            
            theta = libCRFmatlab(pots.potentials, obj.loss, th_init, ...
                params.epsilon, 1, d, ...
                params.p, params.c, params.rgap, params.iters); 
            
        end
        
    end
    
end
    