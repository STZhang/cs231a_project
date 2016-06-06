classdef gcrf_sample < handle
    % The class to represent a sample in a generic CRF framework
    %
    % This class mainly encapsulates the basic info as follows
    %
    %   - the number of samples
    %   - the number of local variables at each sample
    %   - the number of states of each local variable
    %
    
    properties(GetAccess='public', SetAccess='private')
        num_locals = 0;     % the number of local variables
        locals;             % the struct stores the local info
        Ks;                 % vector of #states
    end
    
    methods
        function iv = add_local(obj, name, nstates)
            % Add a single local variable
            %
            %   obj.add_local(name, nstates);
            %
            %   This method returns the index of the added variable
            
            
            if isfield(obj.locals, name)
                error('locals already contains a variable of name %s', ...
                    name);
            end
            
            bi = obj.num_locals;
            obj.locals.(name) = struct('bi', bi, 'nv', 1, 'K', nstates);
            obj.Ks(bi + 1) = nstates;
            obj.num_locals = bi + 1;
            iv = bi + 1;
        end
        
        function inds = add_locals(obj, name, nv, nstates)
            % Add a batch of multiple local variables
            %
            %   obj.add_locals(obj, name, nv, nstates);
            %
            %   This method returns the indices of the added variables
            
            if isfield(obj.locals, name)
                error('locals already contains a variable of name %s', ...
                    name);
            end
            
            bi = obj.num_locals;
            obj.locals.(name) = struct('bi', bi, 'nv', nv, 'K', nstates);
            obj.Ks(bi+1:bi+nv) = nstates;
            obj.num_locals = bi + nv;  
            inds = bi+1:bi+nv;
        end
        
        function inds = var_inds(obj, name)
            % Retrieve the variable index (indices)
            %
            %   inds = obj.var_inds(name)
            %
            
            a = obj.locals.(name);
            if a.nv == 1
                inds = a.bi + 1;
            else
                inds = a.bi + 1 : a.bi + a.nv;
            end
        end        
        
        function disp(obj)
            % overrided disp function
            
            fprintf('gcrf_sample (with %d vars)\n', obj.num_locals);
            if ~isempty(obj.locals)                
                vnames = fieldnames(obj.locals);
                for i = 1 : length(vnames)
                    vn = vnames{i};
                    a = obj.locals.(vn);
                    fprintf('\t%s[%d]: %d states\n', vn, a.nv, a.K);
                end
            end
            fprintf('\n');
        end
    end

    
end
