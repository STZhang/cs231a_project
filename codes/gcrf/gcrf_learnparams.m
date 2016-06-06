function s = gcrf_learnparams(varargin)
%GCRF_LEARNPARAMS Gets a struct of learning parameters
%
%   s = GCRF_LEARNPARAMS();
%
%       returns the default parameters
%
%   s = GCRF_LEARNPARAMS('name1', val1, 'name2', val2, ...);
%
%       returns a parameter struct using customzied values.
%       For those values that the users did not provide, the default
%       values will be used.
%       

%% setup defaults

s.p = 2;
s.c = 1;
s.epsilon = 1;
s.rgap = 1e-6;
s.iters = 10;

% override using customized values

if ~isempty(varargin)
    names = varargin(1:2:end);
    vals = varargin(2:2:end);
    
    if ~(length(names) == length(vals) && iscellstr(names))
        error('Invalid argument list.');
    end
    
    for i = 1 : length(names)
        cn = lower(names{i});
        cv = vals{i};
        
        if ~isfield(s, cn)
            error('%s is not a valid parameter name.', cn);
        end
        
        if ~(isscalar(cv) && isnumeric(cv))
            error('The value for param %s must be a numeric scalar.', cn);
        end
        
        s.(cn) = cv;
    end    
end


