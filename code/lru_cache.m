classdef lru_cache < cache
    %LRU_CACHE Implements a cache ruled by a LRU policy.
    %   Detailed explanation goes here
    
    properties
        
        % in addition the cache properties, it must keep track of cache
        % entries 'age', i.e. entry age(c) is represents the number of
        % consecutive cache accesses for which content c hasn't been
        % requested
        age = []
        
    end
    
    methods
        
        % class constructor
        function obj = cache(n_content, size)
            
            if (nargin == 2)
            
                % initialize cache contents to zeros
                obj.CACHE = zeros(n_content, size);
                
                % auxiliary properties
                obj.size = size;
                obj.content_size = n_content;
                
                % initialize age matrix
                obj.age = zeros(n_content, 1);
                
            end
            
        end
        
        % updates the state of the cache, according to the Interest inputs
        function outputs = updateOnInterest(obj, inputs)
        
            % first check if the arriving Interests refer to content items
            % maintained in the cache. if so, save the values in the
            % output array.
            outputs = obj.isCached(inputs);
            
            % update the age of the content items for each we just
            % witnessed cache hits
            i = (outputs > 0);
            
            % according to LRU policy, reset the age of the cache hit,
            % increase the age of all others by +1
            obj.age = obj.age + 1;
            obj.age(i) = 0;
            
        end
        
        % updates the state of the cache, according to the Data inputs
        function [] = updateOnData(obj, inputs)
        
            % in this function, we update the contents of the cache, which
            % may include remove a certain cotent item c. we assume that
            % the values given as inputs have already been checked for
            % existing PIT entries (with unsolicited Data packets
            % discarded)
            
            % check if any of the objects given as input is NOT in the
            % cache (note that the isNotCached() function returns an array
            % encoded as '0' and '1', in which '1' indicates that content c
            % is NOT cached).
            aux = obj.isNotCached(inputs);

            % if sum(aux) = r > 0 and the cache is full, we need to make 
            % room for r content items. that means, evicting the 'oldest'
            % r items, and replacing them for the values in aux.
            r = sum(aux);
            
            if r > 0
                
                % get the indexes of the columns for the free slots of the
                % cache
                frii = obj.getFreeSlots;
                
                if sum(frii) < r
                
                    % get the r oldest entries, i.e. r entries in age with
                    % largest values
                    [sortedValues, sortIndex] = sort(obj.age,'descend');

                    % ok, so now, simply replace the lines of CACHE related to
                    % the new content to be cached with the lines which were
                    % occupided by the evicted contents
                    obj.CACHE(aux > 0,:) = obj.CACHE(sortIndex(1:r),:);

                    % set the lines of the evicted contents to zeros. this
                    % procedure guarantees cache validity, and the order within
                    % the cache doesn't matter for LRU, all it matters is for
                    % some content to be in the cache.
                    obj.CACHE(sortIndex(1:r),:) = zeros(r, obj.size);
                
                else
                   
                    % if there are free slots, distribute the free columns
                    % over the content indexes
                    
                    % generate r free slot rows
                    rows = zeros(r, obj.size);
                    
                    for i = 1:1:r                        
                        rows(i, frii(i)) = 1;                        
                    end
                    
                    obj.CACHE(aux > 0,:) = rows(1:r);
                    
                end
                
            end
            
        end
        
    end
    
end

