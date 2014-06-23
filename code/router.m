classdef router < handle
    %ROUTER Abstraction of an NDN router
    %   (...)
    
    properties
        
        % an NDN router has a set of network interfaces
        iface@interface;
        
        % cache, initialized in the constructor
        cache@cache;
        
        % Pending Interest Table (PIT) abstraction
        PIT@pit;
        
        % Forward Information Base (FIB), simply a C x I matrix which 
        % relates some content
        % entry c (in this case represented by the row, numbered from 1 to 
        % C) with a set of outgoing interfaces, which Interest packets must
        % follow
        FIB = []
        
    end

    methods
        
        function obj = router(n_ifaces, n_contents, cache_size, cache_type)
          
            if (nargin == 4)
           
                % create an NDN cache with size of 'cache_size' slots,
                % according to cache_type
                if (strcmpi('LRU', cache_type))
                    
                    obj.cache = lru_cache(n_contents, cache_size);
                    
                else
                    
                    % default is an 'LRU' cache
                    obj.cache = lru_cache(n_contents, cache_size);
                    
                end

                % initialize the interface array, with size n_ifaces
                
                % the index of the iface array is important, as it
                % identifies a specific iface, encoded in the topology
                % matrix used to create an NDN network
                obj.iface(1, n_ifaces) = interface(n_contents);
                
                % initialize the FIB
                obj.FIB = zeros(n_contents, n_ifaces);
                
                % initialize the PIT
                obj.PIT = pit(n_contents,n_ifaces);
                
            end
            
        end
        
        % put some value in the input port of some interface, indexed by
        % iface_index
        function [] = ifacePut(obj, iface_index, value)
           
            obj.iface(iface_index).putIn(value);
            
        end
        
        % get the values from the output port of the interface indexed by
        % iface_index
        function contents = ifaceGet(obj, iface_index)
           
            contents = obj.iface(iface_index).getOutport;
            
        end
        
        % forward Interest packets
        function forwardInterests(obj)
            
            % check if the content is held by the CS (cache). if it does,
            % send it back towards the requesting interfaces by placing the
            % Data in their output ports.
            
            % update the PIT, get back the Interests which must still be
            % forwarded upstream
            
            % place the output of the last step on the output ports of the 
            % appropriate interfaces (according to the FIB)
            
        end
        
        % forward Data packets
        function forwardData(obj)
            
            % discard any unsolicited Data packets
            
            % send the output from the last step to the output ports of the
            % requesting interfaces (as specified in the PIT)
            
            % update the CS (cache)
                        
        end
        
    end
        
end
