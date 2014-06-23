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
        function obj = cache(content_n, size)
            
            if (nargin == 2)
            
                % initialize cache contents to zeros
                obj.CACHE = zeros(content_n, size);
                
                % auxiliary properties
                obj.size = size;
                obj.content_n = content_n;
                
                % initialize age matrix
                obj.age = zeros(content_n, 1);
                
            end
            
        end
        
        % updates the state of the cache, according to the Interest inputs.
        % one assumes that inputs as a (2 x C) x I array, in which the
        % first the rows 1 to C are related to Interest signals while those
        % from (C + 1) to (2 x C) relate to Data signals, and I is the
        % number of interfaces on which the Interest packets have been
        % received.
        function [data_outputs, remaining_interests] = updateOnInterest(obj, inputs)

            % the arrays returned by this method should encode the values 
            % as (2 x C) x I matrixes, with '0' and '1', for coherence
            
            % 1) build the output Data signals
            
            % 1.1) get the cached contents at this point
            cached = obj.getCached;
                        
            % 1.2) set the appropriate rows of inputs to [0 0 ... 0], i.e. 
            % all the row 
            % indexes i for which cached(i) = 0 AND with i in the range 
            % 1:C (i.e. only Interest signals). the diag() statement allows
            % a direct matrix multiplication which 'erases' (i.e. sets to
            % [0 0 ... 0]) the appropriate rows in inputs.
            data_outputs = diag([cached ; zeros(n_contents, 1)]) * inputs;
                        
            % 1.3) swap the rows from outputs, as the top C rows correspond
            % to Interest signals, while the bottom C rows to Data signals.
            data_outputs = [data_outputs((n_contents + 1):(2 * n_contents),:); data_outputs(1:n_contents,:)];
            
            % 2) build the output Interest signals. no need to swap rows, 
            % as the order of rows is correct (Interest signals on top)
            not_cached = ~cached;
            remaining_interests = diag([not_cached ; zeros(n_contents, 1)]) * inputs;
            
            % update the age of the content items for each we just
            % witnessed cache hits
            i = (cached > 0);
            
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
            not_cached = ~obj.getCached & sum(inputs((obj.content_n + 1):(2 * obj.content_n),:));

            % if sum(aux) = r > 0 and the cache is full, we need to make 
            % room for r content items. that means, evicting the 'oldest'
            % r items, and replacing them for the values in aux.
            r = sum(not_cached);
            
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
                    obj.CACHE(not_cached > 0,:) = obj.CACHE(sortIndex(1:r),:);

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
                    
                    obj.CACHE(not_cached > 0,:) = rows(1:r);
                    
                end
                
            end
            
        end
        
    end
    
end

