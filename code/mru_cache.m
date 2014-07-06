classdef mru_cache < cache
    %MRU_CACHE Implements a cache ruled by a MRU policy.
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
        function obj = mru_cache(content_n, size)
            
            if (nargin == 2)
            
                % initialize cache contents to zeros
                obj.CACHE = zeros(content_n, size);
                
                % auxiliary properties
                obj.size = size;
                obj.content_n = content_n;
                
                % initialize age matrix
                obj.age = zeros(content_n, 1);
                
                % initialize data gathering matrices
                obj.stats_hits = zeros(content_n, 1);
                obj.stats_miss = zeros(content_n, 1);
                obj.stats_time = zeros(content_n, 1);
                                
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
            %cached = obj.getCached;
            cached = sum(obj.CACHE, 2);
                        
            % 1.2) set the appropriate rows of inputs to [0 0 ... 0], i.e. 
            % all the row 
            % indexes i for which cached(i) = 0 AND with i in the range 
            % 1:obj.content_n (i.e. only Interest signals). the diag() statement allows
            % a direct matrix multiplication which 'erases' (i.e. sets to
            % [0 0 ... 0]) the appropriate rows in inputs.
            %data_outputs = diag([cached ; zeros(obj.content_n, 1)]);
            %data_outputs = data_outputs * inputs;
            ifaces_n = size(inputs, 2);
            data_outputs = inputs & ([cached ; zeros(obj.content_n, 1)] * ones(1, ifaces_n));
            
            % 1.3) swap the rows from outputs, as the top obj.content_n rows correspond
            % to Interest signals, while the bottom obj.content_n rows to Data signals.
            data_outputs = [data_outputs((obj.content_n + 1):(2 * obj.content_n),:); data_outputs(1:obj.content_n,:)];
            
            % 2) build the output Interest signals. no need to swap rows, 
            % as the order of rows is correct (Interest signals on top)
            not_cached = ~cached;
            %remaining_interests = diag([not_cached ; zeros(obj.content_n, 1)]);
            %remaining_interests = remaining_interests * inputs;
            remaining_interests = inputs & ([not_cached ; zeros(obj.content_n, 1)] * ones(1, ifaces_n));
                                    
            % 3) data gathering operations
            
            % 3.1) update # of hits
            hits = cached & sum(inputs(1:obj.content_n, :), 2);
            obj.stats_hits((hits > 0)) = obj.stats_hits((hits > 0)) + 1;
            
            % 3.2) according to MRU policy, reset the age of the cache hit,
            % increase the age of all others by +1
            obj.age = obj.age + 1;
            obj.age((hits > 0)) = 0;
            
            % 3.3) update # misses
            j = find(sum(remaining_interests, 2));
            obj.stats_miss(j) = obj.stats_miss(j) + 1;
            
        end
        
        % updates the state of the cache, according to the Data inputs
        function [] = updateOnData(obj, inputs)
        
            % GENERAL:            
            % in this function, we update the contents of the CS, which
            % may include remove a certain cotent item. we assume that
            % the values given as inputs have already been checked for
            % existing PIT entries (with unsolicited Data packets
            % discarded).
                        
            % 1) 1-column array with arriving Data signals
            data = (sum(inputs((obj.content_n + 1):(2 * obj.content_n),:), 2) & 1);
            
            % 2) find the 'pseudo order' array
            
            % 2.1) get the indexes of the active Data objects 
            pseudo_order = (1:1:obj.content_n)';
            pseudo_order = pseudo_order .* data;
            
            % 2.2) confine the pseudo order array to the active Data
            % signals only
            pseudo_order_idx = (pseudo_order > 0);                        
            pseudo_order = pseudo_order(pseudo_order_idx);
            pseudo_order_n = length(pseudo_order);
            
            % 2.3) shuffle the array
            pseudo_order_idx = randperm(pseudo_order_n);            
            pseudo_order = pseudo_order(pseudo_order_idx);
            
            % 3) apply the MRU algorithm, element-wise (according to the
            % contents of pseudo_order)
            
            % NOTE: it involves a 'for' cycle, that's horrible in Matlab,
            % but for now, that's the best I can do...            
            
            cached = sum(obj.CACHE, 2);
            
            for i = 1:pseudo_order_n
                
                % 3.1) get the currently cached elements
                %cached = obj.getCached;
                cached = sum(obj.CACHE, 2);
                cached_n = sum(cached);
                                
                % 3.1) check if the element is already cached, if that's so
                % simply update the age value to 0
                if (sum(obj.CACHE(pseudo_order(i),:), 2) == 0)                

                    % 3.2) check if any evictions are necessary.    
                    if (cached_n >= obj.size)

                        % 3.2.1) cache the new Data value and evict the 
                        % MRU value, according to the age matrix
                        [sortedValues, sortIndex] = sort(obj.age, 'ascend');
                        
                        % 3.2.2) determine the sorted indexes which also
                        % happen to be cached
                        sortIndex = cached(sortIndex, :) .* sortIndex;
                        sortIndex = sortIndex(sortIndex > 0);
                                                                                                                        
                        obj.CACHE(pseudo_order(i),:) = obj.CACHE(sortIndex(1),:);            
                        obj.CACHE(sortIndex(1),:) = zeros(1, obj.size);

                    % 3.3) just add the Data to a free slot    
                    else
                        
                        % 3.3.1) get the indexes of the columns for the 
                        % free slots of the CS
                        free_slots = find(obj.getFreeSlots);
                        
                        % 3.3.2) set the Data as cached on the appropriate
                        % slot
                        obj.CACHE(pseudo_order(i),:) = zeros(1, obj.size);
                        obj.CACHE(pseudo_order(i), free_slots(1)) = 1;
                        
                    end
                end
                                
                % 3.2) reset the age for the newly cached Data
                obj.age(pseudo_order(i)) = 0;
                
            end
                        
            % 3.2) update data gathering parameters (caching time)
            %obj.stats_time((cached > 0)) = obj.stats_time((cached > 0)) + 1;
            obj.stats_time = obj.stats_time + cached;
                        
        end
        
    end
    
end
