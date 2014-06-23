classdef pit < handle
    %PIT Abstraction for an NDN Pending Interest Table (PIT)
    %   Detailed explanation goes here
    
    properties
        
        % the PIT is simply a C x I matrix which relates some content
        % entry c (in this case represented by the row, numbered from 1 to 
        % C) with a set of outgoint interfaces for Interest packets (i.e. 
        % the columns 1 to I, where I is equal to the number of interfaces
        % of the NDN router)
        PIT = []
        
    end
    
    methods
        
        % class constructor
        function obj = pit(content_n, iface_n)
            
            if (nargin == 2)
            
                % initialize interface's buffer to zeros
                obj.PIT = zeros(content_n, iface_n);
            end
        end
        
        % add an entry to the PIT
        function obj = add(obj, entry, iface)
                                
            % simply OR the entry Interest values to the corresponding
            % column on the PIT
            obj.PIT(:, iface) = obj.PIT(:, iface) | entry;
                        
        end
        
        % clear PIT contents by interface
        function [] = clearIface(obj, iface)
        
            obj.PIT(:, iface) = obj.PIT(:, iface) .* 0;
            
        end
        
        % clear PIT contents by content
        function [] = clearContent(obj, content)
        
            obj.PIT(content,:) = obj.PIT(content,:) .* 0;
            
        end
        
        % clear all PIT contents
        function [] = clearPIT(obj)
        
            obj.PIT = obj.PIT .* 0;
            
        end
        
        % simply show the PIT contents
        function [] = showPIT(obj)
        
            obj.PIT
            
        end
        
        % updates the state of the PIT, according to the Interest inputs,
        % and returns the Interest indexes which should be forwarded
        % upstream
        function outputs = updateOnInterest(obj, inputs)
        
            % first, collect all the content indexes for which outstanding
            % Interests do not exist yet. these will be the Interests which
            % will be re-forwarded upstream.
            outputs = ~sum(obj.PIT, 2) & sum(inputs, 2);
            
            % second, given the inputs on all interfaces, OR it with the
            % PIT contents. One assumes that 'inputs' in a C x I matrix
            % containing all the Interest signals received on the input
            % ports of all the router's interfaces. In short, a '1' entry
            % on position (c,i) in the PIT means that an
            % Interest for content at row c has been received at interface 
            % i and awaiting a corresponding Data object.            
            obj.PIT = (obj.PIT | inputs);
                        
        end
        
        % updates the state of the PIT, according to the Data inputs, and
        % returns all the Data indexes which have not been discarded based
        % on PIT processing (i.e. after discarding unsolicited Data
        % packets)
        function outputs = updateOnData(obj, inputs)
        
            % basically, discard all the row values for which there is no
            % outstanding PIT entry
            outputs = sum(obj.PIT, 2) & sum(inputs, 2);
            
            % now, free the positions in the PIT (since the awaiting Data
            % packets are about to be forwarded downstream)
            obj.PIT = (obj.PIT & ~inputs);
            
        end

    end
    
end

