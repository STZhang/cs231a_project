classdef gcrf_potset < handle
    %GCRF The class to represent a potential set for use in CRF train/test
    %
    % Note: this is a light-weight wrapper of libHCRF
    %
    
    properties(GetAccess='public', SetAccess='private')        
        num_features;   % the number of features 
        num_samples;    % the number of samples
        
        feaspecs;       % the specification of features
        samples;        % the cell array of samples
        potentials;     % the libCRF-format cell array of potentials 
        
        fac_counters;   % per-sample factor counter
    end
    
    
    %% Methods for building a feature set
    
    methods
        
        function obj = gcrf_potset(feaset, samples)
            % Creates an empty feature set over a sample set
            %
            %   obj = gcrf_feaset(samples, feaset);
            %
                                    
            if ~isa(feaset, 'gcrf_feaset')
                error('feaset must be an instance of gcrf_feaset.');
            end
            nf = feaset.num_features;
            
            if ~iscell(samples)
                error('samples must be a cell array.');
            end
            
            ns = numel(samples);
            for i = 1 : ns
                if ~isa(samples{i}, 'gcrf_sample')
                    error('Each sample must be of class gcrf_sample.');
                end
            end
                                                            
            % intialize the feature cells
            
            pots = cell(1, nf);
            for k = 1 : nf
                ps = [];
                ps.sample = cell(1, ns);
                for i = 1 : ns
                    s = [];
                    sp = samples{i};
                    nv = sp.num_locals;
                    Ks = sp.Ks;
                    
                    s.local = cell(1, nv);
                    for j = 1 : nv
                        s.local{j}.NumStates = Ks(j);
                        % s.local{j}.pot = zeros(1, Ks(j));
                    end
                    
                    s.factor = {};                    
                    ps.sample{i} = s;
                end
                pots{k} = ps;
            end
           
            % set fields
                                    
            obj.num_samples = ns;
            obj.num_features = nf;
            
            obj.feaspecs = feaset.feaspecs;
            obj.samples = samples;
            obj.potentials = pots;
            obj.fac_counters = zeros(1, ns);
        end
              
        
        function connect_local(obj, ifea, isample, ilocal, ifac)              
            v = obj.potentials{ifea}.sample{isample}.local{ilocal};
            if isfield(v, 'connTo')
                v.connTo = [v.connTo, ifac];
            else
                v.connTo = ifac;
            end
            obj.potentials{ifea}.sample{isample}.local{ilocal} = v;
        end        
        
        
        function set_pot(obj, fea, isample, ilocal, pot)
            % set potential values
            %
            %   obj.set_pot(fea, isample, il, unary_pot);
            %   obj.set_pot(fea, isample, [il1, il2], binary_pot);
            %
            %       Here, fea is the name of the feature.
            %
            
            % retrieve feature info
            
            fs = obj.feaspecs.(fea);
            fidx = fs.index;
            psiz = fs.potsize;
            pd = length(psiz);
            
            assert(numel(ilocal) == pd);
            
            % retrieve sample
            
            s = obj.samples{isample};
            
            if pd == 1   % unary potential
                
                K = s.Ks(ilocal);
                if K ~= psiz
                    error('Incompatible feature & local.');
                end
                if ~isequal(size(pot), [1 K])
                    error('Incorrect potential size.');
                end
                
                obj.potentials{fidx}.sample{isample}.local{ilocal}.pot = pot;
                                
            elseif pd == 2  % binary potential
                
                K = s.Ks(ilocal);
                if ~isequal(K, psiz)
                    error('Incompatible feature & local.');
                end
                if ~isequal(size(pot), K)
                    error('Incorrect potential size.');
                end
                
                il1 = ilocal(1);
                il2 = ilocal(2);
                
                ifac = obj.fac_counters(isample);
                ifac = ifac + 1;
                
                obj.potentials{fidx}.sample{isample}.factor{ifac} = ...
                    struct('size', K, 'pot', pot, 'nodes', [il1, il2]);
                
                obj.connect_local(fidx, isample, il1, ifac);
                obj.connect_local(fidx, isample, il2, ifac);
                
                obj.fac_counters(isample) = ifac;
            else
                error('Only unary and binary potentials are supported.');
            end
            
        end
                
    end
    
    
    %% Methods for inference
    
    methods
    
        function r = infer(obj, theta)
            % Perform inference based on given coefficients
            %
            %   r = obj.infer(theta);
            %
            
            if ~(isfloat(theta) && isvector(theta) && ~issparse(theta))
                error('theta must be a non-sparse numeric vector.');
            end
            
            if length(theta) ~= obj.num_features
                error('Invalid dimension of theta.');
            end
            
            %r = libCRFmatlab(obj.potentials, [], theta, 0, 0);  
            r = libCRFmatlabRgap(obj.potentials, [], theta, 0, 0);
        end
        
    end
end


