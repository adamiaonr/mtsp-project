classdef router < handle
    %ROUTER Abstraction of an NDN router
    %   (...)
    
    properties
        
        % an NDN router has a set of I network interfaces
        ifaces@interface;
        
        % cache, or CS in NDN terms, whose specific type (e.g. 'LRU', 
        % 'MRU') is specified via a text argument in the constructor 
        CS@cache;
        
        % Pending Interest Table (PIT) abstraction, size C x I (in which C
        % is the number of different content items we're dealing in the
        % model)
        PIT@pit;
        
        % Forward Information Base (FIB), simply a C x I matrix which 
        % relates some content
        % entry c (in this case represented by the row, numbered from 1 to 
        % C) with a set of outgoing interfaces, which Interest packets must
        % follow
        FIB = []
        
        % dimensions, number of contents (rows) and num of 
        % interfaces (columns)
        content_n = 0;
        iface_n = 0;
        
        % simulation parameters
        id;
        %iface_ends = [];
        
    end

    methods
        
        function obj = router(id, iface_n, content_n, cache_size, cache_type)
                          
            obj.id = id;
            %obj.iface_ends = iface_ends;

            obj.content_n = content_n;
            obj.iface_n = iface_n;

            % create an NDN cache with size of 'cache_size' slots,
            % instatiate a specific class according to cache_type
            if (strcmpi('LRU', cache_type))

                obj.CS = lru_cache(content_n, cache_size);

            else

                % default is an 'LRU' cache
                obj.CS = lru_cache(content_n, cache_size);

            end

            % initialize the interface array, with size n_ifaces

            % the index of the iface array is important, as it
            % identifies a specific iface, encoded in the topology
            % matrix used to create an NDN network
            obj.ifaces = interface(content_n, iface_n);

            % initialize the FIB
            obj.FIB = zeros(content_n, iface_n);

            % TODO: BY DEFAULT, ALL FORWARDING OPERATIONS GO OUT 
            % INTERFACE 1 (THIS MUST BE CHANGED IN THE FUTURE FOR 
            % GENERALITY 
            obj.FIB(:,2) = ones(content_n, 1);

            % initialize the PIT
            obj.PIT = pit(content_n,iface_n);
                            
        end
                
        % . one assumes the outputs are encoded as a C x I matrix, in which
        % C equals to the number of contents and I to the number of
        % interfaces in the present NDN router.
        function [] = putOut(obj, outputs)
        
            obj.ifaces.putOutPorts(outputs);
            
        end
        
        % . one assumes the outputs are encoded as a C x I matrix, in which
        % C equals to the number of contents and I to the number of
        % interfaces in the present NDN router.
        function contents = getOut(obj)
        
            contents = obj.ifaces.getOutPorts;
            
        end
        
        % . one assumes the outputs are encoded as a C x I matrix, in which
        % C equals to the number of contents and I to the number of
        % interfaces in the present NDN router.
        function [] = putIn(obj, inputs)
        
            obj.ifaces.putInPorts(inputs);
            
        end
        
        % . one assumes the outputs are encoded as a C x I matrix, in which
        % C equals to the number of contents and I to the number of
        % interfaces in the present NDN router.
        function contents = getIn(obj)
        
            contents = obj.ifaces.getInPorts;
            
        end
        
        % forward Interest packets. the final result shall be the
        % appropriate activation of Interest and Data signals on the output
        % ports of all the NDN router's interfaces. note the format of
        % input and output signals, a (2 x C) x I matrix (where I is equal
        % to the number of interfaces in the NDN router), with the top 1:C
        % rows referring to Interest signals, and the bottom 
        % (C + 1):(2 x C) rows to Data signals ('0' means a deactivated
        % signal, '1' an activated signal).
        function [] = forwardInterests(obj)
            
            inputs = obj.getIn;
            
            % check if the content is held by the CS (cache). send the 
            % content back towards the requesting interfaces by 
            % activating the appropriate Data signals in their output 
            % ports.
            [data_outputs, remaining_interests] = obj.CS.updateOnInterest(inputs);
            obj.putOut(data_outputs);
            
            % update the PIT, get back the Interests which must still be
            % forwarded upstream
            remaining_interests = obj.PIT.updateOnInterest(remaining_interests);
            
            % place the output of the last step on the output ports of the 
            % appropriate interfaces (according to the FIB)
            to_forward = sum(remaining_interests, 2) & 1;
            to_forward = diag(to_forward(1:obj.content_n));
            to_forward = to_forward * obj.FIB;
            obj.putOut([to_forward; zeros(obj.content_n, obj.iface_n)]);
            
        end
        
        % forward Data packets
        function [] = forwardData(obj)
            
            inputs = obj.getIn;
            
            % discard any unsolicited Data packets
            remaining_data = obj.PIT.updateOnData(inputs);
            
            % send the output from the last step to the output ports of the
            % requesting interfaces (as specified in the PIT)
            obj.putOut(remaining_data);
            
            % update the CS (cache)
            obj.CS.updateOnData(remaining_data);
                        
        end
        
    end
        
end
