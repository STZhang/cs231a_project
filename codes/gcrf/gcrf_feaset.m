classdef gcrf_feaset < handle
    % The class to capture the feature set specification
    %
    %   The information contains in an instance includes:
    %       
    %   - the number of features
    %   - the names of the features
    %   - the potential size of the features
    %
    %   This class only gives a specification, and does not store
    %   potential values.
    %
    
    properties(GetAccess='public', SetAccess='private')
        num_features;   % the number of features
        feaspecs;       % the feature specification struct
    end
    
    
    methods        
        function obj = gcrf_feaset()
            % Creates an empty feature set
            %
            %   obj = gcrf_feaset();
            %
            
            obj.num_features = 0;
            obj.feaspecs = [];
        end
        
        function idx = add_feature(obj, name, potsize)
            % add a feature type
            %
            %   idx = obj.add_feature(name, potsize);
            %
            %       potsize is the size of the associated potentials.
            %
            %       For unary feature, potsize should be a scalar
            %       For binary feature, potsize should be a pair like 
            %       [K1, K2].
            %
            %       This method returns the index of the added feature.
            %
            
            if isfield(obj.feaspecs, name)
                error('The feature %s has already been added.', name);
            end
            
            if ~(isvector(potsize) && all(potsize == fix(potsize)))
                error('The potsize should be an integer of a vector of integers.');
            end
            
            idx = obj.num_features + 1;
            obj.feaspecs.(name) = struct('index', idx, 'potsize', potsize);
            
            obj.num_features = idx;                                   
        end        
        
    end    
    
end