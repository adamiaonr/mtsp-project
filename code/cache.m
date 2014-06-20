classdef (Abstract) cache < handle
    %CACHE Abstraction of an NDN cache.
    %   This abstract class provides the common properties and methods for 
    %   NDN cache abstractions, 
    %   while concrete instantiations of this class may implement specific
    %   cache replacement policies (e.g. LRU, randomized, etc.)
    
    properties
        
        % the actual cache table, a C x N matrix, in which C is the number
        % of different types of content considered in the runs and N is the
        % size of the cache (one normally assumes N << C)
        
        % the table consists in a sparse matrix, encoded as 0 and 1, in
        % which a 1 at position (c,n) indicates the presence of content c
        % in the cache, at position n
        
        % note that the total number of 1s must not exceed N (i.e.
        % sum(sum(CACHE)) <= N) and the sum of each column and row must
        % always be equal to 1 or 0 (i.e. 0 <= sum(CACHE(c,:)) <= 1 and
        % 0 <= sum(CACHE(:,n)) <= 1)
        CACHE = []
        
        % some auxiliary properties
        size = 0;
        content_size = 0;
        
    end

    methods
        
        % class constructor
        function obj = cache(content_n,size)
            
            if (nargin == 2)
            
                % initialize cache contents to zeros
                obj.CACHE = zeros(content_n,size);
                
                % auxiliary properties
                obj.size = size;
                obj.content_size = content_n;
                
            end
        end
        
        % checks cache validity
        function result = checkValidity(obj)
            
            % test 1, check for overall cache validity
            result = (sum(sum(obj.CACHE)) <= obj.size);
                        
            % test 2, check for row cache validity
            for c = 1:obj.content_size
                
                s = sum(obj.CACHE(c,:));
                result = result & (s >= 0 && s <= 1);
            end
            
            % test 3, check for column cache validity
            for n = 1:obj.size
                
                s = sum(obj.CACHE(:,n));
                result = result & (s >= 0 && s <= 1);                
            end
                        
        end
        
    end

    methods (Abstract)
        
        % given some input (possibly retrieved from an interface's input 
        % buffer), act according to some specific cache replacement policy,
        % e.g. LRU, randomized, etc.
        obj = replace(obj,entry)
        
    end
    
end

