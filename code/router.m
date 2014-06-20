classdef router < handle
    %ROUTER Abstraction of an NDN router
    %   (...)
    
    properties
        
        % an NDN router has a set of network interfaces (input and output
        % interfaces)
        
        % for the time being (and for simplicity) let's assume each NDN
        % router has 1 input and 1 output interface
        iface@interface;
        oface@interface;
        
        % cache, initialized in the constructor
        cache@cache;
        
        % Pending Interest Table (PIT) abstraction
        pendingit@pit;
        
    end

    methods
        
        function obj = router(cache_size, n_inputs, n_outputs, n_contents)
          
            if (nargin == 4)
           
                % create an NDN cache with size of 'cache_size' slots

                % initialize the input and output interfaces
                obj.iface(1,n_inputs) = interface(n_contents);
                obj.oface(1,n_outputs) = interface(n_contents);
                
            end
            
        end
        
        function [] = ifacePut(obj,iface_index, value)
           
            obj.iface(iface_index).put(value);
            
        end
        
        function contents = ifaceGet(obj,iface_index)
           
            contents = obj.iface(iface_index).get;
            
        end

        function [] = ofacePut(obj,oface_index, value)
           
            obj.oface(oface_index).put(value);
            
        end

        function contents = ofaceGet(obj,oface_index)
           
            contents = obj.iface(oface_index).get;
            
        end
        
    end
        
end
