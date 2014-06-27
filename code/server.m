classdef server < node
    %SERVER Source of content items
    
    properties
        
    end
    
    methods
        
        %class constructor
        function obj = server(id, content_n, ifaces_n)
                          
            % set the element id
            obj.id = id;
            obj.content_n = content_n;

            % initialize the client's single interface
            obj.ifaces = interface(content_n, ifaces_n);
            obj.ifaces_n = ifaces_n;
            
        end
        
        % default answer of the server, simply takes what it gets as
        % Interest signals on its interface's input ports, and mirrors it
        % to the output ports as Data signals.
        function data_outputs = answer(obj)

            data_outputs = obj.ifaces.getInPorts;
            obj.ifaces.putOutPorts([zeros(obj.content_n, obj.ifaces_n); data_outputs((1:obj.content_n), :)]);
            
        end
        
    end
    
end

