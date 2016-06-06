function s = in3d_readcfg(filename)
%IN3D_READCFG Read a simple config into a struct
%
%   s = IN3D_READCFG(filename);
%
%   Suppose the input filereads as
%   -----
%   index = 1
%   status = ok
%
%   The result is a struct s with two fields index and status, whose
%   values are respectively 1 and 'ok'.
%

%% readlines

fid = fopen(filename);
if fid <= 0
    error('Failed to open file %s', filename);
end

text = textscan(fid, '%s', 'delimiter', '\n');
lines = text{1};

fclose(fid);

%% parse lines

s = [];

for i = 1 : length(lines)
    line = strtrim(lines{i});
    if isempty(line) || line(1) == '#'
        continue;
    end
    
    % separate name and value
    ieq = strfind(line, '=');
    if isempty(ieq)
        error('Invalid line (%d): %s\n', i, line);
    end
    ieq = ieq(1);  % only the first one
    
    name = strtrim(line(1:ieq-1));
    vstr = strtrim(line(ieq+1:end));
    if isempty(vstr)
        error('Invalid line (%d): %s\n', i, line);
    end
    
    v = str2double(vstr);
    if isnan(v)  % not a number
        v = vstr;
    end
    
    s.(name) = v;
end

