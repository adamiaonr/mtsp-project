classdef (Abstract) cache < handle
    %CACHE Abstraction of an NDN cache.
    %   This abstract class provides the common properties and methods for 
    %   NDN cache (aka Content Store, CS) abstractions, 
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
        content_n = 0;
        
    end

    methods
        
        % class constructor
        function obj = cache(content_n, size)
            
            if (nargin == 2)
            
                % initialize cache contents to zeros
                obj.CACHE = zeros(content_n, size);
                
                % auxiliary properties
                obj.size = size;
                obj.content_n = content_n;
                
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
        
        % returns a C x 1 array withe the content items which are cached
        % (rows set to '1') and those which are not cached (rows set to
        % '0')
        function contents = getCached(obj)
            
            contents = sum(obj.CACHE, 2) & 1;
            
        end
                
        % evaluates which of the contents set to '1' in inputs are cached 
        % in the
        % router's CS. for each row set to '1', it means the element is
        % cached in the CS.
        function contents = isCached(obj, inputs)

            % assuming that the cache is valid and follows propper
            % encoding, then it's as simple as this...
            contents = sum(obj.CACHE, 2) & inputs;
            
        end
        
        % evaluates which of the contents set to '1' in inputs are NOT 
        % cached in the
        % router's CS. for each row set to '1', it means the element is
        % NOT cached in the CS.
        function contents = isNotCached(obj, inputs)
        
            contents = ~sum(obj.CACHE, 2) & inputs;
            
        end

        % returns the column indexes of free slots in the cache
        function columns = getFreeSlots(obj)

            % once again, assuming proper encoding, it's as simple as
            % this...
            columns = ~sum(obj.CACHE);
            
        end
        
    end

    methods (Abstract)
        
        % update cache state upon Interest inputs
        outputs = udpateOnInterest(obj, inputs)
        
        % update cache state upon Data inputs
        outputs = udpateOnData(obj, inputs)        
        
    end
    
end

